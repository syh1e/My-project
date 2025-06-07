import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:math';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database get database {
    if (_database != null) return _database!;
    _database = _initDatabase();
    return _database!;
  }

  Database _initDatabase() {
    final dbPath = join(Directory.current.path, 'study_app.db');
    final db = sqlite3.open(dbPath);

    // Create tables if they don't exist
    db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        school TEXT NOT NULL
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS studies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        schedule TEXT NOT NULL,
        week_count INTEGER NOT NULL,
        leader_id TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (leader_id) REFERENCES users(id)
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS study_participants(
        study_id INTEGER,
        user_id TEXT,
        joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (study_id, user_id),
        FOREIGN KEY (study_id) REFERENCES studies(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS attendance_verification (
        study_id INTEGER PRIMARY KEY,
        code TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        FOREIGN KEY (study_id) REFERENCES studies (id)
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        study_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (study_id) REFERENCES studies (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    return db;
  }

  void insertUser(String id, String password, String name, String school) {
    database.execute(
      'INSERT OR REPLACE INTO users (id, password, name, school) VALUES (?, ?, ?, ?)',
      [id, password, name, school],
    );
  }

  Map<String, dynamic>? getUser(String id) {
    final result = database.select(
      'SELECT * FROM users WHERE id = ?',
      [id],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  bool isIdAvailable(String id) {
    final user = getUser(id);
    return user == null;
  }

  void createStudy(String name, String description, String schedule,
      int weekCount, String leaderId) {
    database.execute(
      'INSERT INTO studies (name, description, schedule, week_count, leader_id) VALUES (?, ?, ?, ?, ?)',
      [name, description, schedule, weekCount, leaderId],
    );
  }

  List<Map<String, dynamic>> getAllStudies() {
    return database.select('''
      SELECT s.*, u.name as leader_name,
        (SELECT COUNT(*) FROM study_participants WHERE study_id = s.id) + 1 as participant_count
      FROM studies s
      JOIN users u ON s.leader_id = u.id
      ORDER BY s.created_at DESC
    ''');
  }

  Map<String, dynamic>? getStudyDetails(int studyId) {
    final result = database.select('''
      SELECT s.*, u.name as leader_name,
        (SELECT COUNT(*) FROM study_participants WHERE study_id = s.id) + 1 as participant_count
      FROM studies s
      JOIN users u ON s.leader_id = u.id
      WHERE s.id = ?
    ''', [studyId]);

    if (result.isEmpty) return null;
    return result.first;
  }

  bool isUserParticipating(int studyId, String userId) {
    final result = database.select(
      'SELECT 1 FROM study_participants WHERE study_id = ? AND user_id = ?',
      [studyId, userId],
    );
    return result.isNotEmpty;
  }

  void joinStudy(int studyId, String userId) {
    database.execute(
      'INSERT INTO study_participants (study_id, user_id) VALUES (?, ?)',
      [studyId, userId],
    );
  }

  void dispose() {
    _database?.dispose();
    _database = null;
  }

  List<Map<String, dynamic>> getStudiesByLeader(String leaderId) {
    return database.select('''
      SELECT s.*, u.name as leader_name,
        (SELECT COUNT(*) FROM study_participants WHERE study_id = s.id) + 1 as participant_count
      FROM studies s
      JOIN users u ON s.leader_id = u.id
      WHERE s.leader_id = ?
      ORDER BY s.created_at DESC
    ''', [leaderId]);
  }

  List<Map<String, dynamic>> getJoinedStudies(String userId) {
    return database.select('''
      SELECT s.*, u.name as leader_name,
        (SELECT COUNT(*) FROM study_participants WHERE study_id = s.id) + 1 as participant_count
      FROM studies s
      JOIN users u ON s.leader_id = u.id
      JOIN study_participants sp ON s.id = sp.study_id
      WHERE sp.user_id = ? AND s.leader_id != ?
      ORDER BY s.created_at DESC
    ''', [userId, userId]);
  }

  List<Map<String, dynamic>> getStudyParticipants(int studyId) {
    return database.select('''
      SELECT u.id, u.name, u.school, sp.joined_at
      FROM users u
      JOIN study_participants sp ON u.id = sp.user_id
      WHERE sp.study_id = ?
      ORDER BY sp.joined_at ASC
    ''', [studyId]);
  }

  void updateStudyDescription(int studyId, String description) {
    database.execute(
      'UPDATE studies SET description = ? WHERE id = ?',
      [description, studyId],
    );
  }

  void removeParticipant(int studyId, String userId) {
    database.execute(
      'DELETE FROM study_participants WHERE study_id = ? AND user_id = ?',
      [studyId, userId],
    );
  }

  void deleteStudy(int studyId) {
    database.execute(
        'DELETE FROM study_participants WHERE study_id = ?', [studyId]);
    database.execute('DELETE FROM studies WHERE id = ?', [studyId]);
  }

  Map<String, dynamic> startAttendance(int studyId) {
    // 4자리 랜덤 코드 생성 (1000-9999)
    final random = Random();
    final code = (1000 + random.nextInt(9000)).toString();
    final expiresAt = DateTime.now().add(const Duration(minutes: 10));
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Delete existing verification and attendance records for this study (for today)
    database.execute(
        'DELETE FROM attendance_verification WHERE study_id = ?', [studyId]);
    database.execute('DELETE FROM attendance WHERE study_id = ? AND date = ?',
        [studyId, today.toIso8601String()]);

    // Insert new attendance verification
    database.execute(
        'INSERT INTO attendance_verification (study_id, code, expires_at) VALUES (?, ?, ?)',
        [studyId, code, expiresAt.toIso8601String()]);

    // Get leader ID
    final leaderResult = database
        .select('SELECT leader_id FROM studies WHERE id = ?', [studyId]);
    final leaderId = leaderResult.isNotEmpty
        ? leaderResult.first['leader_id'] as String
        : null;

    if (leaderId != null) {
      // Get all participants excluding the leader
      final participants = database.select('''
        SELECT user_id FROM study_participants
        WHERE study_id = ? AND user_id != ?
      ''', [studyId, leaderId]);

      // Insert initial 'absent' records for participants for today
      for (final participant in participants) {
        final userId = participant['user_id'] as String;
        database.execute(
          'INSERT INTO attendance (study_id, user_id, status, date) VALUES (?, ?, ?, ?)',
          [studyId, userId, 'absent', today.toIso8601String()],
        );
      }
    }

    return {'code': code, 'expires_at': expiresAt.toIso8601String()};
  }

  bool verifyAttendance(int studyId, String userId, String code) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final verificationResult = database.select(
        'SELECT code, expires_at FROM attendance_verification WHERE study_id = ?',
        [studyId]);

    if (verificationResult.isEmpty) {
      throw Exception('인증이 시작되지 않았습니다.');
    }

    final storedCode = verificationResult.first['code'] as String;
    final expiresAt =
        DateTime.parse(verificationResult.first['expires_at'] as String);

    if (code != storedCode) {
      throw Exception('잘못된 인증 코드입니다.');
    }

    // Determine status based on expiry time
    final status = now.isAfter(expiresAt) ? 'late' : 'present';

    // Check if an attendance record exists for today and update its status
    final existingAttendance = database.select(
        'SELECT id FROM attendance WHERE study_id = ? AND user_id = ? AND date = ?',
        [studyId, userId, today.toIso8601String()]);

    if (existingAttendance.isNotEmpty) {
      // Update the existing record
      final attendanceId = existingAttendance.first['id'] as int;
      database.execute('UPDATE attendance SET status = ? WHERE id = ?',
          [status, attendanceId]);
      return true; // Return true on successful update
    } else {
      // This case should ideally not happen if startAttendance initializes correctly.
      // However, as a fallback or if leader was excluded from initial 'absent' insertion:
      // Insert a new record if none exists for today.
      database.execute(
          'INSERT INTO attendance (study_id, user_id, status, date) VALUES (?, ?, ?, ?)',
          [studyId, userId, status, today.toIso8601String()]);
      return true; // Return true on successful insert
    }
  }

  // 출석 인증 종료
  void endAttendance(int studyId) {
    database.execute(
      'DELETE FROM attendance_verification WHERE study_id = ?',
      [studyId],
    );
  }

  List<Map<String, dynamic>> getAttendance(int studyId) {
    final today = DateTime.now();
    final todayStr =
        DateTime(today.year, today.month, today.day).toIso8601String();

    // 출석 인증이 활성화되어 있는지 확인
    final verification = database.select(
        'SELECT code, expires_at FROM attendance_verification WHERE study_id = ? AND expires_at > ?',
        [studyId, today.toIso8601String()]);

    if (verification.isEmpty) {
      throw Exception('현재 진행 중인 출석 인증이 없습니다.');
    }

    // 스터디의 모든 참여자 조회 (스터디장 제외)
    final participants = database.select('''
      SELECT DISTINCT u.id, u.name
      FROM study_participants sp
      JOIN users u ON sp.user_id = u.id
      WHERE sp.study_id = ?
    ''', [studyId]);

    // 오늘 출석 또는 결석인 사람 조회
    final attendanceRecords = database.select('''
      SELECT u.id, u.name, a.status, a.date
      FROM attendance a
      JOIN users u ON a.user_id = u.id
      WHERE a.study_id = ? AND a.date = ?
    ''', [studyId, todayStr]);

    // 출석 기록을 Map으로 변환
    final attendanceMap = {
      for (var record in attendanceRecords)
        record['id'] as String: {
          'name': record['name'] as String,
          'status': record['status'] as String,
          'date': record['date'] as String
        }
    };

    // 모든 참여자의 출석 상태 생성
    final attendanceList = participants.map((participant) {
      final id = participant['id'] as String;
      if (attendanceMap.containsKey(id)) {
        return attendanceMap[id]!;
      } else {
        return {
          'name': participant['name'] as String,
          'status': 'absent',
          'date': todayStr
        };
      }
    }).toList();

    // 출석 인증 정보를 마지막에 추가
    attendanceList.add({
      'code': verification.first['code'],
      'expires_at': verification.first['expires_at']
    });

    return attendanceList;
  }
}
