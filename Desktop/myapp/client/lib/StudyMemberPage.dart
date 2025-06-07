import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'StudyDetailPage.dart';

class StudyMemberPage extends StatefulWidget {
  @override
  _StudyMemberPageState createState() => _StudyMemberPageState();
}

class _StudyMemberPageState extends State<StudyMemberPage> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _allStudies = [];
  List<Map<String, dynamic>> _joinedStudies = [];
  bool _isLoading = true;
  bool _showJoinedOnly = false;
  Set<int> _joinedStudyIds = {};
  int? _verifyingStudyId;
  final TextEditingController _attendanceCodeController =
      TextEditingController();
  Map<int, bool> _attendanceStatus = {}; // 스터디별 출석 상태 (true: 출석 완료)

  @override
  void initState() {
    super.initState();
    _loadStudies();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStudies();
  }

  @override
  void dispose() {
    _attendanceCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadStudies() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) throw Exception('사용자 정보를 찾을 수 없습니다.');

      final studies = await _apiService.getAllStudies();
      final joinedStudies = await _apiService.getJoinedStudies(userId);

      // Get attendance status for joined studies
      final Map<int, bool> currentAttendanceStatus = {};
      final Map<int, String> attendanceStatusMap = {};
      for (final study in joinedStudies) {
        try {
          // Call getAttendance for each joined study
          final attendanceList = await _apiService.getAttendance(study['id']);
          if (attendanceList.isNotEmpty) {
            // 마지막 항목은 현재 인증 세션 정보이므로 제외
            final userAttendance = attendanceList
                .where((record) => record['id'] == userId)
                .firstOrNull;
            currentAttendanceStatus[study['id']] = userAttendance != null &&
                (userAttendance['status'] == 'present' ||
                    userAttendance['status'] == 'late');
            if (userAttendance != null) {
              attendanceStatusMap[study['id']] = userAttendance['status'];
            }
          } else {
            currentAttendanceStatus[study['id']] = false;
          }
        } catch (e) {
          // If getAttendance fails (e.g., no active session), assume not attended for this session
          currentAttendanceStatus[study['id']] = false;
        }
      }

      setState(() {
        _allStudies = studies;
        _joinedStudies = joinedStudies;
        _joinedStudyIds = joinedStudies.map((s) => s['id'] as int).toSet();
        _attendanceStatus = currentAttendanceStatus;
        // Add attendance status to each study
        for (var study in _allStudies) {
          if (attendanceStatusMap.containsKey(study['id'])) {
            study['attendance_status'] = attendanceStatusMap[study['id']];
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  List<Map<String, dynamic>> get _displayStudies {
    return _showJoinedOnly ? _joinedStudies : _allStudies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('스터디 목록'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showJoinedOnly ? Icons.list : Icons.person),
            onPressed: () {
              setState(() {
                _showJoinedOnly = !_showJoinedOnly;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStudies,
              child: _displayStudies.isEmpty
                  ? Center(
                      child: Text(
                        _showJoinedOnly ? '참여 중인 스터디가 없습니다.' : '등록된 스터디가 없습니다.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _displayStudies.length,
                      itemBuilder: (context, index) {
                        final study = _displayStudies[index];
                        return _buildStudyCard(study);
                      },
                    ),
            ),
    );
  }

  Widget _buildStudyCard(Map<String, dynamic> study) {
    return FutureBuilder<String?>(
      future: SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('user_id')),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(child: ListTile(title: Text('로딩 중...')));
        }

        final userId = snapshot.data;
        final isLeader = study['leader_id'] == userId;
        final isJoined = _joinedStudyIds.contains(study['id']);
        final isAttendanceVerified = _attendanceStatus[study['id']] ?? false;
        final isVerifying = _verifyingStudyId == study['id'];

        return Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(study['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('스터디장: ${study['leader_name']}'),
                    Text('참여 인원: ${study['participant_count']}명'),
                    if (isJoined)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '참여 중',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: isLeader
                    ? Container(
                        width: 140,
                        child: ElevatedButton.icon(
                          onPressed: null,
                          icon: Icon(Icons.military_tech),
                          label: Text('스터디장'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      )
                    : isJoined
                        ? isAttendanceVerified
                            ? Chip(
                                label: Text(
                                    study['attendance_status'] == 'present'
                                        ? '출석'
                                        : '출석'),
                                backgroundColor: Colors.red,
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                              )
                            : Container(
                                width: 200,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _verifyingStudyId =
                                          isVerifying ? null : study['id'];
                                      if (!isVerifying) {
                                        _attendanceCodeController.clear();
                                      }
                                    });
                                  },
                                  icon: Icon(Icons.check_circle_outline),
                                  label: Text(isVerifying ? '닫기' : '출석 인증'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              )
                        : ElevatedButton(
                            onPressed: () => _joinStudy(study['id']),
                            child: const Text('참가하기'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudyDetailPage(
                        study: study,
                        isLeader: isLeader,
                      ),
                    ),
                  ).then((_) => _loadStudies());
                },
              ),
              if (isVerifying) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '출석 인증 코드 입력',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _attendanceCodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: const InputDecoration(
                          hintText: '4자리 코드 입력',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _verifyAttendanceForStudy(study['id']),
                        child: const Text('인증하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _verifyAttendanceForStudy(int studyId) async {
    if (_attendanceCodeController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('4자리 인증 코드를 입력해주세요.')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) throw Exception('사용자 정보를 찾을 수 없습니다.');

      await _apiService.verifyAttendance(
        studyId,
        userId,
        _attendanceCodeController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('출석인증을 완료했습니다.')),
        );
        _attendanceCodeController.clear();
        setState(() {
          _attendanceStatus[studyId] = true; // 출석 상태 업데이트
          _verifyingStudyId = null; // Close the input field
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '다시 입력해주세요. (${e.toString()})'), // Show error for debugging
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _joinStudy(int studyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      await _apiService.joinStudy(studyId, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('스터디에 참여했습니다')),
        );
        await _loadStudies();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _showAttendanceVerificationDialog(int studyId) async {
    // Implementation of _showAttendanceVerificationDialog method
  }
}

class StudyDetailPage extends StatefulWidget {
  final Map<String, dynamic> study;
  final bool isLeader;

  StudyDetailPage({required this.study, required this.isLeader});

  @override
  _StudyDetailPageState createState() => _StudyDetailPageState();
}

class _StudyDetailPageState extends State<StudyDetailPage> {
  final _apiService = ApiService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudyDetails();
  }

  Future<void> _loadStudyDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final study = await _apiService.getStudyDetails(widget.study['id']);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('스터디 상세 정보'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.study['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '스터디장: ${widget.study['leader_name']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '스터디 소개',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.study['description'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '스터디 일시',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.study['schedule'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '스터디 기간',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.study['week_count']}주',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '참여자 수',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.study['participant_count']}명',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 32),
                  if (!widget.isLeader)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _joinStudy(widget.study['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('스터디 참여하기'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _joinStudy(int studyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      await _apiService.joinStudy(studyId, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('스터디에 참여했습니다')),
        );
        await _loadStudyDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
