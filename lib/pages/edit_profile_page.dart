import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  File? _profileImage;

  @override
  void initState() {
    _usernameController.text = user.displayName ?? '';
    _emailController.text = user.email ?? '';
    _bioController.text = ''; // Set initial bio value
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          _usernameController.text = doc.get('fullName') ?? '';
          _bioController.text = doc.get('bio') ?? '';
        });
      }
      
    });

    super.initState();
  }
  

  Future<void> _pickProfileImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    // Update user's display name and email
    final fullName = _usernameController.text;
    final email = _emailController.text;
    final bio = _bioController.text;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'fullName': fullName}, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'email': email}, SetOptions(merge: true));
    await user.updateEmail(_emailController.text);
    // Save bio to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'bio': bio}, SetOptions(merge: true));

    // Update user's photo URL
    String? photoUrl;
    if (_profileImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(user.uid);
      await storageRef.putFile(_profileImage!);
      photoUrl = await storageRef.getDownloadURL();
      await user.updatePhotoURL(photoUrl);
    }

    // Add photoUrl to Firestore
    if (photoUrl != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'photoUrl': photoUrl}, SetOptions(merge: true));
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    // Navigate back to profile page
    Navigator.of(context).pop();
    

    setState(() {});//sayfayı anlık yeniler!!

  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  _pickProfileImage();
                  // Replace with code to pick a new profile image
                  // and update the profile photo URL
                },
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      :const NetworkImage(
                              'https://www.w3schools.com/w3images/avatar2.png')
                          as ImageProvider<Object>,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Full name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email address';
                } else if (!value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
