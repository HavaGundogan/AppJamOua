import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailPage extends StatelessWidget {
  final DocumentSnapshot post;

  const PostDetailPage({required this.post});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> imageUrls = post['images'];
    final String zipUrl = post['zip'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    imageUrls.first,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16.0),
              Text(
                post['text'],
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              IconButton(
                icon: Icon(Icons.download),
                onPressed: () async {
                  final url = post['zip'];
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
              SizedBox(width: 8.0),
              Text(
                'Download Zip File',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                ' ${post['timestamp'].toDate().toString()}',
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
