import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'StudyLeaderPage.dart';
import 'StudyMemberPage.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AuthPage());
  }
}

class AuthPage extends StatefulWidget {
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool idChecked = false;
  final ApiService _apiService = ApiService();

  // Controllers for text fields
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final pwCheckController = TextEditingController();
  final schoolController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.waving_hand,
                      size: 100,
                      color: Colors.red,
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(height: 30),
                Text(
                  isLogin ? '로그인하여 시작하세요!' : '회원가입을 진행해주세요!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 30),
                if (!isLogin) ...[
                  _buildTextField(nameController, '이름'),
                  SizedBox(height: 12),
                ],
                _buildTextField(idController, '아이디'),
                SizedBox(height: 12),
                _buildTextField(pwController, '비밀번호', isPassword: true),
                SizedBox(height: 12),
                if (!isLogin) ...[
                  _buildTextField(
                    pwCheckController,
                    '비밀번호 확인',
                    isPassword: true,
                  ),
                  SizedBox(height: 12),
                  _buildTextField(schoolController, '학교'),
                  SizedBox(height: 12),
                ],
                _buildButton(
                  isLogin ? '로그인' : '회원가입',
                  isLogin ? _handleLogin : _handleSignUp,
                ),
                SizedBox(height: 20),
                _buildToggleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
  }) {
    if (label == '아이디' && !isLogin) {
      return Container(
        width: 300,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            suffixIcon: TextButton(
              onPressed: _checkIdAvailability,
              child: Text(
                '중복 확인',
                style: TextStyle(
                  color: idChecked ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Container(
      width: 300,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
          idChecked = false;
        });
      },
      child: Text(
        isLogin ? '계정이 없으신가요? 회원가입' : '이미 계정이 있으신가요? 로그인',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Future<void> _checkIdAvailability() async {
    final id = idController.text.trim();
    if (id.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(content: Text('아이디를 입력해주세요.')),
      );
      return;
    }

    try {
      final isAvailable = await _apiService.checkIdAvailability(id);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(
            isAvailable ? '사용 가능한 아이디입니다.' : '이미 사용 중인 아이디입니다.',
          ),
        ),
      );

      setState(() {
        idChecked = isAvailable;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(content: Text('ID 확인 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<void> _handleLogin() async {
    try {
      final id = idController.text.trim();
      final pw = pwController.text.trim();

      if (id.isEmpty || pw.isEmpty) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text('아이디와 비밀번호를 입력해주세요.')),
        );
        return;
      }

      final response = await _apiService.login(id, pw);

      // 로그인 성공 시 사용자 정보를 SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', id);
      await prefs.setString('user_name', response['name']);

      // 로그인 성공 시 select_roll 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => select_roll()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(content: Text('로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.')),
      );
    }
  }

  Future<void> _handleSignUp() async {
    try {
      final name = nameController.text.trim();
      final id = idController.text.trim();
      final pw = pwController.text.trim();
      final pwCheck = pwCheckController.text.trim();
      final school = schoolController.text.trim();

      if (name.isEmpty || id.isEmpty || pw.isEmpty || school.isEmpty) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text('모든 필드를 입력해주세요.')),
        );
        return;
      }

      if (pw != pwCheck) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text('비밀번호가 일치하지 않습니다.')),
        );
        return;
      }

      if (!idChecked) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text('아이디 중복 확인을 해주세요.')),
        );
        return;
      }

      await _apiService.register(name, id, pw, school);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text('회원가입이 완료되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isLogin = true;
                  idChecked = false;
                });
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(content: Text(e.toString())),
      );
    }
  }
}

class select_roll extends StatelessWidget {
  Future<void> _handleLogout(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FA),
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
              Icons.person,
              size: 200,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              '역할을 선택해주세요!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            _buildRoleButton(
              context,
              '스터디장',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudyLeaderPage()),
              ),
            ),
            SizedBox(height: 20),
            _buildRoleButton(
              context,
              '스터디원',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudyMemberPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 250,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              text == '스터디장' ? Icons.workspace_premium : Icons.menu_book,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
