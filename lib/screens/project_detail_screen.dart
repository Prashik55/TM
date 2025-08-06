import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmapp/providers/project_provider.dart';
import 'package:tmapp/providers/user_provider.dart';
import 'package:tmapp/providers/ticket_provider.dart';
import 'package:tmapp/models/project.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project? project;

  const ProjectDetailScreen({super.key, this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDeadline;
  String _selectedStatus = 'not started';
  String? _selectedOwnerId;
  File? _coverImage;
  List<String> _selectedUserIds = [];
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedDeadline = widget.project!.deadline != null 
          ? DateTime.parse(widget.project!.deadline!) 
          : null;
      _selectedStatus = widget.project!.status?.name.toLowerCase() ?? 'not started';
      _selectedOwnerId = widget.project!.owner?.id.toString();
      // Load existing project users
      if (widget.project!.users != null) {
        _selectedUserIds = widget.project!.users!.map((u) => u.id.toString()).toList();
      }
      
      // Load tickets for this project
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TicketProvider>().loadTickets(refresh: true);
        context.read<UserProvider>().loadUsers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'New Project' : 'Project Details'),
        actions: [
          if (widget.project != null)
            IconButton(
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _isLoading ? null : () {
                if (_isEditing) {
                  _saveProject();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
        ],
      ),
      body: Consumer3<ProjectProvider, UserProvider, TicketProvider>(
        builder: (context, projectProvider, userProvider, ticketProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    kToolbarHeight - 32,
              ),
              child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Image
                  _buildCoverImageSection(),
                  const SizedBox(height: 24),

                  // Project Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Project Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter project name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Deadline
                  _buildDeadlineSection(),
                  const SizedBox(height: 16),

                  // Project Owner
                  _buildOwnerDropdown(userProvider),
                  const SizedBox(height: 16),

                  // Project Status
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Project Status',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'not started', child: Text('NOT STARTED')),
                      DropdownMenuItem(value: 'planning', child: Text('PLANNING')),
                      DropdownMenuItem(value: 'in progress', child: Text('IN PROGRESS')),
                      DropdownMenuItem(value: 'completed', child: Text('COMPLETED')),
                      DropdownMenuItem(value: 'on hold', child: Text('ON HOLD')),
                    ],
                    onChanged: _isEditing ? (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    } : null,
                  ),
                  const SizedBox(height: 16),

                  // Project Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Project Description',
                      border: OutlineInputBorder(),
                      hintText: 'Enter description (text and emojis only)',
                    ),
                    maxLines: 3,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 24),

                  // Project Users
                  _buildUsersSection(userProvider),
                  const SizedBox(height: 24),

                  // Ticket List
                  if (widget.project != null) _buildTicketList(projectProvider, ticketProvider),
                ],
              ),
            ),
          ),
        );
        },
      ),
      floatingActionButton: widget.project == null ? FloatingActionButton(
        onPressed: _saveProject,
        child: const Icon(Icons.save),
      ) : null,
    );
  }

  Widget _buildCoverImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cover Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isEditing ? _pickImage : null,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
                         child: _coverImage != null
                 ? ClipRRect(
                     borderRadius: BorderRadius.circular(8),
                     child: kIsWeb 
                         ? const Icon(Icons.image, size: 50, color: Colors.grey)
                         : Image.file(_coverImage!, fit: BoxFit.cover),
                   )
                 : const Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deadline',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: Text(_selectedDeadline == null
              ? 'No deadline set'
              : _formatDate(_selectedDeadline!)),
          trailing: _isEditing ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
              if (_selectedDeadline != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _selectedDeadline = null),
                ),
            ],
          ) : null,
        ),
      ],
    );
  }

  Widget _buildOwnerDropdown(UserProvider userProvider) {
    return DropdownButtonFormField<String>(
      value: _selectedOwnerId,
      decoration: const InputDecoration(
        labelText: 'Project Owner',
        border: OutlineInputBorder(),
      ),
      items: userProvider.users.map((user) {
        return DropdownMenuItem(
          value: user.id.toString(),
          child: Text(user.name),
        );
      }).toList(),
      onChanged: _isEditing ? (value) {
        setState(() => _selectedOwnerId = value);
      } : null,
    );
  }

  Widget _buildUsersSection(UserProvider userProvider) {
    print('Users in project detail: ${userProvider.users.length}');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Users',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (userProvider.users.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Loading users...'),
            ),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: userProvider.users.length,
              itemBuilder: (context, index) {
                final user = userProvider.users[index];
                final isSelected = _selectedUserIds.contains(user.id.toString());
                
                return CheckboxListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  value: isSelected,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      if (value == true) {
                        _selectedUserIds.add(user.id.toString());
                      } else {
                        _selectedUserIds.remove(user.id.toString());
                      }
                    });
                  } : null,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTicketList(ProjectProvider projectProvider, TicketProvider ticketProvider) {
    final projectTickets = ticketProvider.tickets
        .where((ticket) => ticket.projectId == widget.project!.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tickets',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (projectTickets.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No tickets found for this project'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projectTickets.length,
            itemBuilder: (context, index) {
              final ticket = projectTickets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(ticket.name),
                  subtitle: Text(ticket.status?.name ?? 'No Status'),
                  trailing: Chip(
                    label: Text(ticket.priority?.name ?? 'No Priority'),
                    backgroundColor: _getPriorityColor(ticket.priority),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Color _getPriorityColor(dynamic priority) {
    if (priority == null) return Colors.grey;
    
    switch (priority.name.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'normal':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload is not supported on web')),
      );
      return;
    }
    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _coverImage = File(image.path);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() => _selectedDeadline = picked);
    }
  }

  void _saveProject() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final projectData = {
          'name': _nameController.text,
          'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
          'status': _selectedStatus,
          'owner_id': _selectedOwnerId,
          'deadline': _selectedDeadline?.toIso8601String(),
          'user_ids': _selectedUserIds,
        };

        print('Saving project with data: $projectData');

        final provider = context.read<ProjectProvider>();
        bool success;
        
        if (widget.project == null) {
          success = await provider.createProject(projectData);
        } else {
          success = await provider.updateProject(widget.project!.id, projectData);
        }

        if (success && mounted) {
          if (widget.project == null) {
            Navigator.of(context).pop();
          } else {
            setState(() => _isEditing = false);
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.project == null ? 'Project created successfully!' : 'Project updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to ${widget.project == null ? 'create' : 'update'} project. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error saving project: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 