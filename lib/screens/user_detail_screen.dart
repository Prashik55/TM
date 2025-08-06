import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmapp/providers/user_provider.dart';
import 'package:tmapp/models/user.dart';

class UserDetailScreen extends StatefulWidget {
  final User? user;

  const UserDetailScreen({super.key, this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedType = 'default';
  String _selectedRole = 'user';
  bool _isEditing = false;
  bool _isAdmin = false; // This should be determined from current user's role

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _selectedType = widget.user!.type;
      _selectedRole = widget.user!.role ?? 'user';
    }
    // Check if current user is admin (this should be implemented based on your auth system)
    _isAdmin = true; // For demo purposes, set to true
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'New User' : 'User Details'),
        actions: [
          if (widget.user != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveUser();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter full name';
                      }
                      return null;
                    },
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  // Email ID
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email ID',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  // Password (only for new users or when editing)
                  if (widget.user == null || _isEditing) ...[
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: widget.user == null ? 'Password' : 'New Password (leave empty to keep current)',
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: widget.user == null ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      } : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // User Type (visible only for admin)
                  if (_isAdmin) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'User Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'default', child: Text('Default User')),
                        DropdownMenuItem(value: 'employee', child: Text('Employee')),
                        DropdownMenuItem(value: 'db', child: Text('Database Manager')),
                        DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                      ],
                      onChanged: _isEditing ? (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      } : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Role (visible)
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('User')),
                      DropdownMenuItem(value: 'moderator', child: Text('Moderator')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: _isEditing ? (value) {
                      if (value != null) {
                        setState(() => _selectedRole = value);
                      }
                    } : null,
                  ),
                  const SizedBox(height: 24),

                  // User Statistics (if viewing existing user)
                  if (widget.user != null) _buildUserStatistics(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: widget.user == null ? FloatingActionButton(
        onPressed: _saveUser,
        child: const Icon(Icons.save),
      ) : null,
    );
  }

  Widget _buildUserStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow('Created At', widget.user!.createdAt),
                const Divider(),
                _buildStatRow('Last Updated', widget.user!.updatedAt),
                const Divider(),
                _buildStatRow('User Type', widget.user!.type),
                const Divider(),
                _buildStatRow('Role', widget.user!.role ?? 'User'),
                if (widget.user!.emailVerifiedAt != null) ...[
                  const Divider(),
                  _buildStatRow('Email Verified', widget.user!.emailVerifiedAt!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'type': _selectedType,
        'role': _selectedRole,
      };

      // Only include password if it's provided
      if (_passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
      }

      final provider = context.read<UserProvider>();
      
      if (widget.user == null) {
        provider.createUser(userData);
      } else {
        provider.updateUser(widget.user!.id, userData);
      }

      if (widget.user == null) {
        Navigator.of(context).pop();
      } else {
        setState(() => _isEditing = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
} 