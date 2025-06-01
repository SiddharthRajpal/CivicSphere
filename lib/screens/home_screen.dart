import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _titles = ['Feed', 'Report', 'Track', 'Admin'];
  bool _showOnlyMine = false;

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/report');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/track');
    } else if (index == 3) {
      Navigator.pushNamed(context, "/admin");
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _createPost(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Create a Post', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.grey[850],
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                    onPressed: () async {
                      final message = controller.text.trim();
                      if (message.isNotEmpty) {
                        await FirebaseFirestore.instance.collection('posts').add({
                          'message': message,
                          'author': FirebaseAuth.instance.currentUser!.email,
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Post'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(_titles[_currentIndex], style: const TextStyle(color: Colors.white)),
          actions: [
            if (_currentIndex == 0)
              IconButton(
                icon: Icon(_showOnlyMine ? CupertinoIcons.person_crop_circle_badge_checkmark : CupertinoIcons.person_circle, color: Colors.white),
                onPressed: () => setState(() => _showOnlyMine = !_showOnlyMine),
              ),
            IconButton(
              icon: const Icon(CupertinoIcons.power, color: Colors.white),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _currentIndex == 0 ? CommunityFeed(showOnlyMine: _showOnlyMine) : const Center(child: Text('')),
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          onPressed: () => _createPost(context),
          child: const Icon(CupertinoIcons.add),
        )
            : null,
        bottomNavigationBar: CupertinoTabBar(
          backgroundColor: Colors.black,
          activeColor: Colors.white,
          inactiveColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.house), label: 'Feed'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.plus_circle), label: 'Report'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.doc_chart), label: 'Track'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.lock_shield), label: 'Admin'),
          ],
        ),
      ),
    );
  }
}

class CommunityFeed extends StatelessWidget {
  final bool showOnlyMine;
  const CommunityFeed({super.key, required this.showOnlyMine});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final filtered = showOnlyMine ? docs.where((doc) => doc['author'] == userEmail).toList() : docs;

        if (filtered.isEmpty) {
          return const Center(child: Text('No posts yet.', style: TextStyle(color: Colors.white)));
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final data = filtered[index].data() as Map<String, dynamic>;
            final author = data['author'] ?? 'Unknown';
            final message = data['message'] ?? '';
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
            final docId = filtered[index].id;
            final isAuthor = author == userEmail;
            final isAdmin = userEmail == 'admin@gmail.com';

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: const TextStyle(fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$author\n${timestamp?.toLocal().toString().split('.')[0] ?? ''}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      if (isAuthor || isAdmin)
                        IconButton(
                          icon: const Icon(CupertinoIcons.trash, size: 18, color: Colors.redAccent),
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('replies').where('postId', isEqualTo: docId).get().then(
                                  (snapshot) {
                                for (var doc in snapshot.docs) {
                                  doc.reference.delete();
                                }
                              },
                            );
                            await FirebaseFirestore.instance.collection('posts').doc(docId).delete();
                          },
                        ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _showReplies(context, docId),
                    child: const Text('View Replies', style: TextStyle(color: Colors.blueAccent)),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReplies(BuildContext context, String postId) {
    final controller = TextEditingController();
    showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('replies')
                    .where('postId', isEqualTo: postId)
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final replies = snapshot.data!.docs;

                  if (replies.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No replies yet.', style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: replies.length,
                    itemBuilder: (context, index) {
                      final data = replies[index].data() as Map<String, dynamic>;
                      final replyTime = (data['timestamp'] as Timestamp?)?.toDate();
                      return ListTile(
                        title: Text(data['reply'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          '${data['author']} • ${replyTime?.toLocal().toString().split('.')[0] ?? ''}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      );
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Write a reply...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          fillColor: Colors.grey[850],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.paperplane, color: Colors.white),
                      onPressed: () async {
                        final reply = controller.text.trim();
                        if (reply.isNotEmpty) {
                          await FirebaseFirestore.instance.collection('replies').add({
                            'postId': postId,
                            'reply': reply,
                            'author': FirebaseAuth.instance.currentUser?.email,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          controller.clear();
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
