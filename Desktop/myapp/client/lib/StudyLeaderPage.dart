import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'CreateStudyPage.dart';
import 'StudyDetailPage.dart';

class StudyLeaderPage extends StatefulWidget {
  @override
  _StudyLeaderPageState createState() => _StudyLeaderPageState();
}

class _StudyLeaderPageState extends State<StudyLeaderPage> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _studies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudies();
  }

  Future<void> _loadStudies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final studies = await _apiService.getStudiesByLeader(userId);
      setState(() {
        _studies = studies;
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
        title: Text('내 스터디 관리'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStudies,
              child: _studies.isEmpty
                  ? Center(
                      child: Text(
                        '생성한 스터디가 없습니다.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _studies.length,
                      itemBuilder: (context, index) {
                        final study = _studies[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              study['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                '참여자 수: ${study['participant_count'] ?? 0}명'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudyDetailPage(
                                    study: study,
                                    isLeader: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateStudyPage()),
          ).then((_) => _loadStudies());
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class StudyManagementPage extends StatefulWidget {
  final int studyId;
  final String studyName;

  StudyManagementPage({
    required this.studyId,
    required this.studyName,
  });

  @override
  _StudyManagementPageState createState() => _StudyManagementPageState();
}

class _StudyManagementPageState extends State<StudyManagementPage> {
  final _apiService = ApiService();
  final _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _participants = [];
  Map<String, dynamic>? _study;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudyData();
  }

  Future<void> _loadStudyData() async {
    try {
      final study = await _apiService.getStudyDetails(widget.studyId);
      final participants =
          await _apiService.getStudyParticipants(widget.studyId);

      setState(() {
        _study = study;
        _descriptionController.text = study['description'];
        _participants = participants;
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

  Future<void> _updateDescription() async {
    try {
      await _apiService.updateStudyDescription(
        widget.studyId,
        _descriptionController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('스터디 설명이 수정되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _removeParticipant(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('스터디원 추방'),
        content: Text('$userName님을 스터디에서 추방하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('추방'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.removeParticipant(widget.studyId, userId);
        await _loadStudyData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('스터디원이 추방되었습니다')),
          );
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

  Future<void> _deleteStudy() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('스터디 삭제'),
        content: Text('정말로 이 스터디를 삭제하시겠습니까?\n모든 스터디원이 자동으로 탈퇴됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteStudy(widget.studyId);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('스터디가 삭제되었습니다')),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studyName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteStudy,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '스터디 설명',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '스터디 설명을 입력하세요',
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updateDescription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('설명 수정'),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '스터디원 목록',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _participants.length,
                    itemBuilder: (context, index) {
                      final participant = _participants[index];
                      final isLeader =
                          participant['id'] == _study!['leader_id'];
                      return ListTile(
                        title: Text(
                          participant['name'],
                          style: TextStyle(
                            fontWeight:
                                isLeader ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(participant['school']),
                        trailing: isLeader
                            ? Chip(
                                label: Text('스터디장'),
                                backgroundColor: Colors.blue,
                                labelStyle: TextStyle(color: Colors.white),
                              )
                            : IconButton(
                                icon: Icon(Icons.person_remove),
                                onPressed: () => _removeParticipant(
                                  participant['id'],
                                  participant['name'],
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
