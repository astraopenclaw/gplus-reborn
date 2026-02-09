import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'create_post_page.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadPosts();
  }
  
  void _loadUser() async {
    final user = await _api.getUser();
    setState(() {
      _userName = user['name']!;
      _userEmail = user['email']!;
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
        title: const Text('Home'), // Or logo
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(post['content'], style: const TextStyle(fontSize: 16)),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _actionBtn(Icons.add, '1'),
                            _actionBtn(Icons.comment, 'Comment'),
                            _actionBtn(Icons.share, 'Share'),
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
        onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostPage()));
            if (result == true) _loadPosts();
        },
      ),
    );
  }
  
  Widget _actionBtn(IconData icon, String label) {
      return TextButton.icon(
          icon: Icon(icon, size: 18, color: Colors.grey[600]),
          label: Text(label, style: TextStyle(color: Colors.grey[600])),
          onPressed: () {},
      );
  }
}
