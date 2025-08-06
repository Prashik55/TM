import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmapp/providers/ticket_provider.dart';
import 'package:tmapp/providers/project_provider.dart';
import 'package:tmapp/providers/user_provider.dart';
import 'package:tmapp/providers/auth_provider.dart';
import 'package:tmapp/models/ticket.dart';
import 'package:tmapp/models/project.dart';
import 'package:tmapp/models/user.dart';

class TicketEditScreen extends StatefulWidget {
  final Ticket? ticket; // null for create, not null for edit

  const TicketEditScreen({super.key, this.ticket});

  @override
  State<TicketEditScreen> createState() => _TicketEditScreenState();
}

class _TicketEditScreenState extends State<TicketEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  final _codeController = TextEditingController();
  
  DateTime? _selectedDeadline;
  User? _selectedOwner;
  Project? _selectedProject;
  int _selectedStatus = 1; // Default to open
  int _selectedType = 1; // Default to task
  int _selectedPriority = 1; // Default to low
  int _estimation = 0;
  bool _isLoading = false;

  // Status options
  final List<Map<String, dynamic>> _statusOptions = [
    {'id': 1, 'name': 'Open', 'color': Colors.blue},
    {'id': 2, 'name': 'In Progress', 'color': Colors.orange},
    {'id': 3, 'name': 'Review', 'color': Colors.purple},
    {'id': 4, 'name': 'Completed', 'color': Colors.green},
    {'id': 5, 'name': 'Closed', 'color': Colors.grey},
  ];

  // Type options
  final List<Map<String, dynamic>> _typeOptions = [
    {'id': 1, 'name': 'Task', 'icon': Icons.task},
    {'id': 2, 'name': 'Bug', 'icon': Icons.bug_report},
    {'id': 3, 'name': 'Feature', 'icon': Icons.new_releases},
    {'id': 4, 'name': 'Improvement', 'icon': Icons.trending_up},
  ];

  // Priority options
  final List<Map<String, dynamic>> _priorityOptions = [
    {'id': 1, 'name': 'Low', 'color': Colors.green},
    {'id': 2, 'name': 'Medium', 'color': Colors.orange},
    {'id': 3, 'name': 'High', 'color': Colors.red},
    {'id': 4, 'name': 'Critical', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.ticket != null) {
      _loadTicketData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load users and projects
      await Future.wait([
        context.read<UserProvider>().loadUsers(),
        context.read<ProjectProvider>().loadProjects(),
      ]);
      
      // Set default owner to current user if creating
      if (widget.ticket == null) {
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

  void _loadTicketData() {
    final ticket = widget.ticket!;
    _nameController.text = ticket.name;
    _contentController.text = ticket.content ?? '';
    _codeController.text = ticket.code;
    _selectedStatus = ticket.statusId;
    _selectedType = ticket.typeId;
    _selectedPriority = ticket.priorityId;
    _estimation = ticket.estimation ?? 0;
    _selectedDeadline = ticket.deadline != null ? DateTime.parse(ticket.deadline!) : null;
    
    // Find owner and project
    final users = context.read<UserProvider>().users;
    final projects = context.read<ProjectProvider>().projects;
    
    _selectedOwner = users.firstWhere(
      (user) => user.id == ticket.ownerId,
      orElse: () => users.isNotEmpty ? users.first : User(id: 0, name: '', email: '', type: '', createdAt: '', updatedAt: ''),
    );
    
    _selectedProject = projects.firstWhere(
      (project) => project.id == ticket.projectId,
      orElse: () => projects.isNotEmpty ? projects.first : Project(id: 0, name: '', statusId: 1, ownerId: 0, createdAt: '', updatedAt: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ticket == null ? 'Create Ticket' : 'Edit Ticket'),
        actions: [
          if (widget.ticket != null)
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
                    // Ticket Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Ticket Name *',
                        hintText: 'Enter ticket name',
                        prefixIcon: Icon(Icons.assignment),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ticket name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Content/Description
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter ticket description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    // Ticket Code
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Ticket Code *',
                        hintText: 'e.g., PROJ-001, WEB-123',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ticket code is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Project Selection
                    Consumer<ProjectProvider>(
                      builder: (context, projectProvider, child) {
                        return DropdownButtonFormField<Project>(
                          value: _selectedProject,
                          decoration: const InputDecoration(
                            labelText: 'Project *',
                            prefixIcon: Icon(Icons.folder),
                          ),
                          items: projectProvider.projects.map((project) {
                            return DropdownMenuItem(
                              value: project,
                              child: Text('${project.name} (${project.ticketPrefix ?? 'No prefix'})'),
                            );
                          }).toList(),
                          onChanged: (Project? value) {
                            setState(() {
                              _selectedProject = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a project';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ticket Owner
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return DropdownButtonFormField<User>(
                          value: _selectedOwner,
                          decoration: const InputDecoration(
                            labelText: 'Ticket Owner *',
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: userProvider.users.map((user) {
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
                              return 'Please select a ticket owner';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ticket Status
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

                    // Ticket Type
                    DropdownButtonFormField<int>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type *',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _typeOptions.map((type) {
                        return DropdownMenuItem<int>(
                          value: type['id'] as int,
                          child: Row(
                            children: [
                              Icon(type['icon'] as IconData, size: 20),
                              const SizedBox(width: 8),
                              Text(type['name'] as String),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Priority
                    DropdownButtonFormField<int>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority *',
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: _priorityOptions.map((priority) {
                        return DropdownMenuItem<int>(
                          value: priority['id'] as int,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: priority['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(priority['name'] as String),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Estimation (hours)
                    TextFormField(
                      initialValue: _estimation.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Estimation (hours)',
                        hintText: 'Enter estimated hours',
                        prefixIcon: Icon(Icons.timer),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _estimation = int.tryParse(value) ?? 0;
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

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveTicket,
                            child: Text(widget.ticket == null ? 'Create Ticket' : 'Update Ticket'),
                          ),
                        ),
                        if (widget.ticket != null) ...[
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

  Future<void> _saveTicket() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOwner == null || _selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both owner and project')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ticketData = {
        'name': _nameController.text.trim(),
        'content': _contentController.text.trim(),
        'code': _codeController.text.trim(),
        'project_id': _selectedProject!.id,
        'owner_id': _selectedOwner!.id,
        'status_id': _selectedStatus,
        'type_id': _selectedType,
        'priority_id': _selectedPriority,
        'estimation': _estimation,
        if (_selectedDeadline != null) 'deadline': _selectedDeadline!.toIso8601String(),
      };

      final ticketProvider = context.read<TicketProvider>();
      bool success;

      if (widget.ticket == null) {
        success = await ticketProvider.createTicket(ticketData);
      } else {
        success = await ticketProvider.updateTicket(widget.ticket!.id, ticketData);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.ticket == null ? 'Ticket created successfully!' : 'Ticket updated successfully!'),
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: const Text('Are you sure you want to delete this ticket? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTicket();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTicket() async {
    setState(() => _isLoading = true);

    try {
      final success = await context.read<TicketProvider>().deleteTicket(widget.ticket!.id);
      
      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket deleted successfully!'),
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

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    _codeController.dispose();
    super.dispose();
  }
} 