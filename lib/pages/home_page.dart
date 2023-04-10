import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signup_login/pages/post_detail_page.dart';
import 'package:signup_login/pages/post_share_page.dart';
import 'package:signup_login/pages/profile_page.dart';
import 'package:signup_login/pages/settings.dart';

import 'add_post_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    _buildPostList(),
    PostSharePage(),
    ProfilePage(),
    SettingsPage(),
  ];
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  static Widget _buildPostList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Bir hata oluştu: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final posts = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              // post index'ine göre arka plan rengi sağlamak için bir renk listesi oluşturuyoruz
              final List<Color> colorList = [
                Colors.blue.shade100,
                Colors.yellow.shade100,
                Colors.green.shade100,
                Colors.red.shade100
              ];

              // post index'ine göre renk seçiyoruz
              final backgroundColor = colorList[index % colorList.length];

              // Gönderi resimlerini imageUrls listesinden alıyoruz
              final List<dynamic> imageUrls = post['images'];

              // Yeni eklenen kodlar
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(post['user'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Bir hata oluştu: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const SizedBox();
                  } else {
                    final user = snapshot.data!;
                    final photoUrl = user['photoUrl'];

                    return Container(
                      decoration: BoxDecoration(
                        color: backgroundColor, // arka plan rengi
                        borderRadius:
                            BorderRadius.circular(15), // kenar yarıçapı
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrls.first),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${post['text']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          CircleAvatar(
                            backgroundImage: NetworkImage(photoUrl),
                            radius: 50, // resim boyutunu ayarlayabilirsiniz
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${user['fullName']}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 147, 255),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'lib/images/logo1.png',
                fit: BoxFit.contain,
                height: 40,
              ),
            ),
            const SizedBox(width: 8.0),
            const Text('Akademi Galeri'),
          ],
        ),
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: _children.elementAt(_currentIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color.fromARGB(255, 52, 147, 255),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add Post',
            backgroundColor: Color.fromARGB(255, 67, 160, 71),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity),
            label: 'Profile',
            backgroundColor: Color.fromARGB(255, 249, 168, 37),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Color.fromARGB(255, 229, 57, 53),
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.grey[700],
        onTap: _onItemTapped,
      ),
    );
  }
}
