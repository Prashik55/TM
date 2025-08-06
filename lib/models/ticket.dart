import 'project.dart';
import 'user.dart';

class Ticket {
  final int id;
  final String name;
  final String? content;
  final int ownerId;
  final int statusId;
  final int projectId;
  final String code;
  final int order;
  final int typeId;
  final int priorityId;
  final int? estimation;
  final String? deadline;
  final String createdAt;
  final String updatedAt;
  final User? owner;
  final TicketStatus? status;
  final Project? project;
  final TicketType? type;
  final TicketPriority? priority;
  final List<User>? responsibles;
  final List<TicketAttachment>? attachments;
  final User? assignedTo; // Added this field

  Ticket({
    required this.id,
    required this.name,
    this.content,
    required this.ownerId,
    required this.statusId,
    required this.projectId,
    required this.code,
    required this.order,
    required this.typeId,
    required this.priorityId,
    this.estimation,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
    this.status,
    this.project,
    this.type,
    this.priority,
    this.responsibles,
    this.attachments,
    this.assignedTo, // Added this field
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'],
      content: json['content'],
      ownerId: json['owner_id'] is int ? json['owner_id'] : int.tryParse(json['owner_id'].toString()) ?? 0,
      statusId: json['status_id'] is int ? json['status_id'] : int.tryParse(json['status_id'].toString()) ?? 0,
      projectId: json['project_id'] is int ? json['project_id'] : int.tryParse(json['project_id'].toString()) ?? 0,
      code: json['code'],
      order: json['order'] is int ? json['order'] : int.tryParse(json['order'].toString()) ?? 0,
      typeId: json['type_id'] is int ? json['type_id'] : int.tryParse(json['type_id'].toString()) ?? 0,
      priorityId: json['priority_id'] is int ? json['priority_id'] : int.tryParse(json['priority_id'].toString()) ?? 0,
      estimation: json['estimation'] is int ? json['estimation'] : (json['estimation'] != null ? int.tryParse(json['estimation'].toString()) : null),
      deadline: json['deadline'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      status: json['status'] != null ? TicketStatus.fromJson(json['status']) : null,
      project: json['project'] != null ? Project.fromJson(json['project']) : null,
      type: json['type'] != null ? TicketType.fromJson(json['type']) : null,
      priority: json['priority'] != null ? TicketPriority.fromJson(json['priority']) : null,
      responsibles: json['responsibles'] != null 
          ? List<User>.from(json['responsibles'].map((x) => User.fromJson(x)))
          : null,
      attachments: json['attachments'] != null 
          ? List<TicketAttachment>.from(json['attachments'].map((x) => TicketAttachment.fromJson(x)))
          : null,
      assignedTo: json['assigned_to'] != null ? User.fromJson(json['assigned_to']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'owner_id': ownerId,
      'status_id': statusId,
      'project_id': projectId,
      'code': code,
      'order': order,
      'type_id': typeId,
      'priority_id': priorityId,
      'estimation': estimation,
      'deadline': deadline,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isOverdue {
    if (deadline == null) return false;
    final deadlineDate = DateTime.parse(deadline!);
    return DateTime.now().isAfter(deadlineDate);
  }

  bool get isDueSoon {
    if (deadline == null) return false;
    final deadlineDate = DateTime.parse(deadline!);
    final now = DateTime.now();
    final difference = deadlineDate.difference(now).inDays;
    return difference <= 3 && difference >= 0;
  }

  String get estimationForHumans {
    if (estimation == null) return 'Not estimated';
    final hours = estimation! ~/ 3600;
    final minutes = (estimation! % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes > 0 ? '${minutes}m' : ''}'.trim();
    }
    return '${minutes}m';
  }
}

class TicketAttachment {
  final int id;
  final String name;
  final String path;
  final int size;
  final String createdAt;
  final String updatedAt;

  TicketAttachment({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketAttachment.fromJson(Map<String, dynamic> json) {
    return TicketAttachment(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'],
      path: json['path'],
      size: json['size'] is int ? json['size'] : int.tryParse(json['size'].toString()) ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'size': size,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TicketStatus {
  final int id;
  final String name;
  final String color;
  final int? projectId;
  final String createdAt;
  final String updatedAt;

  TicketStatus({
    required this.id,
    required this.name,
    required this.color,
    this.projectId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketStatus.fromJson(Map<String, dynamic> json) {
    return TicketStatus(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'],
      color: json['color'] ?? '#000000',
      projectId: json['project_id'] is int ? json['project_id'] : (json['project_id'] != null ? int.tryParse(json['project_id'].toString()) : null),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'project_id': projectId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TicketType {
  final int id;
  final String name;
  final String color;
  final String createdAt;
  final String updatedAt;

  TicketType({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'],
      color: json['color'] ?? '#000000',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TicketPriority {
  final int id;
  final String name;
  final String color;
  final String createdAt;
  final String updatedAt;

  TicketPriority({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketPriority.fromJson(Map<String, dynamic> json) {
    return TicketPriority(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'],
      color: json['color'] ?? '#000000',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
} 