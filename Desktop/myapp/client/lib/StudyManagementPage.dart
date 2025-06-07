import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class StudyManagementPage extends StatefulWidget {
  final String studyId;
  final String studyName;

  const StudyManagementPage(
      {Key? key, required this.studyId, required this.studyName})
      : super(key: key);

  @override
  _StudyManagementPageState createState() => _StudyManagementPageState();
}

class _StudyManagementPageState extends State<StudyManagementPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _scheduleController;
  late TextEditingController _weekCountController;
  List<dynamic> _participants = [];
  bool _isLoading = true;
  final _apiService = ApiService();
  Map<String, dynamic>? _studyDetails;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _scheduleController = TextEditingController();
    _weekCountController = TextEditingController();
    _loadStudyData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scheduleController.dispose();
    _weekCountController.dispose();
    super.dispose();
  }

  Future<void> _loadStudyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final study =
          await _apiService.getStudyDetails(int.parse(widget.studyId));
      final participants =
          await _apiService.getStudyParticipants(int.parse(widget.studyId));

      setState(() {
        _nameController.text = study['name'];
        _descriptionController.text = study['description'];
        _scheduleController.text = study['schedule'];
        _weekCountController.text = study['week_count'].toString();
        _participants = participants;
        _studyDetails = study;
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

  Future<void> _updateStudy() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await _apiService.updateStudy(
        int.parse(widget.studyId),
        _nameController.text,
        _descriptionController.text,
        _scheduleController.text,
        int.parse(_weekCountController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스터디 정보가 수정되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeParticipant(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('스터디원 제외'),
        content: Text('$name님을 스터디에서 제외하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _apiService.removeParticipant(
                    int.parse(widget.studyId), id);
                Navigator.pop(context);
                _loadStudyData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name님이 스터디에서 제외되었습니다.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text('제외'),
          ),
        ],
      ),
    );
  }

  void _deleteStudy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('스터디 삭제'),
        content: Text('정말로 이 스터디를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _apiService.deleteStudy(int.parse(widget.studyId));
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context, true); // 스터디 목록 페이지로 돌아가기
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('스터디가 삭제되었습니다.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text('삭제'),
          ),
        ],
      ),
    );
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '스터디 정보 수정',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '스터디 이름',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '스터디 이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: '스터디 설명',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '스터디 설명을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _scheduleController,
                      decoration: InputDecoration(
                        labelText: '스터디 일시',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '스터디 일시를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _weekCountController,
                      decoration: InputDecoration(
                        labelText: '스터디 기간 (주차)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '스터디 기간을 입력해주세요';
                        }
                        if (int.tryParse(value) == null) {
                          return '숫자만 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateStudy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text('스터디 정보 수정'),
                    ),
                    SizedBox(height: 32),
                    Text(
                      '스터디원 목록',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _participants.length,
                      itemBuilder: (context, index) {
                        final participant = _participants[index];
                        final isLeader =
                            participant['id'] == _studyDetails?['leader_id'];
                        return ListTile(
                          title: Text(
                            participant['name'],
                            style: TextStyle(
                              fontWeight: isLeader
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
            ),
    );
  }
}
