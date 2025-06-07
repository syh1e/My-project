import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/api_service.dart';

class AttendanceVerificationPage extends StatefulWidget {
  final String courseId;
  final String sessionId;

  const AttendanceVerificationPage({
    Key? key,
    required this.courseId,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<AttendanceVerificationPage> createState() =>
      _AttendanceVerificationPageState();
}

class _AttendanceVerificationPageState
    extends State<AttendanceVerificationPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _attendanceCode;

  Future<void> startAttendanceSession() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result =
          await _apiService.startAttendance(int.parse(widget.courseId));

      setState(() {
        _attendanceCode = result['code'].toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> endAttendanceSession() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _apiService.endAttendance(int.parse(widget.courseId));

      setState(() {
        _attendanceCode = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('출석 인증'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_attendanceCode != null)
                Column(
                  children: [
                    const Text(
                      '출석 코드',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _attendanceCode!,
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: endAttendanceSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text(
                        '출석 종료',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: startAttendanceSession,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    '출석 인증 시작',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
