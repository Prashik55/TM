import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmapp/providers/project_provider.dart';
import 'package:tmapp/providers/user_provider.dart';
import 'package:tmapp/providers/auth_provider.dart';
import 'package:tmapp/models/project.dart';
import 'package:tmapp/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ProjectEditScreen extends StatefulWidget {
  final Project? project; // null for create, not null for edit

  const ProjectEditScreen({super.key, this.project});

  @override
  State<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends State<ProjectEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ticketPrefixController = TextEditingController();

  DateTime? _selectedDeadline;
  User? _selectedOwner;
  int _selectedStatus = 1; // Default to active
  bool _isLoading = false;
  File? _coverImage;
  List<String> _selectedUserIds = [];

  // Status options
  final List<Map<String, dynamic>> _statusOptions = [
    {'id': 1, 'name': 'Active', 'color': Colors.green},
    {'id': 2, 'name': 'On Hold', 'color': Colors.orange},
    {'id': 3, 'name': 'Completed', 'color': Colors.blue},
    {'id': 4, 'name': 'Cancelled', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.project != null) {
      _loadProjectData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load users for owner selection
      await context.read<UserProvider>().loadUsers();

      // Set default owner to current user if creating
      if (widget.project == null) {
        final currentUser = context.read<AuthProvider>().user;
        if (currentUser != null) {
          _selectedOwner = currentUser;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadProjectData() {
    final project = widget.project!;
    _nameController.text = project.name;
    _descriptionController.text = project.description ?? '';
    _ticketPrefixController.text = project.ticketPrefix ?? '';
    _selectedStatus = project.statusId;
    _selectedDeadline = project.deadline != null ? DateTime.parse(project.deadline!) : null;

    // Find owner
    final users = context.read<UserProvider>().users;
    try {
      _selectedOwner = users.firstWhere(
        (user) => user.id == project.ownerId,
        orElse: () => users.isNotEmpty ? users.first : User(id: 0, name: '', email: '', type: '', createdAt: '', updatedAt: ''),
      );
    } catch (e) {
      print('Error finding owner: $e');
      if (users.isNotEmpty) {
        _selectedOwner = users.first;
      }
    }

    // Load existing project users
    if (project.users != null) {
      _selectedUserIds = project.users!.map((u) => u.id.toString()).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'Create Project' : 'Edit Project'),
        actions: [
          if (widget.project != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          kToolbarHeight - 32,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Project Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Project Name *',
                        hintText: 'Enter project name',
                        prefixIcon: Icon(Icons.folder),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Project name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter project description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Ticket Prefix
                    TextFormField(
                      controller: _ticketPrefixController,
                      decoration: const InputDecoration(
                        labelText: 'Ticket Prefix',
                        hintText: 'e.g., PROJ, WEB, APP',
                        prefixIcon: Icon(Icons.tag),
                      ),
                                         ),
                     const SizedBox(height: 16),

                     // Cover Image
                     _buildCoverImageSection(),
                     const SizedBox(height: 16),

                     // Project Owner
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        print('Users loaded: ${userProvider.users.length}');
                        if (userProvider.users.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Loading users...'),
                            ),
                          );
                        }
                        
                                                 print('Selected owner: ${_selectedOwner?.name} (ID: ${_selectedOwner?.id})');
                         return DropdownButtonFormField<User>(
                           value: _selectedOwner,
                           decoration: const InputDecoration(
                             labelText: 'Project Owner *',
                             prefixIcon: Icon(Icons.person),
                           ),
                           items: userProvider.users.map((user) {
                             print('Adding user to dropdown: ${user.name} (ID: ${user.id})');
                             return DropdownMenuItem(
                               value: user,
                               child: Text('${user.name} (${user.email})'),
                             );
                           }).toList(),
                          onChanged: (User? value) {
                            setState(() {
                              _selectedOwner = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a project owner';
                            }
                            return null;
                          },
                          isExpanded: true,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Project Status
                    DropdownButtonFormField<int>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status *',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem<int>(
                          value: status['id'] as int,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: status['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(status['name'] as String),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Deadline
                    InkWell(
                      onTap: () => _selectDeadline(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Deadline',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDeadline != null
                              ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                              : 'Select deadline',
                          style: TextStyle(
                            color: _selectedDeadline != null ? null : Colors.grey[600],
                          ),
                        ),
                      ),
                                         ),
                     const SizedBox(height: 16),

                     // Project Users
                     _buildUsersSection(),
                     const SizedBox(height: 16),

                                          // Action Buttons
                     Row(
                       children: [
                         Expanded(
                           child: ElevatedButton(
                             onPressed: _isLoading ? null : _saveProject,
                             child: _isLoading
                                 ? const SizedBox(
                                     width: 20,
                                     height: 20,
                                     child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                   )
                                 : Text(widget.project == null ? 'Create Project' : 'Update Project'),
                           ),
                         ),
                        if (widget.project != null) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

     Future<void> _saveProject() async {
     if (!_formKey.currentState!.validate()) return;
     if (_selectedOwner == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please select a project owner')),
       );
       return;
     }

     setState(() => _isLoading = true);

           try {
        final projectData = {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'ticket_prefix': _ticketPrefixController.text.trim(),
          'status_id': _selectedStatus,
          'owner_id': _selectedOwner!.id,
          'user_ids': _selectedUserIds,
          if (_selectedDeadline != null) 'deadline': _selectedDeadline!.toIso8601String(),
        };

        print('Saving project with data: $projectData');
        print('Selected owner: ${_selectedOwner?.name} (ID: ${_selectedOwner?.id})');
        print('Selected status: $_selectedStatus');
        print('Selected deadline: $_selectedDeadline');
        print('Selected users: $_selectedUserIds');

       final projectProvider = context.read<ProjectProvider>();
       bool success;

       if (widget.project == null) {
         success = await projectProvider.createProject(projectData);
       } else {
         success = await projectProvider.updateProject(widget.project!.id, projectData);
       }

       if (success && mounted) {
         Navigator.of(context).pop();
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(widget.project == null ? 'Project created successfully!' : 'Project updated successfully!'),
             backgroundColor: Colors.green,
           ),
         );
               } else {
          final errorMessage = projectProvider.error ?? 'Unknown error occurred';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to ${widget.project == null ? 'create' : 'update'} project: $errorMessage'),
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteProject();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject() async {
    setState(() => _isLoading = true);

    try {
      final success = await context.read<ProjectProvider>().deleteProject(widget.project!.id);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
        }
  }

  Widget _buildUsersSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        print('Users in project edit: ${userProvider.users.length}');
        
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
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedUserIds.add(user.id.toString());
                          } else {
                            _selectedUserIds.remove(user.id.toString());
                          }
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
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
           onTap: _pickImage,
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

   @override
   void dispose() {
     _nameController.dispose();
     _descriptionController.dispose();
     _ticketPrefixController.dispose();
     super.dispose();
   }
 }
