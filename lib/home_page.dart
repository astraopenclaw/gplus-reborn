import 'package:flutter/material.dart';
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
        title: const Text('Home'),
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
                    // Force open even if userId is empty (for debug safety)
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(userId: _userId.isEmpty ? '1' : _userId)));
                },
            ),
            ListTile(
                leading: const Icon(Icons.bug_report),
                title: Text('Debug: ID=$_userId'),
                onTap: () {},
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
                padding: const EdgeInsets.all(8),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[300],
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(post['content'], style: const TextStyle(fontSize: 16)),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _actionBtn(
                                Icons.add, 
                                post['likes'] > 0 ? '+${post['likes']}' : '+1', 
                                () async {
                                    final success = await _api.likePost(post['id']);
                                    if (success) {
                                        setState(() {
                                            post['likes'] = (post['likes'] ?? 0) + 1;
                                        });
                                    }
                                }
                            ),
                            _actionBtn(Icons.comment, 'Comment', () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailPage(post: post)));
                            }),
                            _actionBtn(
                                Icons.share, 
                                'Share',
                                () async {
                                    // Short press: Internal Repost
                                    final user = await _api.getSessionUser();
                                    final content = "Reshared from ${post['author']}:\n\n> ${post['content']}";
                                    await _api.createPost(content);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shared to stream!')));
                                    _loadPosts();
                                },
                                onLongPress: () {
                                    // Long press: System Share
                                    Share.share("${post['author']} posted: ${post['content']}\n\n(via Google+)");
                                }
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFDD4B39),
        child: const Icon(Icons.edit),
        onPressed: () {
            // Debug: Just open it!
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostPage()))
                .then((res) => { if(res==true) _loadPosts() });
        },
      ),
    );
  }
  
  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
      return TextButton.icon(
          icon: Icon(icon, size: 18, color: Colors.grey[600]),
          label: Text(label, style: TextStyle(color: Colors.grey[600])),
          onPressed: onTap,
      );
  }
}
