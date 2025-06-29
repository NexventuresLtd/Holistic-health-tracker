import 'package:client/Widgets/bottom_nav_bar.dart';
import 'package:client/Widgets/profile_card.dart';
import 'package:client/providers/theme_cubit.dart';
import 'package:client/screens/calendar_screen.dart';
import 'package:client/screens/chat_list_screen.dart';
import 'package:client/screens/record_screen.dart';
import 'package:client/screens/userProgress.dart';
import 'package:client/themes/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/dashboard_screen.dart';

class _FamilyListSection extends StatelessWidget {
  final List<dynamic> familyIds;

  const _FamilyListSection({required this.familyIds});

  @override
  Widget build(BuildContext context) {
    if (familyIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            'Your Families',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleSmall!.color,
            ),
          ),
        ),
        FutureBuilder<List<DocumentSnapshot>>(
          future: _getFamiliesData(familyIds),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No family information found'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final family = snapshot.data![index];
                return _FamilyListItem(family: family);
              },
            );
          },
        ),
      ],
    );
  }

  Future<List<DocumentSnapshot>> _getFamiliesData(
      List<dynamic> familyIds) async {
    final futures = familyIds
        .map((id) =>
            FirebaseFirestore.instance.collection('families').doc(id).get())
        .toList();
    return Future.wait(futures);
  }
}

// Add this widget class for individual family items
class _FamilyListItem extends StatelessWidget {
  final DocumentSnapshot family;

  const _FamilyListItem({required this.family});

  @override
  Widget build(BuildContext context) {
    final data = family.data() as Map<String, dynamic>;
    final familyName = data['familyName'] ?? 'Unnamed Family';
    final familyId = family.id;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(Icons.family_restroom,
            color: Theme.of(context).colorScheme.primary),
        title: Text(familyName),
        subtitle: Text(
          'ID: $familyId',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: familyId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Family ID copied to clipboard!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _handleFamilyManagement(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Family Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleSmall!.color,
                ),
              ),
              const SizedBox(height: 24),
              _buildDialogButton(
                context,
                icon: Icons.group_add,
                text: 'Create New Family',
                onPressed: () => _createFamily(context, user.uid),
              ),
              const SizedBox(height: 16),
              _buildDialogButton(
                context,
                icon: Icons.group,
                text: 'Join Existing Family',
                onPressed: () => _joinFamilyDialog(context, user.uid),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(BuildContext context,
      {required IconData icon,
      required String text,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.1),
        foregroundColor: Theme.of(context).textTheme.bodyMedium!.color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Future<void> _createFamily(BuildContext context, String userId) async {
    final familyNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Family',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: familyNameController,
                decoration: InputDecoration(
                  labelText: 'Family Name',
                  hintText: 'Enter family name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.family_restroom,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).textTheme.bodyMedium!.color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (familyNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orange[300],
                            content: const Text('Please enter a family name'),
                          ),
                        );
                        return;
                      }

                      try {
                        final docRef = await FirebaseFirestore.instance
                            .collection('families')
                            .add({
                          'familyName': familyNameController.text,
                          'members': [userId],
                          'patients': [],
                          'createdAt': Timestamp.now(),
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .update({
                          'families': FieldValue.arrayUnion([docRef.id]),
                        });

                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            content: const Text('Family created successfully!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red[300],
                            content: Text('Error: ${e.toString()}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('Create',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinFamilyDialog(BuildContext context, String userId) async {
    final familyIdController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join Family',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: familyIdController,
                decoration: InputDecoration(
                  labelText: 'Family ID',
                  hintText: 'Enter family ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.group, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).textTheme.bodyMedium!.color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (familyIdController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orange[300],
                            content: const Text('Please enter a family ID'),
                          ),
                        );
                        return;
                      }

                      try {
                        final familyDoc = await FirebaseFirestore.instance
                            .collection('families')
                            .doc(familyIdController.text)
                            .get();

                        if (!familyDoc.exists) {
                          throw Exception('Family not found');
                        }

                        await FirebaseFirestore.instance
                            .collection('families')
                            .doc(familyIdController.text)
                            .update({
                          'members': FieldValue.arrayUnion([userId]),
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .update({
                          'families':
                              FieldValue.arrayUnion([familyIdController.text]),
                        });

                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            content: const Text('Joined family successfully!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red[300],
                            content: Text('Error: ${e.toString()}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('Join',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateNotificationPref(String key, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'notificationPreferences.$key': value,
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    // Using StreamBuilder to listen for real-time updates from Firestore.
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            true, // This shows the back button by default
        leading: Container(
          margin: const EdgeInsets.all(4.0), // Add some margin around the icon
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 40,
            ),
            onPressed: () {
              Navigator.pop(context); // This will navigate back
            },
          ),
        ),
        title: const Image(
          image: AssetImage("assets/images/main4.png"),
          height: 300, // Adjust height as needed
        ),
        centerTitle: true,
        actions: const [
          // If you need any actions on the right side
          SizedBox(width: 48), // This balances the leading icon space
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // While waiting for data, show a loading indicator.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data found.'));
          }

          // Assuming your Firestore document has fields: name, joinDate, phone
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userName = userData['fullName'] ?? 'No Name';
          final joinDate =
              userData['createdAt']?.toDate().toString() ?? 'Unknown Date';
          final phone = userData['phone'] ?? 'No Phone';

          final families = userData['families'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(10.0),
            children: [
              const SizedBox(height: 0.0),
              Card(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Image(
                          image: AssetImage("assets/images/main5.png"),
                          width: 120,
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  joinDate,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .color,
                                  ),
                                ),
                                Text(
                                  phone,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 50),
                        Icon(Icons.account_circle_rounded,
                            color: primaryGreen, size: 40),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: InkWell(
                  onTap: () => _handleFamilyManagement(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons
                                  .family_restroom, // Make sure you have this icon
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12.0),
                            Text(
                              "Family Management",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => _handleFamilyManagement(context),
                          icon: Icon(
                            Icons.chevron_right_rounded,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _FamilyListSection(familyIds: families.cast<String>()),
              Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: BlocBuilder<ThemeCubit, bool>(
                  builder: (context, isDark) {
                    return SwitchListTile(
                      title: const Text('Dark Theme'),
                      value: isDark,
                      onChanged: (value) =>
                          context.read<ThemeCubit>().toggleTheme(value),
                    );
                  },
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Medication Reminders'),
                        value: userData['notificationPreferences']
                                ?['medicationReminders'] ??
                            true,
                        onChanged: (value) => _updateNotificationPref(
                            'medicationReminders', value),
                      ),
                      SwitchListTile(
                        title: const Text('Task Alerts'),
                        value: userData['notificationPreferences']
                                ?['taskAlerts'] ??
                            true,
                        onChanged: (value) =>
                            _updateNotificationPref('taskAlerts', value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 0.0),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/record'),
                child: const ProfileCard(
                  iconPath: "assets/fluent_book-exclamation-mark-20-filled.svg",
                  title: 'Health History',
                  description: "Check your All Medical History",
                ),
              ),
              const SizedBox(height: 0.0),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProgressScreen()),
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/main5.png",
                        width: 58,
                        height: 58,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${userName.split(' ')[0]}'s History",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Receive and save up. Points to receive gifts",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lock_open_sharp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 12.0),
                          Text(
                            "Reset Password",
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.titleSmall!.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/reset');
                        },
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.door_front_door,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 12.0),
                          Text(
                            "Log Out",
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.titleSmall!.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onHomePressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()));
        },
        onCalendarPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalendarScreen()),
          );
        },
        onRecordPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordScreen()),
          );
        },
        onChatPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatListScreen()),
          );
        },
        onAddPressed: () {
          print('FAB Clicked');
        },
      ),
    );
  }
}
