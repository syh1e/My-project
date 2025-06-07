import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://10.0.2.2:8080'; // Android emulator localhost
  // static const String baseUrl = 'http://localhost:8080'; // iOS simulator localhost

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // 로그인
  Future<Map<String, dynamic>> login(String id, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({'id': id, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'] as String?;
        if (token != null) {
          setAuthToken(token);
        }
        return data;
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '로그인에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 회원가입
  Future<void> register(
    String name,
    String id,
    String password,
    String school,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'id': id,
          'password': password,
          'school': school,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '회원가입에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // ID 중복 확인
  Future<bool> checkIdAvailability(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/check-id/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['available'] as bool;
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? 'ID 확인에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 스터디 생성
  Future<void> createStudy(
    String name,
    String description,
    String schedule,
    int weekCount,
    String leaderId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/studies'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'description': description,
          'schedule': schedule,
          'weekCount': weekCount,
          'leaderId': leaderId,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '스터디 생성에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 모든 스터디 목록 조회
  Future<List<Map<String, dynamic>>> getAllStudies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/studies'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '스터디 목록 조회에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 스터디 상세 정보 조회
  Future<Map<String, dynamic>> getStudyDetails(int studyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/studies/$studyId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '스터디 정보 조회에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 스터디 참여
  Future<void> joinStudy(int studyId, String userId) async {
    try {
      final study = await getStudyDetails(studyId);
      if (study['leader_id'] == userId) {
        throw Exception('스터디장은 자신의 스터디에 참여할 수 없습니다.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/studies/$studyId/join'),
        headers: await _getHeaders(),
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '스터디 참여에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 스터디장의 스터디 목록 조회
  Future<List<Map<String, dynamic>>> getStudiesByLeader(String leaderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/studies/leader/$leaderId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '스터디 목록 조회에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 사용자가 참여 중인 스터디 목록 조회
  Future<List<Map<String, dynamic>>> getJoinedStudies(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/studies/joined/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '참여 중인 스터디 목록 조회에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 스터디 참여자 목록 조회
  Future<List<Map<String, dynamic>>> getStudyParticipants(int studyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/studies/$studyId/participants'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '스터디 참여자 목록 조회에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 스터디 설명 수정
  Future<void> updateStudyDescription(int studyId, String description) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/studies/$studyId/description'),
        headers: await _getHeaders(),
        body: jsonEncode({'description': description}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '스터디 설명 수정에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 스터디원 추방
  Future<void> removeParticipant(int studyId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/studies/$studyId/participants/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '스터디원 추방에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 스터디 삭제
  Future<void> deleteStudy(int studyId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/studies/$studyId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '스터디 삭제에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 출석 인증 시작
  Future<Map<String, dynamic>> startAttendance(int studyId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/studies/$studyId/start-attendance'),
        headers: await _getHeaders(),
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // 서버 응답을 그대로 반환
      } else {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '출석 인증을 시작할 수 없습니다.');
      }
    } catch (e) {
      print('Error in startAttendance: $e');
      rethrow;
    }
  }

  // 출석 인증 확인
  Future<bool> verifyAttendance(int studyId, String userId, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/studies/$studyId/verify-attendance'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'user_id': userId,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        // 서버는 성공 시 {'message': '...'} 형태의 문자열 응답을 보냄
        return true; // 성공했으면 true 반환
      } else {
        // 서버는 실패 시 {'error': '...'} 형태의 응답을 보냄
        // 응답 본문이 JSON이 아닐 경우를 대비하여 안전하게 디코딩
        String errorMessage = '알 수 없는 오류가 발생했습니다.';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] as String? ?? errorMessage;
        } catch (e) {
          // 응답 본문이 JSON이 아니거나 error 필드가 없을 경우
          errorMessage = '서버 오류가 발생했습니다: ${response.statusCode}';
          if (response.body != null && response.body.isNotEmpty) {
            // 서버 응답 본문이 있다면 함께 표시
            errorMessage += ' - ${response.body}';
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error in verifyAttendance: $e');
      rethrow;
    }
  }

  // 출석 현황 조회
  Future<List<Map<String, dynamic>>> getAttendance(int studyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/studies/$studyId/attendance'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('출석 현황을 조회할 수 없습니다.');
      }
    } catch (e) {
      print('Error in getAttendance: $e');
      rethrow;
    }
  }

  // 스터디 정보 업데이트
  Future<void> updateStudy(
    int studyId,
    String name,
    String description,
    String schedule,
    int weekCount,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/studies/$studyId'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'description': description,
          'schedule': schedule,
          'week_count': weekCount,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body)['error'] as String?;
        throw Exception(error ?? '스터디 정보 수정에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('서버 연결에 실패했습니다: $e');
    }
  }

  // 출석 인증 종료
  Future<void> endAttendance(int studyId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/studies/$studyId/end-attendance'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        String errorMessage = '출석 인증을 종료할 수 없습니다.';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] as String? ?? errorMessage;
        } catch (e) {
          errorMessage = '서버 오류: ${response.statusCode}';
          if (response.body.isNotEmpty) {
            errorMessage += ' - ${response.body}';
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error in endAttendance: $e');
      rethrow;
    }
  }
}
