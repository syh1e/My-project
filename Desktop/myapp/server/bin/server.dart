import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import '../lib/database.dart';

final _dbHelper = DatabaseHelper();

// Configure routes.
final _router = Router()
  ..post('/api/auth/register', _registerHandler)
  ..post('/api/auth/login', _loginHandler)
  ..get('/api/auth/check-id/<id>', _checkIdHandler)
  ..post('/api/studies', _createStudyHandler)
  ..get('/api/studies', _getAllStudiesHandler)
  ..get('/api/studies/<id>', _getStudyDetailsHandler)
  ..post('/api/studies/<id>/join', _joinStudyHandler)
  ..get('/api/studies/leader/<leaderId>', _getStudiesByLeaderHandler)
  ..get('/api/studies/joined/<userId>', _getJoinedStudiesHandler)
  ..get('/api/studies/<id>/participants', _getStudyParticipantsHandler)
  ..put('/api/studies/<id>/description', _updateStudyDescriptionHandler)
  ..delete('/api/studies/<id>/participants/<userId>', _removeParticipantHandler)
  ..delete('/api/studies/<id>', _deleteStudyHandler)
  ..post('/api/studies/<id>/start-attendance', _startAttendanceHandler)
  ..post('/api/studies/<id>/verify-attendance', _verifyAttendanceHandler)
  ..get('/api/studies/<id>/attendance', _getAttendanceHandler)
  ..post('/api/studies/<id>/end-attendance', _endAttendanceHandler);

Future<Response> _registerHandler(Request request) async {
  try {
    final body = await request.readAsString();
    final data = json.decode(body) as Map<String, dynamic>;

    final id = data['id'] as String;
    final password = data['password'] as String;
    final name = data['name'] as String;
    final school = data['school'] as String;

    final isAvailable = _dbHelper.isIdAvailable(id);
    if (!isAvailable) {
      return Response(400, body: json.encode({'error': 'ID already exists'}));
    }

    _dbHelper.insertUser(id, password, name, school);
    return Response.ok(json.encode({'message': 'Registration successful'}));
  } catch (e) {
    return Response(400,
        body: json.encode({'error': 'Invalid request format'}));
  }
}

Future<Response> _loginHandler(Request request) async {
  try {
    final body = await request.readAsString();
    final data = json.decode(body) as Map<String, dynamic>;

    final id = data['id'] as String;
    final password = data['password'] as String;

    final user = _dbHelper.getUser(id);
    if (user == null || user['password'] != password) {
      return Response(401, body: json.encode({'error': 'Invalid credentials'}));
    }

    return Response.ok(json.encode({
      'name': user['name'],
      'school': user['school'],
    }));
  } catch (e) {
    return Response(400,
        body: json.encode({'error': 'Invalid request format'}));
  }
}

Future<Response> _checkIdHandler(Request request) async {
  final id = request.params['id'];
  if (id == null) {
    return Response(400, body: json.encode({'error': 'ID is required'}));
  }
  final isAvailable = _dbHelper.isIdAvailable(id);
  return Response.ok(json.encode({'available': isAvailable}));
}

Future<Response> _createStudyHandler(Request request) async {
  try {
    final body = await request.readAsString();
    final data = json.decode(body) as Map<String, dynamic>;

    final name = data['name'] as String;
    final description = data['description'] as String;
    final schedule = data['schedule'] as String;
    final weekCount = data['weekCount'] as int;
    final leaderId = data['leaderId'] as String;

    _dbHelper.createStudy(name, description, schedule, weekCount, leaderId);
    return Response.ok(json.encode({'message': 'Study created successfully'}));
  } catch (e) {
    return Response(400,
        body: json.encode({'error': 'Invalid request format'}));
  }
}

Future<Response> _getAllStudiesHandler(Request request) async {
  final studies = _dbHelper.getAllStudies();
  return Response.ok(json.encode(studies));
}

Future<Response> _getStudyDetailsHandler(Request request) async {
  final studyId = request.params['id'];
  if (studyId == null) {
    return Response(400, body: json.encode({'error': 'Study ID is required'}));
  }

  final study = _dbHelper.getStudyDetails(int.parse(studyId));
  if (study == null) {
    return Response(404, body: json.encode({'error': 'Study not found'}));
  }

  return Response.ok(json.encode(study));
}

Future<Response> _joinStudyHandler(Request request) async {
  try {
    final studyId = request.params['id'];
    if (studyId == null) {
      return Response(400,
          body: json.encode({'error': 'Study ID is required'}));
    }

    final body = await request.readAsString();
    final data = json.decode(body) as Map<String, dynamic>;
    final userId = data['userId'] as String;

    if (_dbHelper.isUserParticipating(int.parse(studyId), userId)) {
      return Response(400,
          body: json.encode({'error': 'Already participating in this study'}));
    }

    _dbHelper.joinStudy(int.parse(studyId), userId);
    return Response.ok(
        json.encode({'message': 'Successfully joined the study'}));
  } catch (e) {
    return Response(400,
        body: json.encode({'error': 'Invalid request format'}));
  }
}

Future<Response> _getStudiesByLeaderHandler(Request request) async {
  final leaderId = request.params['leaderId'];
  if (leaderId == null) {
    return Response(400, body: json.encode({'error': 'Leader ID is required'}));
  }

  final studies = _dbHelper.getStudiesByLeader(leaderId);
  return Response.ok(json.encode(studies));
}

Future<Response> _getJoinedStudiesHandler(Request request) async {
  final userId = request.params['userId'];
  if (userId == null) {
    return Response(400, body: json.encode({'error': 'User ID is required'}));
  }

  final studies = _dbHelper.getJoinedStudies(userId);
  return Response.ok(json.encode(studies));
}

Future<Response> _getStudyParticipantsHandler(Request request) async {
  final studyId = request.params['id'];
  if (studyId == null) {
    return Response(400, body: json.encode({'error': 'Study ID is required'}));
  }

  final participants = _dbHelper.getStudyParticipants(int.parse(studyId));
  return Response.ok(json.encode(participants));
}

Future<Response> _updateStudyDescriptionHandler(Request request) async {
  try {
    final studyId = request.params['id'];
    if (studyId == null) {
      return Response(400,
          body: json.encode({'error': 'Study ID is required'}));
    }

    final body = await request.readAsString();
    final data = json.decode(body) as Map<String, dynamic>;
    final description = data['description'] as String;

    _dbHelper.updateStudyDescription(int.parse(studyId), description);
    return Response.ok(
        json.encode({'message': 'Description updated successfully'}));
  } catch (e) {
    return Response(400,
        body: json.encode({'error': 'Invalid request format'}));
  }
}

Future<Response> _removeParticipantHandler(Request request) async {
  final studyId = request.params['id'];
  final userId = request.params['userId'];
  if (studyId == null || userId == null) {
    return Response(400,
        body: json.encode({'error': 'Study ID and User ID are required'}));
  }

  _dbHelper.removeParticipant(int.parse(studyId), userId);
  return Response.ok(
      json.encode({'message': 'Participant removed successfully'}));
}

Future<Response> _deleteStudyHandler(Request request) async {
  final studyId = request.params['id'];
  if (studyId == null) {
    return Response(400, body: json.encode({'error': 'Study ID is required'}));
  }

  _dbHelper.deleteStudy(int.parse(studyId));
  return Response.ok(json.encode({'message': 'Study deleted successfully'}));
}

Future<Response> _startAttendanceHandler(Request request) async {
  final studyId = request.params['id'];
  if (studyId == null) {
    return Response(400, body: json.encode({'error': 'Study ID is required'}));
  }

  final result = _dbHelper.startAttendance(int.parse(studyId));
  return Response.ok(json.encode({'message': result}));
}

Future<Response> _verifyAttendanceHandler(Request request) async {
  final studyId = request.params['id'];
  if (studyId == null) {
    return Response(400, body: json.encode({'error': 'Study ID is required'}));
  }

  final body = await request.readAsString();
  final data = json.decode(body) as Map<String, dynamic>;

  // Safely access fields and check for null
  final userId =
      data['user_id'] as String?; // Expecting 'user_id' with underscore
  final code = data['code'] as String?; // Expecting 'code'

  if (userId == null || code == null) {
    return Response(400,
        body: json.encode(
            {'error': 'User ID and code are required in the request body'}));
  }

  try {
    // Cast to non-nullable String after checking for null
    final result = _dbHelper.verifyAttendance(int.parse(studyId), userId, code);
    return Response.ok(json.encode({'message': result}));
  } catch (e) {
    // Handle potential errors from _dbHelper.verifyAttendance
    return Response(500, body: json.encode({'error': e.toString()}));
  }
}

Future<Response> _getAttendanceHandler(Request request) async {
  final studyId = request.params['id'];
  if (studyId == null) {
    return Response(400, body: json.encode({'error': 'Study ID is required'}));
  }

  final attendance = _dbHelper.getAttendance(int.parse(studyId));
  return Response.ok(json.encode(attendance));
}

// 출석 인증 종료 핸들러
Future<Response> _endAttendanceHandler(Request request) async {
  final studyId = request.params['id'];
  if (studyId == null) {
    return Response(400, body: json.encode({'error': 'Study ID is required'}));
  }

  try {
    // 데이터베이스 헬퍼를 사용하여 출석 세션 종료
    _dbHelper.endAttendance(int.parse(studyId));
    return Response.ok(json.encode({'message': '출석 인증이 종료되었습니다.'}));
  } catch (e) {
    print('Error in _endAttendanceHandler: ${e}');
    return Response(500,
        body: json.encode({'error': '출석 세션 종료 중 오류가 발생했습니다.'}));
  }
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests and handles CORS
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');

  // Clean up database connection when server shuts down
  ProcessSignal.sigint.watch().listen((_) {
    _dbHelper.dispose();
    exit(0);
  });
}
