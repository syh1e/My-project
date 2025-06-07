import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'dart:async';

class AttendanceSessionPage extends StatefulWidget {
  final Map<String, dynamic> study;
  final bool isLeader;

  AttendanceSessionPage({
    required this.study,
    required this.isLeader,
  });

  @override
  _AttendanceSessionPageState createState() => _AttendanceSessionPageState();
}

class _AttendanceSessionPageState extends State<AttendanceSessionPage> {
  final ApiService _apiService = ApiService();
  String? _attendanceCode;
  DateTime? _expiresAt;
  List<Map<String, dynamic>> _attendanceRecords = [];
  Timer? _refreshTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startAttendanceSession();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _startAttendanceSession() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await _apiService.startAttendance(widget.study['id']);
      print('출석 시작 응답: $result');

      if (mounted) {
        setState(() {
          _attendanceCode = result['code'].toString();
          _expiresAt = DateTime.parse(result['expires_at']);
          _isLoading = false;
        });

        _refreshTimer?.cancel();
        _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
          _loadAttendanceData();
        });

        _loadAttendanceData();
      }
    } catch (e) {
      print('출석 시작 에러: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _endAttendanceSession() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _apiService.endAttendance(widget.study['id']);

      if (mounted) {
        setState(() {
          _attendanceCode = null;
          _expiresAt = null;
          _attendanceRecords = [];
          _isLoading = false;
        });
        _refreshTimer?.cancel();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadAttendanceData() async {
    if (!mounted) return;

    try {
      final result = await _apiService.getAttendance(widget.study['id']);
      print('출석 데이터 로드 응답: $result');

      if (result.isNotEmpty) {
        final sessionInfo = result.last;
        if (mounted) {
          setState(() {
            _attendanceCode = sessionInfo['code']?.toString();
            _expiresAt = sessionInfo['expires_at'] != null
                ? DateTime.parse(sessionInfo['expires_at'])
                : null;
            _attendanceRecords = result.take(result.length - 1).toList();
          });
        }
      }
    } catch (e) {
      print('출석 데이터 로드 에러: $e');
      if (mounted) {
        if (!e.toString().contains('현재 진행 중인 출석 인증이 없습니다')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
        setState(() {
          _attendanceCode = null;
          _expiresAt = null;
          _attendanceRecords = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.study['name']} 출석'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_attendanceCode != null)
                        Column(
                          children: [
                            const Text(
                              '출석 코드',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _attendanceCode!,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_expiresAt != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '만료 시간: ${_expiresAt!.hour.toString().padLeft(2, '0')}:${_expiresAt!.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _endAttendanceSession,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                '출석 종료',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (widget.isLeader)
                        ElevatedButton(
                          onPressed:
                              _isLoading ? null : _startAttendanceSession,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: Text(
                            _isLoading ? '시작 중...' : '출석 인증 시작',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '출석 현황',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_attendanceRecords.isNotEmpty)
                Card(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = _attendanceRecords[index];
                      return ListTile(
                        title: Text(record['name'] ?? '알 수 없음'),
                        trailing: Text(
                          record['status'] == 'present'
                              ? '출석'
                              : record['status'] == 'late'
                                  ? '지각'
                                  : '결석',
                          style: TextStyle(
                            color: record['status'] == 'present'
                                ? Colors.green
                                : record['status'] == 'late'
                                    ? Colors.orange
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('출석 기록이 없습니다.'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
