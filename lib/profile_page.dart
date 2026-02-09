import 'package:flutter/material.dart';
import 'auth_service.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _api = ApiService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final profile = await _api.getUserProfile(widget.userId);
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_profile == null) return const Scaffold(body: Center(child: Text('User not found')));

    final posts = _profile!['posts'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(_profile!['name']),
        backgroundColor: const Color(0xFFDD4B39),
      ),
      backgroundColor: const Color(0xFFE5E5E5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover & Avatar
            Container(
              height: 200,
              color: Colors.grey[800],
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(_profile!['name'][0], style: const TextStyle(fontSize: 32)),
                        ),
                        const SizedBox(width: 16),
                        Text(_profile!['name'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Posts
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Posts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...posts.map((post) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(post['content']),
                      subtitle: Text(post['date']),
                    ),
                  )),
                  if (posts.isEmpty) const Text('No posts yet.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
