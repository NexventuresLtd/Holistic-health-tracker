import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/screens/dashboard_screen.dart';
import 'package:client/globals.dart';
import 'dart:io';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final Color primaryColor = secondaryGreen;
  final Color secondaryColor = const Color(0xFF4E7D96);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF333333);
  final Color greyColor = const Color(0xFF6C757D);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  bool _isLoading = false;
  bool _isUploading = false;
  String? _currentDocId;
  bool _showForm = false;
  File? _selectedImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      // Show options for camera or gallery
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select Image Source',
                    style: _titleStyle(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              Navigator.pop(context, ImageSource.camera),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: primaryColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Camera',
                                  style: _contentStyle(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              Navigator.pop(context, ImageSource.gallery),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.photo_library,
                                  size: 40,
                                  color: primaryColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Gallery',
                                  style: _contentStyle(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: _buttonStyle(color: greyColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (source != null) {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
            _uploadedImageUrl = null; // Clear any existing URL
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}',
              style: _contentStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      setState(() {
        _isUploading = true;
      });

      final User? user = _auth.currentUser;
      if (user == null) return null;

      // Create a unique filename
      final String fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create a reference to Firebase Storage
      final Reference storageRef = _storage
          .ref()
          .child('medical_records')
          .child(user.uid)
          .child(fileName);

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // Get the download URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: ${e.toString()}',
              style: _contentStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _addRecord() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null && _uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image',
              style: _contentStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        String? imageBase64;

        // Upload new image if selected
        if (_selectedImage != null) {
          final bytes = await _selectedImage!.readAsBytes();
          imageBase64 = base64Encode(bytes);
        }

        // Prepare document data
        final recordData = <String, dynamic>{
          'patientId': user.uid,
          'type': _typeController.text.trim(),
          'fileUrl': imageBase64,
          'uploadedBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Add or update document
        if (_currentDocId != null) {
          await _firestore
              .collection('medicalRecords')
              .doc(_currentDocId)
              .update(recordData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Record updated successfully',
                  style: _contentStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          await _firestore.collection('medicalRecords').add(recordData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Record added successfully',
                  style: _contentStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }

        // Reset form
        _resetForm();
        setState(() {
          _showForm = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}',
              style: _contentStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _typeController.clear();
      _selectedImage = null;
      _uploadedImageUrl = null;
      _currentDocId = null;
    });
  }

  void _editRecord(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    setState(() {
      _showForm = true;
      _currentDocId = doc.id;
      _typeController.text = data['type'] ?? '';
      _uploadedImageUrl = data['fileUrl'] ?? '';
      _selectedImage = null; // Clear selected image when editing
    });

    // Scroll to the form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  Future<void> _deleteRecord(String docId) async {
    try {
      await _firestore.collection('medicalRecords').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record deleted successfully',
              style: _contentStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting record: ${e.toString()}',
              style: _contentStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    print(_uploadedImageUrl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medical Image',
          style: _subtitleStyle(),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
            border: Border.all(
              color: Colors.grey[300]!,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  )
                : _uploadedImageUrl != null
                    ? Image.memory(
                        base64Decode(_uploadedImageUrl!),
                        fit: BoxFit.fitHeight,
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Could not load image',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No image selected',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap below to add a photo',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isUploading ? null : _pickImage,
            icon: _isUploading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    Icons.camera_alt,
                    color: primaryColor,
                  ),
            label: Text(
              _isUploading
                  ? 'Uploading...'
                  : (_selectedImage != null || _uploadedImageUrl != null)
                      ? 'Change Photo'
                      : 'Add Photo',
              style: _buttonStyle(),
            ),
          ),
        ),
      ],
    );
  }

  // Text styles for consistent theming
  TextStyle _titleStyle({Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color ?? textColor,
    );
  }

  TextStyle _subtitleStyle({Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color ?? greyColor,
    );
  }

  TextStyle _contentStyle({Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? greyColor,
    );
  }

  TextStyle _buttonStyle({Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color ?? primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Medical Records',
          style: _titleStyle(color: primaryGreen),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: primaryGreen,
            ),
            onPressed: _resetForm,
            tooltip: 'Reset form',
          ),
        ],
      ),
      floatingActionButton: _showForm
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showForm = false;
                  _resetForm();
                });
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.close, color: Colors.white),
            )
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showForm = true;
                });
              },
              backgroundColor: primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: currentUser == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please login to view your records',
                    style: _subtitleStyle(color: greyColor),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Form section (collapsible)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _showForm ? null : 0,
                    child: _showForm
                        ? Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _currentDocId == null
                                            ? 'Add New Record'
                                            : 'Edit Record',
                                        style: _titleStyle(color: primaryColor),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          setState(() {
                                            _showForm = false;
                                            _resetForm();
                                          });
                                        },
                                        tooltip: 'Close form',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _typeController,
                                    decoration: InputDecoration(
                                      labelText: 'Record Type',
                                      hintText: 'e.g. Lab Result, Prescription',
                                      labelStyle:
                                          TextStyle(color: primaryColor),
                                      prefixIcon: Icon(Icons.description,
                                          color: primaryColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: greyColor.withOpacity(0.3)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: greyColor.withOpacity(0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: primaryColor, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                    ),
                                    style: _contentStyle(),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter record type';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Image upload section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: _buildImageSection(),
                                  ),

                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: (_isLoading || _isUploading)
                                          ? null
                                          : _addRecord,
                                      child: (_isLoading || _isUploading)
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              _currentDocId == null
                                                  ? 'Save Record'
                                                  : 'Update Record',
                                              style: _buttonStyle(
                                                  color: Colors.white),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // List of records
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('medicalRecords')
                          .where('patientId', isEqualTo: currentUser.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Something went wrong',
                                    style: _subtitleStyle(),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    snapshot.error.toString(),
                                    style: _contentStyle(),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  size: 72,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No records found',
                                  style: _subtitleStyle(color: greyColor),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your medical records will appear here',
                                  style: _contentStyle(),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showForm = true;
                                    });
                                  },
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    'Add Your First Record',
                                    style: _buttonStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs;

                        // Sort docs manually by timestamp
                        docs.sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;

                          final aTimestamp = aData['createdAt'] as Timestamp?;
                          final bTimestamp = bData['createdAt'] as Timestamp?;

                          if (aTimestamp == null) return 1;
                          if (bTimestamp == null) return -1;

                          return bTimestamp.compareTo(aTimestamp);
                        });

                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 8,
                            bottom: 16,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data() as Map<String, dynamic>;

                              final timestamp = data['createdAt'] as Timestamp?;
                              final date = timestamp != null
                                  ? DateFormat('MMM d, yyyy • h:mm a')
                                      .format(timestamp.toDate())
                                  : 'Date unavailable';

                              final fileUrl = data['fileUrl'] as String?;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.08),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image preview
                                    if (fileUrl != null)
                                      Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          color: Colors.grey[200],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          child: Image.memory(
                                            base64Decode(fileUrl),
                                            fit: BoxFit.fitHeight,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.broken_image,
                                                    size: 48,
                                                    color: Colors.grey[500],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Could not load image',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  data['type'] ??
                                                      'Unknown Type',
                                                  style: _subtitleStyle(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: primaryColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.medical_information,
                                                      size: 16,
                                                      color: primaryColor,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Medical',
                                                      style: _contentStyle(
                                                          color: primaryColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                size: 16,
                                                color: greyColor,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                date,
                                                style: _contentStyle(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          const Divider(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildActionButton(
                                                icon: Icons.visibility_outlined,
                                                label: 'View',
                                                color: Colors.blue,
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        Dialog(
                                                      insetPadding:
                                                          EdgeInsets.zero,
                                                      child: Stack(
                                                        children: [
                                                          InteractiveViewer(
                                                            panEnabled: true,
                                                            minScale: 0.5,
                                                            maxScale: 4,
                                                            child: Image.memory(
                                                              base64Decode(
                                                                  fileUrl!),
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 16,
                                                            right: 16,
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.black
                                                                      .withOpacity(
                                                                          0.5),
                                                              child: IconButton(
                                                                icon:
                                                                    const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              _buildActionButton(
                                                icon: Icons.edit_outlined,
                                                label: 'Edit',
                                                color: primaryColor,
                                                onTap: () => _editRecord(doc),
                                              ),
                                              _buildActionButton(
                                                icon: Icons.delete_outline,
                                                label: 'Delete',
                                                color: Colors.red,
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: Text(
                                                        'Delete Record',
                                                        style: _titleStyle(),
                                                      ),
                                                      content: Text(
                                                        'Are you sure you want to delete this record? '
                                                        'This action cannot be undone.',
                                                        style: _contentStyle(),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: Text(
                                                            'Cancel',
                                                            style: _buttonStyle(
                                                                color:
                                                                    greyColor),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            _deleteRecord(
                                                                doc.id);
                                                          },
                                                          child: Text(
                                                            'Delete',
                                                            style: _buttonStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
