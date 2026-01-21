import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final int sessionId; 

  const ChatScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final LocalStorageService _storageService = LocalStorageService();
  final GeminiService _geminiService = GeminiService();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    
    final messages = await _storageService.getMessages(widget.sessionId);
    setState(() {
      _messages = messages;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final inputText = _controller.text;

    
    if (_messages.isEmpty) {
      await _storageService.updateSessionTitle(
        widget.sessionId, 
        inputText.length > 30 ? '${inputText.substring(0, 30)}...' : inputText
      );
    }

    final userMessage = ChatMessage(
      sessionId: widget.sessionId, 
      text: inputText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    await _storageService.insertMessage(userMessage);
    _controller.clear();
    _scrollToBottom();

    final response = await _geminiService.sendMessage(userMessage.text);
    
    final botMessage = ChatMessage(
      sessionId: widget.sessionId, 
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(botMessage);
      _isLoading = false;
    });

    await _storageService.insertMessage(botMessage);
    _scrollToBottom();
  }



  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Say hello!',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(message: _messages[index]);
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}