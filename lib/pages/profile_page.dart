import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signup_login/pages/post_detail_page.dart';

import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _fullName;
  late String _bio;
  late String _profileImageUrl;

  bool _isLoading = true;

  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      _fullName = userData['fullName'];
      _bio = userData['bio'];
      _profileImageUrl = userData['photoUrl'] ?? '';
      _isLoading = false;
    });
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Yükleme animasyonu
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage: _profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl)
                              : const AssetImage('assets/images/avatar.png')
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        _fullName ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        _bio ?? '',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 1.0, color: Colors.grey),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('user', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final posts = snapshot.data!.docs;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final post = posts[index];
                          final List<dynamic> imageUrls = post['images'];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PostDetailPage(post:post)));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: imageUrls.isNotEmpty
                                  ? Image.network(
                                      imageUrls.first,
                                      fit: BoxFit.cover,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
