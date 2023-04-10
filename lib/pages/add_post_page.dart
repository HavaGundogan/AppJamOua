import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<File> _imageFiles = [];
  File? _documentFile;
  String? _comment;

  Future<void> _pickImages() async {
    List<FilePickerResult?> result = (await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    )) as List<FilePickerResult?>;
    if (result != null) {
      setState(() {
        _imageFiles =
            result.map((file) => File(file!.files.single.path!)).toList();
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'rar'],
    );
    if (result != null) {
      setState(() {
        _documentFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImages,
                  child: const Text('Select Images'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _imageFiles
                          .map((file) => Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Image.file(
                                  file,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Document',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDocument,
              child: Container(
                height: 50,
                color: Colors.grey[300],
                child: Center(
                  child: _documentFile != null
                      ? Text(
                          'Selected: ${_documentFile?.path.split('/').last}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text(
                          'Select a Document',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Comment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _comment = value;
                });
              },
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Write your comment here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement post creation logic here
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
