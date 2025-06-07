import 'package:flutter/material.dart';
import 'services/api_service.dart';

class AttendancePage extends StatefulWidget {
  final int studyId;
  final String studyName;
  final bool isLeader;

  AttendancePage({
    required this.studyId,
    required this.studyName,
    required this.isLeader,
  });

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAttendanceRecords();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAttendanceRecords();
  }

  Future<void> _loadAttendanceRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final records = await _apiService.getAttendance(widget.studyId);
      if (mounted) {
        setState(() {
          // 마지막 항목은 현재 인증 세션 정보이므로 제외
          _attendanceRecords = records.take(records.length - 1).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.studyName} 출석 현황'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      if (widget.isLeader)
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('돌아가기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAttendanceRecords,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = _attendanceRecords[index];
                      final isPresent = record['status'] == 'present';
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            record['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(record['date'].substring(0, 10)),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isPresent ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isPresent ? '출석' : '결석',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
