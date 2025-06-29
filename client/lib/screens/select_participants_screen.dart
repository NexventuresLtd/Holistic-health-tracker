import 'package:client/globals.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectParticipantsScreen extends StatefulWidget {
  const SelectParticipantsScreen({super.key});

  @override
  _SelectParticipantsScreenState createState() =>
      _SelectParticipantsScreenState();
}

class _SelectParticipantsScreenState extends State<SelectParticipantsScreen> {
  final List<String> _selectedUserIds = [];
  late final String _currentUserId;
  String? _familyId;
  List<User> _familyMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    try {
      // Get user's first family
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();

      final families = List<String>.from(userDoc['families'] ?? []);
      if (families.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('You need to belong to a family to start a chat')),
        );
        Navigator.pop(context);
        return;
      }
      _familyId = families.first;

      // Get family members
      final familyDoc = await FirebaseFirestore.instance
          .collection('families')
          .doc(_familyId)
          .get();

      List<String> memberIds = List<String>.from(familyDoc['members'] ?? []);
      memberIds
          .removeWhere((id) => id == _currentUserId); // Exclude current user

      // Fetch member details
      _familyMembers = await Future.wait(
        memberIds.map((id) async {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(id)
              .get();
          return User.fromFirestore(doc);
        }),
      );

      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading family members: $e')),
      );
    }
  }

  Future<void> _createOrOpenChat() async {
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select at least one participant')),
      );
      return;
    }

    final participants = [_currentUserId, ..._selectedUserIds]..sort();

    try {
      // Check existing chats
      final chatsQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('familyId', isEqualTo: _familyId)
          .where('participants', arrayContainsAny: participants)
          .get();

      Chat? existingChat;
      for (var chatDoc in chatsQuery.docs) {
        final chatParticipants =
            List<String>.from(chatDoc['participants'] ?? [])..sort();
        if (chatParticipants.length == participants.length &&
            const ListEquality().equals(chatParticipants, participants)) {
          existingChat = Chat.fromMap(chatDoc.data(), chatDoc.id);
          break;
        }
      }

      if (existingChat != null) {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/chat-detail',
            arguments: existingChat.id);
        return;
      }

      // Create new chat
      final chatName = await _generateChatName(participants);
      final newChatRef =
          await FirebaseFirestore.instance.collection('chats').add({
        'familyId': _familyId,
        'participants': participants,
        'name': chatName,
        'lastMessage': 'Chat created',
        'lastUpdated': Timestamp.now(),
      });

      // Navigate to new chat
      Navigator.pop(context);

      Navigator.pushNamed(context, '/chat-detail', arguments: newChatRef.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating chat: $e')),
      );
    }
  }

  Future<String> _generateChatName(List<String> participants) async {
    if (participants.length == 2) {
      final otherUserId = participants.firstWhere((id) => id != _currentUserId);
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();
      return doc['fullName'];
    }

    final otherUserIds =
        participants.where((id) => id != _currentUserId).toList();
    final userDocs = await Future.wait(otherUserIds.map(
        (id) => FirebaseFirestore.instance.collection('users').doc(id).get()));
    final names = userDocs.map((doc) => doc['fullName'] as String).toList();
    return 'Group: ${names.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      appBar: AppBar(
        title: Text('New Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _createOrOpenChat,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _familyMembers.isEmpty
              ? Center(child: Text("No family members found"))
              : ListView.builder(
                  itemCount: _familyMembers.length,
                  itemBuilder: (context, index) {
                    final member = _familyMembers[index];
                    return CheckboxListTile(
                      title: Text(member.fullName),
                      value: _selectedUserIds.contains(member.id),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedUserIds.add(member.id);
                          } else {
                            _selectedUserIds.remove(member.id);
                          }
                        });
                      },
                    );
                  },
                ),
    );
  }
}

// Helper classes
class User {
  final String id; // Matches Firestore document ID
  final String fullName;
  final String email;
  final String role;
  final String profileImageUrl;
  final String languagePreference;
  final Map<String, bool> notificationPreferences;
  final DateTime createdAt;
  final List<String> families;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.profileImageUrl,
    required this.languagePreference,
    required this.notificationPreferences,
    required this.createdAt,
    required this.families,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id, // Use document ID instead of non-existent 'userID' field
      fullName: data['fullName'],
      email: data['email'],
      role: data['role'],
      profileImageUrl: data['profileImageUrl'],
      languagePreference: data['languagePreference'],
      notificationPreferences:
          Map<String, bool>.from(data['notificationPreferences']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      families: List<String>.from(data['families']),
    );
  }
}

class Chat {
  final String id;
  final String familyId;
  final List<String> participants;

  Chat({required this.id, required this.familyId, required this.participants});

  factory Chat.fromMap(Map<String, dynamic> data, String id) {
    return Chat(
      id: id,
      familyId: data['familyId'],
      participants: List<String>.from(data['participants']),
    );
  }
}
