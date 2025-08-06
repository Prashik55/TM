import 'package:tmapp/models/user.dart';
import 'package:tmapp/models/ticket.dart';

class Project {
  final int id;
  final String name;
  final String? description;
  final int statusId;
  final int ownerId;
  final String? ticketPrefix;
  final String? deadline;
  final String? cover;
  final String createdAt;
  final String updatedAt;
  final User? owner;
  final ProjectStatus? status;
  final List<User>? users;
  final List<Ticket>? tickets;
  final User? assignedTo; // Added this field

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.statusId,
    required this.ownerId,
    this.ticketPrefix,
    this.deadline,
    this.cover,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
    this.status,
    this.users,
    this.tickets,
    this.assignedTo, // Added this field
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'],
      description: json['description'],
      statusId: json['status_id'] is int ? json['status_id'] : int.tryParse(json['status_id'].toString()) ?? 0,
      ownerId: json['owner_id'] is int ? json['owner_id'] : int.tryParse(json['owner_id'].toString()) ?? 0,
      ticketPrefix: json['ticket_prefix'],
      deadline: json['deadline'],
      cover: json['cover'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      status: json['status'] != null ? ProjectStatus.fromJson(json['status']) : null,
      users: json['users'] != null 
          ? List<User>.from(json['users'].map((x) => User.fromJson(x)))
          : null,
      tickets: json['tickets'] != null 
          ? List<Ticket>.from(json['tickets'].map((x) => Ticket.fromJson(x)))
          : null,
      assignedTo: json['assigned_to'] != null ? User.fromJson(json['assigned_to']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status_id': statusId,
      'owner_id': ownerId,
      'ticket_prefix': ticketPrefix,
      'deadline': deadline,
      'cover': cover,
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
    return difference <= 7 && difference >= 0;
  }
}

class ProjectStatus {
  final int id;
  final String name;
  final String color;
  final String createdAt;
  final String updatedAt;

  ProjectStatus({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectStatus.fromJson(Map<String, dynamic> json) {
    return ProjectStatus(
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