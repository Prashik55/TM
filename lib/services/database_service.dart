import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:tmapp/services/api_service.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static const int _databaseVersion = 3;

  static Database? _database;

  static Future<Database?> get database async {
    // Disable database on web platform
    if (kIsWeb) {
      print('Database operations disabled on web platform');
      return null;
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'task_manager.db');

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Projects table
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        owner_id INTEGER NOT NULL,
        status_id INTEGER NOT NULL,
        deadline TEXT,
        ticket_prefix TEXT,
        cover TEXT,
        status_type TEXT,
        type TEXT,
        start_date TEXT,
        end_date TEXT,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    // Tickets table
    await db.execute('''
      CREATE TABLE tickets (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        content TEXT,
        owner_id INTEGER NOT NULL,
        status_id INTEGER NOT NULL,
        project_id INTEGER NOT NULL,
        code TEXT NOT NULL,
        ticket_order INTEGER NOT NULL,
        type_id INTEGER NOT NULL,
        priority_id INTEGER NOT NULL,
        estimation INTEGER,
        deadline TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    // Offline actions table
    await db.execute('''
      CREATE TABLE offline_actions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        table_name TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Dashboard data table
    await db.execute('''
      CREATE TABLE dashboard_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add dashboard_data table for version 2
      await db.execute('''
        CREATE TABLE dashboard_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          data TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Add missing columns to projects table for version 3
      try {
        await db.execute('ALTER TABLE projects ADD COLUMN cover TEXT');
      } catch (e) {
        // Column might already exist
        print('Cover column might already exist: $e');
      }
      
      try {
        await db.execute('ALTER TABLE projects ADD COLUMN status_type TEXT');
      } catch (e) {
        print('Status_type column might already exist: $e');
      }
      
      try {
        await db.execute('ALTER TABLE projects ADD COLUMN type TEXT');
      } catch (e) {
        print('Type column might already exist: $e');
      }
      
      try {
        await db.execute('ALTER TABLE projects ADD COLUMN start_date TEXT');
      } catch (e) {
        print('Start_date column might already exist: $e');
      }
      
      try {
        await db.execute('ALTER TABLE projects ADD COLUMN end_date TEXT');
      } catch (e) {
        print('End_date column might already exist: $e');
      }
      
      try {
        await db.execute('ALTER TABLE projects ADD COLUMN deleted_at TEXT');
      } catch (e) {
        print('Deleted_at column might already exist: $e');
      }
    }
  }

  // User operations
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    if (db == null) return []; // Return empty list on web
    
    return await db.query('users');
  }

  static Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    if (db == null) return null; // Return null on web
    
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<void> deleteUser(int id) async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Project operations
  static Future<void> saveProject(Map<String, dynamic> project) async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    await db.insert(
      'projects',
      project,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getProjects() async {
    final db = await database;
    if (db == null) return []; // Return empty list on web
    
    return await db.query('projects');
  }

  static Future<Map<String, dynamic>?> getProject(int id) async {
    final db = await database;
    if (db == null) return null; // Return null on web
    
    final results = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<void> updateProject(int id, Map<String, dynamic> data) async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    await db.update(
      'projects',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteProject(int id) async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    await db.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ticket operations
  static Future<void> saveTicket(Map<String, dynamic> ticketData) async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    // Convert 'order' to 'ticket_order' for local database
    final localData = Map<String, dynamic>.from(ticketData);
    if (localData.containsKey('order')) {
      localData['ticket_order'] = localData['order'];
      localData.remove('order');
    }
    
    await db.insert(
      'tickets',
      localData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getTickets() async {
    final db = await database;
    if (db == null) return []; // Return empty list on web
    
    final List<Map<String, dynamic>> results = await db.query('tickets');
    
    // Convert 'ticket_order' back to 'order' for consistency
    return results.map((row) {
      final converted = Map<String, dynamic>.from(row);
      if (converted.containsKey('ticket_order')) {
        converted['order'] = converted['ticket_order'];
        converted.remove('ticket_order');
      }
      return converted;
    }).toList();
  }

  static Future<Map<String, dynamic>?> getTicket(int id) async {
    final db = await database;
    if (db == null) return null; // Return null on web
    
    final results = await db.query(
      'tickets',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<void> updateTicket(int id, Map<String, dynamic> data) async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    await db.update(
      'tickets',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteTicket(int id) async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    await db.delete(
      'tickets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Dashboard operations
  static Future<void> saveDashboardData(Map<String, dynamic> data) async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    await db.insert(
      'dashboard_data',
      {
        'data': jsonEncode(data),
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<Map<String, dynamic>?> getDashboardData() async {
    final db = await database;
    if (db == null) return null; // Return null on web
    
    final List<Map<String, dynamic>> results = await db.query(
      'dashboard_data',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    
    if (results.isNotEmpty) {
      return jsonDecode(results.first['data']);
    }
    return null;
  }

  // Offline actions
  static Future<void> saveOfflineAction(String action, String tableName, Map<String, dynamic> data) async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    await db.insert(
      'offline_actions',
      {
        'action': action,
        'table_name': tableName,
        'data': jsonEncode(data),
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getOfflineActions() async {
    final db = await database;
    if (db == null) return []; // Return empty list on web
    
    return await db.query('offline_actions', orderBy: 'created_at ASC');
  }

  static Future<void> deleteOfflineAction(int id) async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    await db.delete(
      'offline_actions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sync data with server
  static Future<void> syncData() async {
    try {
      final actions = await getOfflineActions();
      
      for (final action in actions) {
        final actionType = action['action'];
        final tableName = action['table_name'];
        final data = jsonDecode(action['data']);
        
        try {
          switch (actionType) {
            case 'create':
              await _processCreateAction(tableName, data);
              break;
            case 'update':
              await _processUpdateAction(tableName, data);
              break;
            case 'delete':
              await _processDeleteAction(tableName, data);
              break;
          }
          
          // Remove the action after successful sync
          await deleteOfflineAction(action['id']);
        } catch (e) {
          print('Error syncing action $actionType for $tableName: $e');
        }
      }
    } catch (e) {
      print('Error syncing data: $e');
    }
  }

  static Future<void> _processCreateAction(String tableName, Map<String, dynamic> data) async {
    switch (tableName) {
      case 'projects':
        await ApiService.createProject(data);
        break;
      case 'tickets':
        await ApiService.createTicket(data);
        break;
    }
  }

  static Future<void> _processUpdateAction(String tableName, Map<String, dynamic> data) async {
    final id = data['id'];
    switch (tableName) {
      case 'projects':
        await ApiService.updateProject(id, data);
        break;
      case 'tickets':
        await ApiService.updateTicket(id, data);
        break;
    }
  }

  static Future<void> _processDeleteAction(String tableName, Map<String, dynamic> data) async {
    final id = data['id'];
    switch (tableName) {
      case 'projects':
        await ApiService.deleteProject(id);
        break;
      case 'tickets':
        await ApiService.deleteTicket(id);
        break;
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final db = await database;
    if (db == null) return; // Skip on web
    
    await db.delete('users');
    await db.delete('projects');
    await db.delete('tickets');
    await db.delete('offline_actions');
    await db.delete('dashboard_data');
  }
} 