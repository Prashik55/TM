import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmapp/providers/user_provider.dart';
import 'package:tmapp/providers/ticket_provider.dart';
import 'package:tmapp/models/user.dart';
import 'package:tmapp/models/ticket.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Personal Chat'),
              Tab(text: 'Group Chat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPersonalChatTab(),
            _buildGroupChatTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateChatDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildPersonalChatTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userProvider.users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No users available for chat'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: userProvider.users.length,
          itemBuilder: (context, index) {
            final user = userProvider.users[index];
            return _buildUserChatTile(user);
          },
        );
      },
    );
  }

  Widget _buildGroupChatTab() {
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        if (ticketProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ticketProvider.tickets.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No tickets available for group chat'),
                Text('Create a ticket to start a group chat'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: ticketProvider.tickets.length,
          itemBuilder: (context, index) {
            final ticket = ticketProvider.tickets[index];
            return _buildTicketChatTile(ticket);
          },
        );
      },
    );
  }

  Widget _buildUserChatTile(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getUserTypeColor(user.type),
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: const Icon(Icons.chat_bubble_outline),
        onTap: () => _openPersonalChat(user),
      ),
    );
  }

  Widget _buildTicketChatTile(Ticket ticket) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(ticket.priority),
          child: Icon(
            _getTicketIcon(ticket.type),
            color: Colors.white,
          ),
        ),
        title: Text(ticket.name),
        subtitle: Text('${ticket.responsibles?.length ?? 0} members'),
        trailing: const Icon(Icons.group),
        onTap: () => _openGroupChat(ticket),
      ),
    );
  }

  Color _getUserTypeColor(String? type) {
    switch (type) {
      case 'admin':
        return Colors.red;
      case 'db':
        return Colors.purple;
      case 'employee':
        return Colors.blue;
      case 'default':
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(dynamic priority) {
    if (priority == null) return Colors.orange;
    
    switch (priority.name.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'normal':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getTicketIcon(dynamic type) {
    if (type == null) return Icons.assignment;
    
    switch (type.name.toLowerCase()) {
      case 'bug':
        return Icons.bug_report;
      case 'evolution':
        return Icons.lightbulb;
      case 'task':
        return Icons.assignment;
      default:
        return Icons.assignment;
    }
  }

  void _openPersonalChat(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalChatScreen(user: user),
      ),
    );
  }

  void _openGroupChat(Ticket ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatScreen(ticket: ticket),
      ),
    );
  }

  void _showCreateChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Personal Chat'),
              subtitle: const Text('Chat with a specific user'),
              onTap: () {
                Navigator.pop(context);
                _showUserSelectionDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Group Chat'),
              subtitle: const Text('Create a group chat with ticket members'),
              onTap: () {
                Navigator.pop(context);
                _showTicketSelectionDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUserSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return AlertDialog(
            title: const Text('Select User'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: userProvider.users.length,
                itemBuilder: (context, index) {
                  final user = userProvider.users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getUserTypeColor(user.type),
                      child: Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    onTap: () {
                      Navigator.pop(context);
                      _openPersonalChat(user);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTicketSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          return AlertDialog(
            title: const Text('Select Ticket'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ticketProvider.tickets.length,
                itemBuilder: (context, index) {
                  final ticket = ticketProvider.tickets[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getPriorityColor(ticket.priority),
                      child: Icon(
                        _getTicketIcon(ticket.type),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(ticket.name),
                    subtitle: Text('${ticket.responsibles?.length ?? 0} members'),
                    onTap: () {
                      Navigator.pop(context);
                      _openGroupChat(ticket);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PersonalChatScreen extends StatefulWidget {
  final User user;

  const PersonalChatScreen({super.key, required this.user});

  @override
  State<PersonalChatScreen> createState() => _PersonalChatScreenState();
}

class _PersonalChatScreenState extends State<PersonalChatScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Load chat history here
    _loadChatHistory();
  }

  void _loadChatHistory() {
    // TODO: Load chat history from API
    // For now, add some dummy messages
    _messages.addAll([
      ChatMessage(
        id: '1',
        senderId: '1',
        senderName: 'You',
        content: 'Hello!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isFromCurrentUser: true,
      ),
      ChatMessage(
        id: '2',
        senderId: widget.user.id.toString(),
        senderName: widget.user.name,
        content: 'Hi there! How can I help you?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        isFromCurrentUser: false,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getUserTypeColor(widget.user.type),
              child: Text(
                widget.user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user.name),
                Text(
                  widget.user.email,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: message.isFromCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: _getUserTypeColor(widget.user.type),
              child: Text(
                message.senderName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: message.isFromCurrentUser 
                    ? Colors.blue 
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isFromCurrentUser)
                    Text(
                      message.senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isFromCurrentUser ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isFromCurrentUser 
                          ? Colors.white70 
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: const Text(
                'You',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: '1', // Current user ID
      senderName: 'You',
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isFromCurrentUser: true,
    );

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();

    // TODO: Send message to API
    // Simulate response
    Future.delayed(const Duration(seconds: 1), () {
      final response = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: widget.user.id.toString(),
        senderName: widget.user.name,
        content: 'Thanks for your message!',
        timestamp: DateTime.now(),
        isFromCurrentUser: false,
      );

      setState(() {
        _messages.add(response);
      });
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getUserTypeColor(String? type) {
    switch (type) {
      case 'admin':
        return Colors.red;
      case 'db':
        return Colors.purple;
      case 'employee':
        return Colors.blue;
      case 'default':
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class GroupChatScreen extends StatefulWidget {
  final Ticket ticket;

  const GroupChatScreen({super.key, required this.ticket});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _loadChatHistory() {
    // TODO: Load chat history from API
    // For now, add some dummy messages
    _messages.addAll([
      ChatMessage(
        id: '1',
        senderId: '1',
        senderName: 'You',
        content: 'Hello team!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isFromCurrentUser: true,
      ),
      ChatMessage(
        id: '2',
        senderId: '2',
        senderName: widget.ticket.owner?.name ?? 'Team Member',
        content: 'Hi everyone!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isFromCurrentUser: false,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getPriorityColor(widget.ticket.priority),
              child: Icon(
                _getTicketIcon(widget.ticket.type),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.ticket.name),
                  Text(
                    '${widget.ticket.responsibles?.length ?? 0} members',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _showTicketInfo(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: message.isFromCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              child: Text(
                message.senderName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: message.isFromCurrentUser 
                    ? Colors.blue 
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isFromCurrentUser)
                    Text(
                      message.senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isFromCurrentUser ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isFromCurrentUser 
                          ? Colors.white70 
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: const Text(
                'You',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: '1', // Current user ID
      senderName: 'You',
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isFromCurrentUser: true,
    );

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();

    // TODO: Send message to API
  }

  void _showTicketInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.ticket.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${widget.ticket.status?.name ?? 'Unknown'}'),
            Text('Priority: ${widget.ticket.priority?.name ?? 'Unknown'}'),
            Text('Owner: ${widget.ticket.owner?.name ?? 'Unknown'}'),
            if (widget.ticket.responsibles != null) ...[
              const SizedBox(height: 8),
              const Text('Team Members:'),
              ...widget.ticket.responsibles!.map((user) => Text('• ${user.name}')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getPriorityColor(dynamic priority) {
    if (priority == null) return Colors.orange;
    
    switch (priority.name.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'normal':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getTicketIcon(dynamic type) {
    if (type == null) return Icons.assignment;
    
    switch (type.name.toLowerCase()) {
      case 'bug':
        return Icons.bug_report;
      case 'evolution':
        return Icons.lightbulb;
      case 'task':
        return Icons.assignment;
      default:
        return Icons.assignment;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isFromCurrentUser;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isFromCurrentUser,
  });
} 