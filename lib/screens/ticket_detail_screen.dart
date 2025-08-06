import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmapp/providers/ticket_provider.dart';
import 'package:tmapp/providers/project_provider.dart';
import 'package:tmapp/providers/user_provider.dart';
import 'package:tmapp/models/ticket.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class TicketDetailScreen extends StatefulWidget {
  final Ticket? ticket;

  const TicketDetailScreen({super.key, this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  final _codeController = TextEditingController();
  DateTime? _selectedDeadline;
  String _selectedStatus = 'Backlog';
  String _selectedPriority = 'Normal';
  String _selectedType = 'Task';
  String? _selectedProjectId;
  String? _selectedOwnerId;
  List<String> _selectedResponsibleIds = [];
  final List<File> _attachments = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.ticket != null) {
      try {
        _nameController.text = widget.ticket!.name;
        _contentController.text = widget.ticket!.content ?? '';
        _codeController.text = widget.ticket!.code;
        _selectedDeadline = widget.ticket!.deadline != null 
            ? DateTime.parse(widget.ticket!.deadline!) 
            : null;
        _selectedStatus = widget.ticket!.status?.name ?? 'Backlog';
        _selectedPriority = widget.ticket!.priority?.name ?? 'Normal';
        _selectedType = widget.ticket!.type?.name ?? 'Task';
        _selectedProjectId = widget.ticket!.projectId.toString();
        _selectedOwnerId = widget.ticket!.ownerId.toString();
        if (widget.ticket!.responsibles != null) {
          _selectedResponsibleIds = widget.ticket!.responsibles!.map((r) => r.id.toString()).toList();
        }
      } catch (e) {
        print('Error initializing ticket detail screen: $e');
        // Set default values if there's an error
        _selectedStatus = 'Backlog';
        _selectedPriority = 'Normal';
        _selectedType = 'Task';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ticket == null ? 'New Ticket' : 'Ticket Details'),
        actions: [
          if (widget.ticket != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveTicket();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
        ],
      ),
      body: Consumer3<TicketProvider, ProjectProvider, UserProvider>(
        builder: (context, ticketProvider, projectProvider, userProvider, child) {
          if (widget.ticket == null) {
            return const Center(
              child: Text('No ticket data available'),
            );
          }
          
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
                  // Project Selection
                  _buildProjectDropdown(projectProvider),
                  const SizedBox(height: 16),

                  // Ticket Code
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Ticket Code (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Auto-generated if left empty',
                    ),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  // Ticket Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ticket Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ticket name';
                      }
                      return null;
                    },
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  // Status and Type Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusDropdown(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTypeDropdown(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Priority and Owner Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriorityDropdown(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOwnerDropdown(userProvider),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Deadline
                  _buildDeadlineSection(),
                  const SizedBox(height: 16),

                  // Ticket Content
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Ticket Content',
                      border: OutlineInputBorder(),
                      hintText: 'Enter content (text and emojis only)',
                    ),
                    maxLines: 4,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 24),

                  // Responsible Members
                  _buildResponsibleMembersSection(userProvider),
                  const SizedBox(height: 24),

                  // Attachments
                  _buildAttachmentsSection(),
                ],
              ),
            ),
          ),
        );
        },
      ),
      floatingActionButton: widget.ticket == null ? FloatingActionButton(
        onPressed: _saveTicket,
        child: const Icon(Icons.save),
      ) : null,
    );
  }

  Widget _buildStatusDropdown() {
    // Get all available statuses from the ticket's project or use defaults
    List<String> availableStatuses = [];
    
    if (widget.ticket?.project?.tickets != null) {
      // Extract unique status names from project tickets
      final statusSet = <String>{};
      for (final ticket in widget.ticket!.project!.tickets!) {
        if (ticket.status?.name != null) {
          statusSet.add(ticket.status!.name);
        }
      }
      availableStatuses = statusSet.toList();
    }
    
    // If no statuses found, use defaults
    if (availableStatuses.isEmpty) {
      availableStatuses = ['Todo', 'In Progress', 'Done', 'Archived'];
    }
    
    // Ensure the current status is in the list
    if (!availableStatuses.contains(_selectedStatus)) {
      availableStatuses.add(_selectedStatus);
    }
    
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      items: availableStatuses.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.toUpperCase()),
        );
      }).toList(),
      onChanged: _isEditing ? (value) {
        if (value != null) {
          setState(() => _selectedStatus = value);
        }
      } : null,
    );
  }

  Widget _buildTypeDropdown() {
    // Get all available types from the ticket's project or use defaults
    List<String> availableTypes = [];
    
    if (widget.ticket?.project?.tickets != null) {
      // Extract unique type names from project tickets
      final typeSet = <String>{};
      for (final ticket in widget.ticket!.project!.tickets!) {
        if (ticket.type?.name != null) {
          typeSet.add(ticket.type!.name);
        }
      }
      availableTypes = typeSet.toList();
    }
    
    // If no types found, use defaults
    if (availableTypes.isEmpty) {
      availableTypes = ['Task', 'Evolution', 'Bug'];
    }
    
    // Ensure the current type is in the list
    if (!availableTypes.contains(_selectedType)) {
      availableTypes.add(_selectedType);
    }
    
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(),
      ),
      items: availableTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.toUpperCase()),
        );
      }).toList(),
      onChanged: _isEditing ? (value) {
        if (value != null) {
          setState(() => _selectedType = value);
        }
      } : null,
    );
  }

  Widget _buildPriorityDropdown() {
    // Get all available priorities from the ticket's project or use defaults
    List<String> availablePriorities = [];
    
    if (widget.ticket?.project?.tickets != null) {
      // Extract unique priority names from project tickets
      final prioritySet = <String>{};
      for (final ticket in widget.ticket!.project!.tickets!) {
        if (ticket.priority?.name != null) {
          prioritySet.add(ticket.priority!.name);
        }
      }
      availablePriorities = prioritySet.toList();
    }
    
    // If no priorities found, use defaults
    if (availablePriorities.isEmpty) {
      availablePriorities = ['Low', 'Normal', 'High'];
    }
    
    // Ensure the current priority is in the list
    if (!availablePriorities.contains(_selectedPriority)) {
      availablePriorities.add(_selectedPriority);
    }
    
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
      ),
      items: availablePriorities.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Text(priority.toUpperCase()),
        );
      }).toList(),
      onChanged: _isEditing ? (value) {
        if (value != null) {
          setState(() => _selectedPriority = value);
        }
      } : null,
    );
  }

  Widget _buildProjectDropdown(ProjectProvider projectProvider) {
    return DropdownButtonFormField<String>(
      value: _selectedProjectId,
      decoration: const InputDecoration(
        labelText: 'Project',
        border: OutlineInputBorder(),
      ),
      items: projectProvider.projects.map((project) {
        return DropdownMenuItem(
          value: project.id.toString(),
          child: Text(project.name),
        );
      }).toList(),
      onChanged: _isEditing ? (value) {
        setState(() => _selectedProjectId = value);
      } : null,
    );
  }

  Widget _buildOwnerDropdown(UserProvider userProvider) {
    return DropdownButtonFormField<String>(
      value: _selectedOwnerId,
      decoration: const InputDecoration(
        labelText: 'Ticket Owner',
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

  Widget _buildDeadlineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deadline (Optional)',
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

  Widget _buildResponsibleMembersSection(UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Responsible Members',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
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
              final isSelected = _selectedResponsibleIds.contains(user.id.toString());
              
              return CheckboxListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                value: isSelected,
                onChanged: _isEditing ? (value) {
                  setState(() {
                    if (value == true) {
                      _selectedResponsibleIds.add(user.id.toString());
                    } else {
                      _selectedResponsibleIds.remove(user.id.toString());
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

  Widget _buildAttachmentsSection() {
    final existingAttachments = widget.ticket?.attachments ?? [];
    final hasNewAttachments = _attachments.isNotEmpty;
    final hasExistingAttachments = existingAttachments.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attachments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (_isEditing)
              TextButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.attach_file),
                label: const Text('Add Files'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Show existing attachments
        if (hasExistingAttachments)
          Column(
            children: [
              const Text(
                'Existing Attachments:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...existingAttachments.map((attachment) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: _getFileIcon(attachment.name),
                  title: Text(attachment.name),
                  subtitle: Text('${attachment.size} bytes'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _downloadAttachment(attachment),
                  ),
                ),
              )),
              if (hasNewAttachments) const SizedBox(height: 16),
            ],
          ),
        
        // Show new attachments
        if (hasNewAttachments)
          Column(
            children: [
              const Text(
                'New Attachments:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ..._attachments.map((file) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: _getFileIcon(file.path.split('/').last),
                  title: Text(file.path.split('/').last),
                  subtitle: Text('${file.lengthSync()} bytes'),
                  trailing: _isEditing ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeAttachment(file),
                  ) : null,
                ),
              )),
            ],
          ),
        
        // Show no attachments message
        if (!hasExistingAttachments && !hasNewAttachments)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No attachments'),
            ),
          ),
      ],
    );
  }

  Widget _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    IconData iconData;
    Color iconColor;

    switch (extension) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        iconData = Icons.image;
        iconColor = Colors.green;
        break;
      case 'txt':
        iconData = Icons.text_snippet;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.orange;
    }

    return Icon(iconData, color: iconColor);
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'gif', 'txt'],
    );

    if (result != null) {
      setState(() {
        _attachments.addAll(result.paths.map((path) => File(path!)));
      });
    }
  }

  void _removeAttachment(File file) {
    setState(() {
      _attachments.remove(file);
    });
  }

  void _downloadAttachment(TicketAttachment attachment) {
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${attachment.name}...')),
    );
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

  void _saveTicket() {
    if (_formKey.currentState!.validate()) {
      final ticketData = {
        'name': _nameController.text,
        'content': _contentController.text.isEmpty ? null : _contentController.text,
        'code': _codeController.text.isEmpty ? null : _codeController.text,
        'project_id': _selectedProjectId,
        'type': _selectedType,
        'status': _selectedStatus,
        'priority': _selectedPriority,
        'owner_id': _selectedOwnerId,
        'deadline': _selectedDeadline?.toIso8601String(),
        'responsible_ids': _selectedResponsibleIds,
        'attachments': _attachments.map((f) => f.path).toList(),
      };

      final provider = context.read<TicketProvider>();
      
      if (widget.ticket == null) {
        provider.createTicket(ticketData);
      } else {
        provider.updateTicket(widget.ticket!.id, ticketData);
      }

      if (widget.ticket == null) {
        Navigator.of(context).pop();
      } else {
        setState(() => _isEditing = false);
      }
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