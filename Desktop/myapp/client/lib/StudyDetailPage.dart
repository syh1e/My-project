import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'dart:async';

class StudyDetailPage extends StatefulWidget {
  final Map<String, dynamic> study;
  final bool isLeader;

  StudyDetailPage({required this.study, required this.isLeader});

  @override
  _StudyDetailPageState createState() => _StudyDetailPageState();
}

class _StudyDetailPageState extends State<StudyDetailPage>
    with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  String? _attendanceCode;
  DateTime? _expiresAt;
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _attendanceRecords = [];
  Timer? _refreshTimer;
  bool _isAttendanceActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAttendanceData(); // 페이지 로드 시 출석 데이터 및 세션 상태 로드
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _codeController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAttendanceData(); // 앱 재개 시 데이터 새로고침
    }
  }

  Future<void> _loadAttendanceData() async {
    if (!mounted) return;

    try {
      // 기존 로딩 상태를 유지하며 데이터 로드
      // setState(() { _isLoading = true; }); // <- 여기서 전체 로딩을 걸면 깜빡임

      final result = await _apiService.getAttendance(widget.study['id']);

      if (mounted) {
        if (result != null && result.isNotEmpty) {
          // 마지막 항목이 현재 인증 세션 정보
          final sessionInfo = result.last;
          // 출석 기록만 추출
          final records = result.take(result.length - 1).toList();

          setState(() {
            _attendanceCode = sessionInfo['code']?.toString();
            _expiresAt = sessionInfo['expires_at'] != null
                ? DateTime.parse(sessionInfo['expires_at'])
                : null;
            _attendanceRecords = records.cast<Map<String, dynamic>>(); // 캐스팅 추가
            _isAttendanceActive = true;
          });
          // 세션이 활성화되어 있으면 타이머 시작
          _startRefreshTimer();
        } else {
          // 출석 데이터가 없거나 세션 정보가 없는 경우 (세션 만료/종료)
          setState(() {
            _attendanceCode = null;
            _expiresAt = null;
            // _attendanceRecords는 그대로 유지 (세션 종료 후 기록 표시 위함)
            _isAttendanceActive = false;
          });
          _refreshTimer?.cancel(); // 세션이 없으면 타이머 중지
        }
      } else {
        _refreshTimer?.cancel(); // mounted 상태가 아니면 타이머 중지
      }
    } catch (e) {
      // 에러 발생 시 상태 초기화 및 타이머 중지
      if (mounted) {
        if (!e.toString().contains('현재 진행 중인 출석 인증이 없습니다')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _attendanceCode = null;
          _expiresAt = null;
          // _attendanceRecords는 그대로 유지 (에러 발생 시점의 기록 표시 위함)
          _isAttendanceActive = false;
        });
        _refreshTimer?.cancel();
      }
    } finally {
      // setState(() { _isLoading = false; }); // <- 여기서 전체 로딩을 해제하면 깜빡임
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel(); // 기존 타이머가 있다면 취소
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadAttendanceData();
    });
  }

  Future<void> _startAttendance() async {
    if (!widget.isLeader) return; // 스터디장만 시작 가능

    try {
      setState(() {
        _isLoading = true; // 시작 버튼 로딩 표시
        _errorMessage = null; // 기존 오류 메시지 초기화
      });

      final result = await _apiService.startAttendance(widget.study['id']);

      if (mounted) {
        setState(() {
          _attendanceCode = result['code'].toString();
          _expiresAt = DateTime.parse(result['expires_at']);
          _isLoading = false; // 로딩 해제
          _isAttendanceActive = true; // 세션 시작 시 활성화
        });
        // 시작 성공 후 출석 현황 바로 로드 및 타이머 시작
        _loadAttendanceData(); // -> 이 안에서 세션 확인 후 타이머 시작
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // 로딩 해제
          _isAttendanceActive = false; // 에러 시 비활성화
          _errorMessage = e.toString(); // 오류 메시지 표시
          _attendanceCode = null;
          _expiresAt = null;
        });
        _refreshTimer?.cancel(); // 에러 발생 시 타이머 중지
      }
    }
  }

  Future<void> _endAttendanceSession() async {
    if (!widget.isLeader || _attendanceCode == null)
      return; // 스터디장이고 출석 코드가 있을 때만 종료 가능

    try {
      setState(() {
        _isLoading = true; // 종료 버튼 로딩 표시
        _errorMessage = null; // 기존 오류 메시지 초기화
      });

      await _apiService.endAttendance(widget.study['id']);

      if (mounted) {
        setState(() {
          _attendanceCode = null; // 코드 숨기기
          _expiresAt = null; // 만료 시간 초기화
          _isLoading = false; // 로딩 해제
          _isAttendanceActive = false; // 세션 비활성화
          // _attendanceRecords는 유지 (기록 표시 위함)
        });
        _refreshTimer?.cancel(); // 타이머 중지
        // 출석 기록은 유지하고, 다시 로드하여 세션 만료 상태 반영
        // _loadAttendanceData(); // -> 이 안에서 세션 만료 상태를 감지하고 기록은 유지함
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // 로딩 해제
          _errorMessage = e.toString(); // 오류 메시지 표시
        });
        // 에러 발생 시에도 타이머는 중지 상태를 유지
      }
    }
  }

  Future<void> _verifyAttendance() async {
    if (widget.isLeader) return; // 참여자만 인증 가능

    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증 코드를 입력해주세요.')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true; // 인증 버튼 로딩 표시
        _errorMessage = null; // 기존 오류 메시지 초기화
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) throw Exception('사용자 정보를 찾을 수 없습니다.');

      await _apiService.verifyAttendance(
        widget.study['id'],
        userId,
        _codeController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false; // 로딩 해제
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('출석이 확인되었습니다.')),
        );
        _codeController.clear();
        // 출석 확인 후 데이터 갱신
        _loadAttendanceData();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // 로딩 해제
          _errorMessage = e.toString(); // 오류 메시지 표시
        });
      }
    }
  }

  Future<void> _deleteStudy() async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('스터디 삭제'),
          content: const Text('정말로 이 스터디를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _apiService.deleteStudy(widget.study['id']);
        if (mounted) {
          Navigator.pop(context, true); // 스터디 목록 페이지로 돌아가기
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('스터디가 삭제되었습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatExpiryTime(DateTime? expiryTime) {
    if (expiryTime == null) return '';
    return '${expiryTime.hour.toString().padLeft(2, '0')}:${expiryTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 시 타이머 중지
        _refreshTimer?.cancel();
        return true; // 뒤로가기 허용
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.study['name'] ?? '스터디 상세'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          actions: [
            if (widget.isLeader) // 스터디장에게만 삭제 버튼 표시
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteStudy,
                tooltip: '스터디 삭제',
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '스터디 설명',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.study['description'] ?? '설명 없음'),
              const SizedBox(height: 16),
              Text(
                '스터디 일정',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.study['schedule'] ?? '일정 없음'),
              const SizedBox(height: 16),
              Text(
                '참여 인원: ${((_attendanceRecords.length) + (widget.isLeader ? 1 : 0))}명', // 리더 포함 인원 수 계산 (모든 참여자 + 리더)
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // 출석 인증 영역
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.isLeader // 스터디장인 경우
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_isLoading &&
                                _attendanceCode == null) // 출석 시작 로딩 중
                              const Center(child: CircularProgressIndicator())
                            else if (_attendanceCode ==
                                null) // 출석 시작 전 (로딩 중이 아닐 때만 버튼 표시)
                              ElevatedButton(
                                onPressed: _startAttendance,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('출석 인증 시작'),
                              )
                            else if (_attendanceCode !=
                                null) // 출석 시작 후 코드 표시 및 종료 버튼
                              Column(
                                children: [
                                  const Text(
                                    '출석 인증 코드',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _attendanceCode!,
                                    style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  if (_expiresAt != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '만료 시간: ${_formatExpiryTime(_expiresAt)}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  _isLoading // 종료 로딩 중일 때는 로딩 인디케이터 표시
                                      ? const CircularProgressIndicator()
                                      : ElevatedButton(
                                          onPressed: _endAttendanceSession,
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          child: const Text('출석 종료',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                ],
                              ),
                          ],
                        )
                      : // 참여자인 경우
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_isLoading &&
                                !_isAttendanceActive) // 참여자: 세션 로딩 중
                              const Center(child: CircularProgressIndicator())
                            else if (_isAttendanceActive) // 참여자: 세션 활성화 상태 (인증 코드 입력 필드 표시)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    '인증 코드 입력',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _codeController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: '4자리 코드 입력',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _isLoading // 인증 로딩 중일 때는 로딩 인디케이터 표시
                                      ? const CircularProgressIndicator()
                                      : ElevatedButton(
                                          onPressed: _verifyAttendance,
                                          child: const Text('출석 인증'),
                                        ),
                                ],
                              )
                            else // 참여자: 세션 비활성화 상태
                              const Center(
                                  child: Text('현재 진행 중인 출석 인증이 없습니다.')),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null) // 오류 메시지 표시
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              // 출석 현황 목록
              const Text(
                '출석 현황',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_attendanceRecords.isNotEmpty)
                ListView.builder(
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
                                ? '출석'
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
                )
              else if (!_isLoading) // 로딩 중이 아닐 때만 메시지 표시
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: Text('아직 출석 기록이 없습니다.')),
                ),
              if (_isLoading &&
                  _attendanceCode ==
                      null) // 초기 로딩 또는 시작/종료 후 로딩 중일 때만 출석 현황 아래 로딩 표시
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
