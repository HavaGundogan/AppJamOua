import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:signup_login/pages/home_page.dart';

class PostSharePage extends StatefulWidget {
  @override
  _PostSharePageState createState() => _PostSharePageState();
}

class _PostSharePageState extends State<PostSharePage> {
  final FirebaseStorage storage = FirebaseStorage.instance;

  String _postText = '';
  List<File> _selectedImages = [];
  File? _selectedZip;

  void _selectImage() async {
    final pickedFiles =
        await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        if (_selectedImages.length < 10) {
          _selectedImages.addAll(
              pickedFiles.map((pickedFile) => File(pickedFile.path)));
        }
      });
    }
   
  }

  void _selectZip() async {
    final pickedFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
    setState(() {
      _selectedZip =
          pickedFile != null ? File(pickedFile.files.single.path!) : null;
    });
  
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    Navigator.pop(context);
  }

  void _sharePost() async {
    // Check if at least one photo and zip file are selected
    if (_selectedImages.isEmpty || _selectedZip == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select at least one photo and a zip file')));
      return;
    }

    // Upload files to Firebase Storage
    final List<String> imageUrls = [];
    final String zipUrl = await _uploadFileToStorage(_selectedZip!, 'zips');
    for (int i = 0; i < _selectedImages.length; i++) {
      final String imageUrl =
          await _uploadFileToStorage(_selectedImages[i], 'posts');
      imageUrls.add(imageUrl);
    }

 
    // Upload the post to Cloud Firestore
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('posts').add({
        'text': _postText,
        'images': imageUrls,
        'zip': zipUrl,
        'user': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Show a success message
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Post shared successfully')));
   Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    
  }

  Future<String> _uploadFileToStorage(File file, String folder) async {

    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference reference =
        storage.ref().child('$folder/$fileName');
    final UploadTask uploadTask = reference.putFile(file);
    final TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Container(
        padding:const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Projeni Paylaş, \n Akademiye İlham Ol!',
              style: TextStyle(
               
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 229, 57, 53),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: GridView.builder(
                itemCount: _selectedImages.length + 1,
                gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (index < _selectedImages.length) {
                    return Stack(
                      children: [
                        Image.file(_selectedImages[index], fit: BoxFit.cover),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: TextButton(
                                onPressed: () => _removeImage(index),
                                child:const Icon(Icons.close),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return GestureDetector(
                      onTap: _selectImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFEFEFEF),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child:const Icon(
                          Icons.add,
                          size: 48.0,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    decoration:const InputDecoration(
                      hintText: 'Neler yaptın, ne öğrendin?',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _postText = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                GestureDetector(
                  onTap: _selectZip,
                  child: Container(
                    width: 64.0,
                    height: 64.0,
                    decoration: BoxDecoration(
                      color: Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.file_copy),
                         SizedBox(height: 4.0),
                        Text('ZIP'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sharePost,
              
              child:const Text('Paylaş'),
            ),
          ],
        ),
      ),
    );
  }
}
