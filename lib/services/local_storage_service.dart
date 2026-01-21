import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class LocalStorageService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chatbot_v2.db');
    return await openDatabase(
      path,
      version: 2, // Bumped version for migration
      onCreate: (db, version) async {
        // Create Sessions Table
        await db.execute(
          'CREATE TABLE sessions(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, createdAt INTEGER)',
        );
        // Create Messages Table with session_id
        await db.execute(
          'CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, session_id INTEGER, text TEXT, isUser INTEGER, timestamp INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // 1. Create sessions table
          await db.execute(
            'CREATE TABLE sessions(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, createdAt INTEGER)',
          );
          
          // 2. Insert a default "Legacy Chat" session for old messages
          int legacyId = await db.insert('sessions', {
            'title': 'Legacy Chat',
            'createdAt': DateTime.now().millisecondsSinceEpoch
          });

          // 3. Add session_id column to existing messages
          await db.execute('ALTER TABLE messages ADD COLUMN session_id INTEGER');
          
          // 4. Assign all old messages to the legacy session
          await db.update('messages', {'session_id': legacyId});
        }
      },
    );
  }

  // --- Session Methods ---

  Future<int> createSession(String title) async {
    final db = await database;
    final session = ChatSession(
      title: title,
      createdAt: DateTime.now(),
    );
    return await db.insert('sessions', session.toMap());
  }

  Future<List<ChatSession>> getSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      orderBy: 'createdAt DESC', // Newest first
    );
    return List.generate(maps.length, (i) {
      return ChatSession.fromMap(maps[i]);
    });
  }

  Future<void> updateSessionTitle(int sessionId, String newTitle) async {
    final db = await database;
    await db.update(
      'sessions',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> deleteSession(int sessionId) async {
    final db = await database;
    await db.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
    await db.delete('messages', where: 'session_id = ?', whereArgs: [sessionId]);
  }

  // --- Message Methods ---

  Future<void> insertMessage(ChatMessage message) async {
    final db = await database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatMessage>> getMessages(int sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) {
      return ChatMessage.fromMap(maps[i]);
    });
  }
}