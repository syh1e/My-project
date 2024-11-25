import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(fontFamily: 'GmarketSansTTFMedium'),
    title: "App Default",
    initialRoute: '/',
    routes: {
      '/': (context) => homepage(),
      '/login': (context) => LoginPage(),
      '/main': (context) => MainPage(),
      '/shop': (context) => ShopPage(),
    },
  ));
}

// Custom Drawer 위젯
class CustomDrawer extends StatelessWidget {
  final String? username; // null 가능하도록 변경

  CustomDrawer({this.username = ''}); // 기본값을 빈 문자열로 설정

  @override
  Widget build(BuildContext context) {
    return Drawer();
  }
}

class homepage extends StatelessWidget {
  // 2초뒤에 넘어가게 설정해뒀어요
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushNamed(context, '/login');
    });
    return Scaffold(
      body: Center(
        child: Image.asset("assets/images/loading.png"),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 100),
                child: Icon(
                  Icons.person,
                  color: Color(0x9A7A7D7A),
                  size: 150,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  margin: EdgeInsets.only(top: 24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0x9A7A7D7A).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 0.7),
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "User Name",
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    String username = _usernameController.text;
                    Navigator.pushNamed(
                      context,
                      '/main',
                      arguments: username,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF89BE63).withOpacity(0.5),
                    foregroundColor: Color.fromRGBO(40, 40, 40, 0.604),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Color.fromRGBO(40, 40, 40, 0.604),
                      ),
                    ),
                  ),
                  child: Text("Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String username =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      drawer: CustomDrawer(username: username),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      BubbleButton(
                        text: '상점',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/shop',
                            arguments: username, // username 전달
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/running.png',
                  width: 500,
                  height: 250,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  '걷기/뛰기 중에 선택해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String username =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(),
      drawer: CustomDrawer(username: username),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      BubbleButton(
                        text: '시간',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/time',
                            arguments: username, // username 전달
                          );
                        },
                      ),
                      BubbleButton2(
                        text: '거리',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/distance',
                            arguments: username, // username 전달
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/running.png',
                  width: 500,
                  height: 250,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  '시간/거리 중에 선택해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Select3Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String username =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(),
      drawer: CustomDrawer(username: username),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      BubbleButton(
                        text: '시간',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/time',
                            arguments: username, // username 전달
                          );
                        },
                      ),
                      BubbleButton2(
                        text: '거리',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/distance',
                            arguments: username, // username 전달
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/running.png',
                  width: 500,
                  height: 250,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  '시간/거리 중에 선택해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BubbleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BubbleButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none, // Overflow 처리
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF89BE63),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            left: 35, // 꼬리의 위치 조정
            bottom: -8, // 꼬리의 위치를 조금 더 아래로
            child: CustomPaint(
              size: Size(20, 20), // 꼬리 크기 설정
              painter: BubbleTailPainter(color: Color(0xFF89BE63)),
            ),
          ),
        ],
      ),
    );
  }
}

class BubbleTailPainter extends CustomPainter {
  final Color color;

  BubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // 꼬리의 모양을 위쪽으로 삼각형으로 그리기
    path.moveTo(size.width / 2 + 15, size.height + 5); // 삼각형의 꼭지점 (아래에서 위로)
    path.lineTo(0, 5); // 왼쪽 위로
    path.lineTo(size.width, 0); // 오른쪽 위로
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BubbleButton2 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BubbleButton2({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none, // Overflow 처리
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF89BE63),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            right: 30, // 꼬리의 위치 조정
            bottom: -8, // 꼬리의 위치를 조금 더 아래로
            child: CustomPaint(
              size: Size(20, 20), // 꼬리 크기 설정
              painter: BubbleTailPainter2(color: Color(0xFF89BE63)),
            ),
          ),
        ],
      ),
    );
  }
}

class BubbleTailPainter2 extends CustomPainter {
  final Color color;

  BubbleTailPainter2({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // 꼬리의 모양을 위쪽으로 삼각형으로 그리기
    path.moveTo(size.width / 2 - 15, size.height + 5); // 삼각형의 꼭지점 (아래에서 위로)
    path.lineTo(0, 0); // 왼쪽 위로
    path.lineTo(size.width, 5); // 오른쪽 위로
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
