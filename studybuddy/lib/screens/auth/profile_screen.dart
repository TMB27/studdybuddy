import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:studybuddy/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String? profileImageUrl;
  bool isUploadingImage = false;

  Future<DocumentSnapshot> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Pick from Gallery'),
              onTap: () async {
                final file = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 75,
                );
                Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a Photo'),
              onTap: () async {
                final file = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 75,
                );
                Navigator.pop(context, file);
              },
            ),
          ],
        ),
      ),
    );
    if (pickedFile != null) {
      setState(() {
        isUploadingImage = true;
      });
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');
      await ref.putFile(File(pickedFile.path));
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImageUrl': url,
      });
      setState(() {
        profileImageUrl = url;
        isUploadingImage = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile image updated')));
    }
  }

  void saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Profile updated')));

    setState(() {
      isEditing = false;
    });
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Language'),
        content: Text('Language change functionality coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Theme'),
        content: Text('Theme change functionality coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateStub(String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title screen coming soon!')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<DocumentSnapshot>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Logout"),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          nameController.text = data['name'] ?? '';
          phoneController.text = data['phone'] ?? '';
          profileImageUrl = data['profileImageUrl'];

          return Column(
            children: [
              // Header with avatar, name, email, phone
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 48, bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.95),
                  border: Border(
                    bottom: BorderSide(color: colorScheme.primary.withOpacity(0.08), width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        isUploadingImage
                            ? CircleAvatar(
                                radius: 48,
                                backgroundColor: colorScheme.surface,
                                child: CircularProgressIndicator(color: colorScheme.primary),
                              )
                            : CircleAvatar(
                                radius: 48,
                                backgroundColor: colorScheme.surface,
                                backgroundImage:
                                    profileImageUrl != null &&
                                        profileImageUrl!.isNotEmpty
                                    ? NetworkImage(profileImageUrl!)
                                    : AssetImage(
                                            'assets/avatar_placeholder.png',
                                          )
                                          as ImageProvider,
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: pickAndUploadImage,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: colorScheme.secondary,
                              child: Icon(Icons.edit, color: colorScheme.onSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['name'] ?? 'N/A',
                      style: textTheme.titleLarge?.copyWith(fontSize: 22, color: colorScheme.onPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data['email'] ?? 'N/A'} | ${data['phone'] ?? 'N/A'}',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Card 1: Edit profile, Orders, Language
                    Card(
                      color: theme.cardColor,
                      shape: theme.cardTheme.shape,
                      elevation: theme.cardTheme.elevation,
                      margin: theme.cardTheme.margin,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.person, color: colorScheme.primary),
                            title: Text(
                              'Edit profile information',
                              style: textTheme.bodyLarge,
                            ),
                            onTap: () {
                              setState(() {
                                isEditing = true;
                              });
                            },
                          ),
                          Divider(color: theme.dividerColor, height: 1),
                          ListTile(
                            leading: Icon(Icons.language, color: colorScheme.primary),
                            title: Text(
                              'Language',
                              style: textTheme.bodyLarge,
                            ),
                            trailing: Text(
                              'English',
                              style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold),
                            ),
                            onTap: _showLanguageDialog,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Card 2: View Purchase Notes, Theme
                    Card(
                      color: theme.cardColor,
                      shape: theme.cardTheme.shape,
                      elevation: theme.cardTheme.elevation,
                      margin: theme.cardTheme.margin,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.brightness_6,
                              color: colorScheme.primary,
                            ),
                            title: Text(
                              'Theme',
                              style: textTheme.bodyLarge,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.wb_sunny_outlined,
                                    color: !isDark ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  tooltip: 'Light Mode',
                                  onPressed: () {
                                    if (isDark) {
                                      themeModeNotifier.value = ThemeMode.light;
                                      setState(() {});
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.nightlight_round,
                                    color: isDark ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  tooltip: 'Dark Mode',
                                  onPressed: () {
                                    if (!isDark) {
                                      themeModeNotifier.value = ThemeMode.dark;
                                      setState(() {});
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Card 3: Logout
                    Card(
                      color: theme.cardColor,
                      shape: theme.cardTheme.shape,
                      elevation: theme.cardTheme.elevation,
                      margin: theme.cardTheme.margin,
                      child: ListTile(
                        leading: Icon(Icons.logout, color: colorScheme.primary),
                        title: Text(
                          'Logout',
                          style: textTheme.bodyLarge,
                        ),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 24),
                      Card(
                        color: theme.cardColor,
                        shape: theme.cardTheme.shape,
                        elevation: theme.cardTheme.elevation,
                        margin: theme.cardTheme.margin,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: "Full Name",
                                  labelStyle: textTheme.bodyMedium,
                                ),
                                style: textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: "Phone Number",
                                  labelStyle: textTheme.bodyMedium,
                                ),
                                style: textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: saveChanges,
                                    child: Text("Save"),
                                  ),
                                  const SizedBox(width: 16),
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        isEditing = false;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      "Cancel",
                                      style: textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
