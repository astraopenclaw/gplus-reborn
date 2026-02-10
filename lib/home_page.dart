import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For hashtags
import 'package:share_plus/share_plus.dart';
import 'auth_service.dart';
import 'create_post_page.dart';
import 'post_detail_page.dart';
import 'profile_page.dart';
import 'main.dart'; // For LoginPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  final _api = ApiService();
  String _userName = 'Guest';
  String _userEmail = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadPosts();
  }
  
  void _loadUser() async {
    final user = await _api.getSessionUser();
    setState(() {
      _userName = user['name']!;
      _userEmail = user['email']!;
      _userId = user['id']!;
    });
  }

  Future<void> _loadPosts() async {
    final posts = await _api.getPosts();
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }
  
  void _logout() async {
      await _api.logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDD4B39),
        title: const Text('Google+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPosts),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
                accountName: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                accountEmail: Text(_userEmail),
                currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFFDD4B39)),
                ),
                decoration: const BoxDecoration(color: Color(0xFFDD4B39)),
            ),
            ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: true,
                onTap: () => Navigator.pop(context),
            ),
            ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(userId: _userId.isEmpty ? '1' : _userId)));
                },
            ),
            const Divider(),
            ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Sign out'),
                onTap: _logout,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView.builder(
                padding: const EdgeInsets.all(4),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            radius: 20,
                            child: Text(post['author'][0]),
                          ),
                          title: Text(post['author'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(post['date'] ?? ''),
                          onTap: () {
                              if (post['authorId'] != null) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(userId: post['authorId'])));
                              }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          child: _buildRichText(post['content']),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        // Footer Buttons
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: const Color(0xFFF5F5F5),
                          child: Row(
                            children: [
                                _squareBtn(Icons.add, post['likes'] > 0 ? '+${post['likes']}' : '+1', () async {
                                    final success = await _api.likePost(post['id']);
                                    if (success) setState(() { post['likes'] = (post['likes'] ?? 0) + 1; });
                                }),
                                const SizedBox(width: 8),
                                _squareBtn(Icons.share, 'Share', () async {
                                    final user = await _api.getSessionUser();
                                    final content = "Reshared from ${post['author']}:\n\n> ${post['content']}";
                                    await _api.createPost(content);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shared to stream!')));
                                    }
                                    _loadPosts();
                                }, onLongPress: () {
                                    Share.share("${post['author']} posted: ${post['content']}\n\n(via Google+)");
                                }),
                                const Spacer(),
                                // Comment button on the right
                                InkWell(
                                  onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailPage(post: post)));
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          color: Colors.white,
                                      ),
                                      child: const Icon(Icons.comment, size: 20, color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFDD4B39),
        shape: const CircleBorder(), // Classic round FAB
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostPage()))
                .then((res) => { if(res==true) _loadPosts() });
        },
      ),
    );
  }
  
  Widget _squareBtn(IconData icon, String label, VoidCallback onTap, {VoidCallback? onLongPress}) {
      return InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFC4C4C4)),
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              child: Row(
                  children: [
                      Icon(icon, size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                  ],
              ),
          ),
      );
  }

  Widget _buildRichText(String text) {
    List<TextSpan> spans = [];
    text.splitMapJoin(
      RegExp(r"#[a-zA-Z0-9_]+"),
      onMatch: (m) {
        spans.add(TextSpan(
          text: "${m.group(0)} ",
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ));
        return "";
      },
      onNonMatch: (n) {
        spans.add(TextSpan(text: n, style: const TextStyle(color: Colors.black)));
        return "";
      },
    );
    return RichText(text: TextSpan(children: spans, style: const TextStyle(fontSize: 16)));
  }
}
