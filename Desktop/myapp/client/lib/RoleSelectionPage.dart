import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'StudyLeaderPage.dart';
import 'StudyMemberPage.dart';
import 'main.dart';

class RoleSelectionPage extends StatelessWidget {
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('로그아웃'),
        content: Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // 모든 저장된 데이터 삭제

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AuthPage()),
          (route) => false, // 모든 이전 화면 제거
        );
      }
    }
  }

  Widget _buildRoleButton(
      String role, String description, VoidCallback onPressed) {
    return Container(
      width: 300,
      height: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.all(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              role == '스터디장' ? Icons.school : Icons.person,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              role,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('역할 선택'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () => _handleLogout(context),
              tooltip: '로그아웃',
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_alt,
              size: 48,
              color: Colors.black,
            ),
            SizedBox(height: 16),
            Text(
              '어떤 역할로 시작하시겠습니까?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            _buildRoleButton('스터디장', '스터디장으로 시작하기', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StudyLeaderPage()),
              );
            }),
            SizedBox(height: 20),
            _buildRoleButton('스터디원', '스터디원으로 시작하기', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StudyMemberPage()),
              );
            }),
          ],
        ),
      ),
    );
  }
}
