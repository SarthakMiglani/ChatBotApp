import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_session.dart';
import '../services/local_storage_service.dart';
import 'chat_screen.dart';
import 'profile_screen.dart'; 

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({Key? key}) : super(key: key);

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  List<ChatSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _storageService.getSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  Future<void> _createNewSession() async {
    final id = await _storageService.createSession('New Chat');
    
    if (!mounted) return;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(sessionId: id),
      ),
    );

    _loadSessions();
  }

  Future<void> _confirmDelete(int sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat?'),
        content: const Text('This will permanently delete this chat and all its messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteSession(sessionId);
      _loadSessions();
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: Text(
                    'No chats yet. Start a new one!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.chat_bubble_outline, color: Colors.white),
                      ),
                      title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        DateFormat('MMM d, HH:mm').format(session.createdAt),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () => _confirmDelete(session.id!),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(sessionId: session.id!),
                          ),
                        );
                        _loadSessions();
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewSession,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}