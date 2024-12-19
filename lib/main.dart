import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Widgets 초기화

  runApp(
    ChangeNotifierProvider<AppState>(
      create: (_) => AppState()..loadData(), // AppState 생성과 초기 데이터 로드
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'GmarketSansTTF'),
      title: "App Default",
      initialRoute: '/',
      routes: {
        '/': (context) => homepage(),
        '/login': (context) => LoginPage(),
        '/main': (context) => MainPage(
            weeklyGoal: Provider.of<AppState>(context).weeklyGoal,
            weeklySpending: Provider.of<AppState>(context).weeklySpending,
            points: Provider.of<AppState>(context).points),
        '/community': (context) => CommunityPage(),
        '/eco': (context) => EcoPage(
              points: Provider.of<AppState>(context).points,
              updatePoints:
                  Provider.of<AppState>(context, listen: false).updatePoints,
            ),
        '/month': (context) => MonthPage(),
        '/detail2': (context) => Detail(),
        '/weekgoal': (context) => WeekGoal(),
        '/mypage': (context) => MyPage(),
        '/secondimage': (context) => SecondImage(),
        '/card': (context) => cardPage(),
        '/web': (context) => webPage(),
        '/han': (context) => hanPage(),
        '/food': (context) => foodPage(
              points: Provider.of<AppState>(context).points,
              updatePoints:
                  Provider.of<AppState>(context, listen: false).updatePoints,
            ),
        '/drink': (context) => drinkPage(
              points: Provider.of<AppState>(context).points,
              updatePoints:
                  Provider.of<AppState>(context, listen: false).updatePoints,
            ),
        '/color': (context) => colorPage(
              points: Provider.of<AppState>(context).points,
              updatePoints:
                  Provider.of<AppState>(context, listen: false).updatePoints,
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final selectedDate = settings.arguments as DateTime;
          return MaterialPageRoute(
            builder: (context) => DetailPage(selectedDate: selectedDate),
          );
        }
        return null;
      },
    );
  }
}

class homepage extends StatelessWidget {
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: screenWidth * 0.2),
                child: Icon(
                  Icons.person,
                  color: Color(0x9A7A7D7A),
                  size: screenWidth * 0.4,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  width: double.infinity,
                  height: screenWidth * 0.12,
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
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.03,
                        horizontal: screenWidth * 0.03,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  width: double.infinity,
                  height: screenWidth * 0.12,
                  margin: EdgeInsets.only(top: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0x9A7A7D7A).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 0.7),
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "password",
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.03,
                        horizontal: screenWidth * 0.03,
                      ),
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
                    backgroundColor: Color(0xFF93A5AD).withOpacity(0.5),
                    foregroundColor: Color.fromRGBO(40, 40, 40, 0.604),
                    minimumSize: Size(double.infinity, screenWidth * 0.12),
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
  final double weeklyGoal;
  final double weeklySpending;
  final int points;

  MainPage({
    required this.weeklyGoal,
    required this.weeklySpending,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    // 문구 목록
    List<String> quotes = [
      '오늘 한 푼이 내일의 백 푼',
      '천 리 길도 한 걸음부터',
      '작은 물방울도 바위를 뚫는다',
      '시작이 반이다',
    ];

    String randomQuote = quotes[Random().nextInt(quotes.length)];
    double progress = weeklySpending / weeklyGoal;

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;

        return Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  // 기존 배경 및 컴포넌트
                  Positioned(
                    left: 0,
                    top: screenHeight * 0.68,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight * 0.22,
                      decoration: BoxDecoration(color: Color(0xFFBCBCBC)),
                    ),
                  ),
                  // 오른쪽 상단 아이콘들 추가
                  Positioned(
                    right: screenWidth * 0.05, // 화면 오른쪽 여백
                    top: screenHeight * 0.08, // 화면 위쪽 여백
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          color: Colors.black,
                          iconSize: screenWidth * 0.08,
                          onPressed: () {
                            Navigator.pushNamed(context, '/weekgoal');
                          },
                        ),
                        SizedBox(width: screenWidth * 0.02), // 아이콘 간 간격
                        IconButton(
                          icon: Icon(Icons.account_circle),
                          color: Colors.black,
                          iconSize: screenWidth * 0.08,
                          onPressed: () {
                            Navigator.pushNamed(context, '/mypage');
                          },
                        ),
                        SizedBox(width: screenWidth * 0.02), // 아이콘 간 간격 추가
                        IconButton(
                          icon: Icon(Icons.store),
                          color: Colors.black,
                          iconSize: screenWidth * 0.08,
                          onPressed: () {
                            Navigator.pushNamed(context, '/food');
                          },
                          tooltip: '상점으로 이동',
                        ),
                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.115),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/month');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFDDDDDD),
                              fixedSize:
                                  Size(screenWidth * 0.25, screenWidth * 0.25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              '이달의\n내역',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/eco');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFDDDDDD),
                              fixedSize:
                                  Size(screenWidth * 0.25, screenWidth * 0.25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              '경제\n지식',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/community');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFDDDDDD),
                              fixedSize:
                                  Size(screenWidth * 0.25, screenWidth * 0.25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              '커뮤\n니티',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 랜덤 문구
                  Positioned(
                    left: screenWidth * 0.12,
                    bottom: 20,
                    child: Container(
                      width: screenWidth * 0.76,
                      alignment: Alignment.center, // 텍스트를 가운데로 맞춤
                      child: Text(
                        randomQuote,
                        maxLines: 1, // 두 줄이 되지 않도록 설정
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.05,
                    top: screenHeight * 0.05,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 퍼센트 그래프
                        Stack(
                          children: [
                            // 그래프의 배경
                            Container(
                              width: screenWidth * 0.9,
                              height: screenHeight * 0.02,
                              decoration: BoxDecoration(
                                color: Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            // 그래프의 진행도 (실제 금액에 따라 진행도를 계산)
                            Container(
                              width:
                                  screenWidth * 0.9 * progress, // 목표 대비 진행된 비율
                              height: screenHeight * 0.02,
                              decoration: BoxDecoration(
                                color: Color(0xFF76C7C0),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        // 텍스트 설명
                        Text(
                          '금주 지출 목표',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.045, // 텍스트 크기
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          weeklyGoal.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.04, // 금액 크기
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 캐릭터 이미지
                  Positioned(
                    left: screenWidth * 0.25,
                    top: screenHeight * 0.2,
                    child: Image.asset(
                      // progress 값에 따라 이미지 경로 변경
                      'assets/images/character_${getCharacter(progress)}.png',
                      width: screenWidth * 0.4,
                      height: screenWidth * 0.675,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned(
                    left: screenWidth * 0.03,
                    top: screenHeight * 0.60,
                    child: Container(
                      width: screenWidth * 0.3,
                      height: screenHeight * 0.07,
                      decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: Center(
                        child: Text(
                          points.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

//progress 값에 맞는 이미지 번호를 반환
String getCharacter(double progress) {
  if (progress <= 0.2) {
    return '1';
  } else if (progress <= 0.4) {
    return '2';
  } else if (progress <= 0.6) {
    return '3';
  } else if (progress <= 0.8) {
    return '4';
  } else {
    return '5';
  }
}

class WeekGoal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double weeklyGoal = Provider.of<AppState>(context).weeklyGoal;
    double weeklySpending = Provider.of<AppState>(context).weeklySpending;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 배경 색상
          Container(color: Color(0xFF93A5AD)),

          // 상단 제목
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.03),
              child: Text(
                '금주 지출 목표',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.height * 0.04,
                  fontFamily: 'Gmarket Sans TTF',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 뒤로 가기 버튼
          Positioned(
            left: MediaQuery.of(context).size.width * 0.04,
            top: MediaQuery.of(context).size.height * 0.03,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.12,
              height: MediaQuery.of(context).size.width * 0.12,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // 첫 번째 박스
          Positioned(
            top: MediaQuery.of(context).size.height * 0.13,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.27,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitle("금주 지출 목표"),
                    SizedBox(height: 16),
                    _buildGoalAndSpending(weeklyGoal, weeklySpending, context),
                    SizedBox(height: 16),
                    _buildProgressBar(weeklySpending / weeklyGoal),
                  ],
                ),
              ),
            ),
          ),

          // 두 번째 박스
          Positioned(
            top: MediaQuery.of(context).size.height * 0.43,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.53,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    // 콘텐츠 스크롤 가능한 영역
                    Padding(
                      padding: EdgeInsets.only(bottom: 150),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTitle("지난주 지출 내역"),
                            SizedBox(height: 16),
                            _buildProgressBar(weeklySpending / weeklyGoal),
                            SizedBox(height: 60),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                    // 캐릭터와 메시지 박스
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.05,
                      bottom: MediaQuery.of(context).size.height * 0.24,
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/character_1.png",
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: MediaQuery.of(context).size.height * 0.1,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.height * 0.06,
                            decoration: ShapeDecoration(
                              color: Color(0xFF93A5AD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Center(
                                child: Text(
                                  "지난 주에 20,000원을 아껴서 ~를 리워드로 받았어!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 추가 요소
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.05,
                      bottom: MediaQuery.of(context).size.height * 0.02,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                decoration: ShapeDecoration(
                                  color: Color(0xFF93A5AD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Center(
                                    child: Text(
                                      "지출을 줄였다면, 살 수 있었던 물건들을 알려줄게!",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..scale(-1.0, 1.0),
                                child: Image.asset(
                                  "assets/images/character_1.png",
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.03),
                            width: MediaQuery.of(context).size.width * 0.77,
                            height: MediaQuery.of(context).size.height * 0.10,
                            decoration: ShapeDecoration(
                              color: Color(0x00D9D9D9),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 2, color: Color(0xFF93A5AD)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween, // 요소 간 간격 조정
                              crossAxisAlignment:
                                  CrossAxisAlignment.center, // 세로 정렬
                              children: [
                                Container(
                                  width: screenWidth * 0.22,
                                  height: screenHeight * 0.1,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/drink1.png'), // 로컬 이미지
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Text(
                                  '패딩',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.04,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '\$150,000',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 큰 제목
  Widget _buildTitle(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // 목표와 지출 표시 (금액 및 수정 아이콘 포함)
  Widget _buildGoalAndSpending(
      double weeklyGoal, double weeklySpending, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "현재 지출: ${weeklySpending.toStringAsFixed(0)}원",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              "목표: ${weeklyGoal.toStringAsFixed(0)}원",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          onPressed: () async {
            double? newGoal = await _showGoalInputDialog(context);
            if (newGoal != null) {
              Provider.of<AppState>(context, listen: false)
                  .setWeeklyGoal(newGoal);
            }
          },
        ),
      ],
    );
  }

  // 진행 바
  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "현재 지출: ${progress * 100}% / 목표: 100%",
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          color: Colors.green,
          minHeight: 20,
        ),
        SizedBox(height: 25),
      ],
    );
  }

  // 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // 지난 주 요약 정보
  Widget _buildLastWeekSummary(String summary) {
    return Text(
      summary,
      style: TextStyle(fontSize: 16, color: Colors.black),
    );
  }

  // 목표 입력 다이얼로그
  Future<double?> _showGoalInputDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("금주 목표 수정"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "새 목표 금액"),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                double? goal = double.tryParse(controller.text);
                if (goal != null) {
                  Navigator.of(context).pop(goal);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text("저장"),
            ),
          ],
        );
      },
    );
  }
}

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final appState = Provider.of<AppState>(context);
    String _nickname = appState.name;
    int _points = appState.points;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Color(0xFF93A5AD)),
            child: Stack(
              children: [
                // 카드 컨테이너
                Positioned(
                  left: screenWidth * 0.07,
                  top: screenHeight * 0.28,
                  child: Container(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.68,
                    decoration: ShapeDecoration(
                      color: Color(0xFFEEEEEE),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 3, color: Color(0xFF93A5AD)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                // 닉네임 수정 박스
                Positioned(
                  left: screenWidth * 0.4,
                  top: screenHeight * 0.15,
                  child: Container(
                    width: screenWidth * 0.45,
                    height: screenHeight * 0.05,
                    decoration: ShapeDecoration(
                      color: Color(0xFFBCBCBC),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 3,
                          offset: Offset(0, screenHeight * 0.005),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 닉네임 텍스트
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02),
                          child: Text(
                            _nickname,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenHeight * 0.018,
                              fontFamily: 'Gmarket Sans TTF',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // 수정 아이콘
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: screenHeight * 0.022,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController nicknameController =
                                    TextEditingController(text: _nickname);
                                return AlertDialog(
                                  title: Text('닉네임 수정'),
                                  content: TextField(
                                    controller: nicknameController,
                                    decoration:
                                        InputDecoration(hintText: '새 닉네임 입력'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        appState.updateName(
                                            nicknameController.text);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('저장'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // 포인트 표시 박스
                Positioned(
                  left: screenWidth * 0.4,
                  top: screenHeight * 0.25,
                  child: Container(
                    width: screenWidth * 0.45,
                    height: screenHeight * 0.05,
                    decoration: ShapeDecoration(
                      color: Color(0xFFBCBCBC),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 3,
                          offset: Offset(0, screenHeight * 0.005),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '포인트: $_points',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.018,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MonthPage extends StatefulWidget {
  @override
  _MonthlySummaryPageState createState() => _MonthlySummaryPageState();
}

class _MonthlySummaryPageState extends State<MonthPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // 수입 내역과 지출 내역 불러오기
    String? expenseData = prefs.getString('expenseRecords');
    String? incomeData = prefs.getString('incomeRecords');

    if (expenseData != null) {
      List<dynamic> expenseList = jsonDecode(expenseData);
      totalExpense = expenseList.fold(
          0.0, (sum, e) => sum + (double.tryParse(e['amount']) ?? 0.0));
    }

    if (incomeData != null) {
      List<dynamic> incomeList = jsonDecode(incomeData);
      totalIncome = incomeList.fold(
          0.0, (sum, e) => sum + (double.tryParse(e['amount']) ?? 0.0));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이달의 내역'),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      '이번달 수입: ${totalIncome.toStringAsFixed(0)}원\n이번달 지출: ${totalExpense.toStringAsFixed(0)}원',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2024, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) async {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      // 상세 페이지로 이동 후 데이터 반환
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPage(selectedDate: selectedDay),
                        ),
                      );

                      // 새 데이터로 업데이트
                      if (result == true) {
                        _loadData();
                      }
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue[200],
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: Icon(Icons.chevron_left),
                      rightChevronIcon: Icon(Icons.chevron_right),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/detail2'); // 소비 내역 보기 기능 추가
            },
            child: Text('소비 내역 자세히 보기'),
          ),
        ],
      ),
    );
  }
}

// 카테고리 관련
class DetailPage extends StatefulWidget {
  final DateTime selectedDate;

  DetailPage({required this.selectedDate});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late DateTime _selectedDay;
  List<Map<String, String>> expenseRecords = [];
  List<Map<String, String>> incomeRecords = [];
  List<String> expenseCategories = [];
  List<String> incomeCategories = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDate;
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    String? expenseData = prefs.getString('expenseRecords');
    if (expenseData != null) {
      List<dynamic> expenseList = jsonDecode(expenseData);
      expenseRecords =
          expenseList.map((e) => Map<String, String>.from(e)).toList();
    }

    String? incomeData = prefs.getString('incomeRecords');
    if (incomeData != null) {
      List<dynamic> incomeList = jsonDecode(incomeData);
      incomeRecords =
          incomeList.map((e) => Map<String, String>.from(e)).toList();
    }

    String? expenseCategoriesData = prefs.getString('expenseCategories');
    if (expenseCategoriesData != null) {
      expenseCategories = List<String>.from(jsonDecode(expenseCategoriesData));
    }

    String? incomeCategoriesData = prefs.getString('incomeCategories');
    if (incomeCategoriesData != null) {
      incomeCategories = List<String>.from(jsonDecode(incomeCategoriesData));
    }

    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('expenseRecords', jsonEncode(expenseRecords));
    prefs.setString('incomeRecords', jsonEncode(incomeRecords));
    prefs.setString('expenseCategories', jsonEncode(expenseCategories));
    prefs.setString('incomeCategories', jsonEncode(incomeCategories));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${_selectedDay.year}년 ${_selectedDay.month}월 ${_selectedDay.day}일 내역'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('지출 기록', true),
            _buildRecordTable(expenseRecords),
            _buildAddButton(isExpense: true),
            SizedBox(height: 20),
            _buildSectionTitle('수입 기록', false),
            _buildRecordTable(incomeRecords),
            _buildAddButton(isExpense: false),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isExpense) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => manageCategories(isExpense),
          child: Text('카테고리 관리'),
        ),
      ],
    );
  }

  Widget _buildRecordTable(List<Map<String, String>> records) {
    final filteredRecords = records.where((record) {
      final recordDate = DateTime.parse(record['date']!);
      return isSameDay(recordDate, _selectedDay);
    }).toList();

    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: [
        TableRow(
          children: [
            _buildTableCell('카테고리', isHeader: true),
            _buildTableCell('내용', isHeader: true),
            _buildTableCell('금액', isHeader: true),
            _buildTableCell('쓸데없는지출', isHeader: true),
            _buildTableCell('삭제', isHeader: true),
          ],
        ),
        ...filteredRecords.map((record) {
          return TableRow(
            children: [
              _buildTableCell(record['category'] ?? ''),
              _buildTableCell(record['content'] ?? ''),
              _buildTableCell(record['amount'] ?? ''),
              Checkbox(
                value: record['isUnnecessary'] == 'true',
                onChanged: (value) {
                  setState(() {
                    record['isUnnecessary'] = value! ? 'true' : 'false';
                  });
                  _saveData(); // 데이터 저장
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    records.remove(record);
                  });
                  _saveData(); // 데이터 저장
                },
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableCell(String content, {bool isHeader = false}) {
    // 색상과 카테고리 이름 분리
    final parts = content.split('|');
    final categoryName = parts[0];
    final categoryColorName = parts.length > 1 ? parts[1] : null;

    // 색상 맵
    final colors = {
      '빨강': Colors.red,
      '주황': Colors.orange,
      '노랑': Colors.yellow,
      '초록': Colors.green,
      '파랑': Colors.blue,
      '남색': Colors.indigo,
      '보라': Colors.purple,
    };

    // 색상 결정
    final categoryColor = colors[categoryColorName] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isHeader
          ? Text(
              content,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            )
          : Row(
              children: [
                if (categoryColorName != null)
                  CircleAvatar(
                    backgroundColor: categoryColor,
                    radius: 8, // 원의 크기 조절
                  ),
                if (categoryColorName != null)
                  SizedBox(width: 8), // 원과 텍스트 사이 간격
                Expanded(
                  child: Text(
                    categoryName,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAddButton({required bool isExpense}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _addRecordDialog(isExpense),
        icon: Icon(Icons.add),
        label: Text('추가'),
      ),
    );
  }

  void _addRecordDialog(bool isExpense) {
    String? selectedCategory;
    String content = '';
    String amount = '';
    bool isUnnecessary = false; // 쓸데없는지출 상태 변수

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isExpense ? '지출 추가' : '수입 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: '카테고리'),
                    value: selectedCategory,
                    items: (isExpense ? expenseCategories : incomeCategories)
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '내용'),
                    onChanged: (value) {
                      content = value;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: '금액'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      amount = value;
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isUnnecessary,
                        onChanged: (value) {
                          setState(() {
                            isUnnecessary = value ?? false;
                          });
                        },
                      ),
                      Text('쓸데없는지출'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      final record = {
                        'category': selectedCategory ?? '',
                        'content': content,
                        'amount': amount,
                        'date': _selectedDay.toString(),
                        'isUnnecessary': isUnnecessary ? 'true' : 'false',
                      };
                      if (isExpense) {
                        expenseRecords.add(record);
                      } else {
                        incomeRecords.add(record);
                      }
                    });
                    _saveData();
                    Navigator.pop(context, true);
                  },
                  child: Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void manageCategories(bool isExpense) {
    showDialog(
      context: context,
      builder: (context) {
        String newCategory = '';
        String selectedColor = '빨강'; // 기본 색상

        final colors = {
          '빨강': Colors.red,
          '주황': Colors.orange,
          '노랑': Colors.yellow,
          '초록': Colors.green,
          '파랑': Colors.blue,
          '남색': Colors.indigo,
          '보라': Colors.purple,
        };

        return AlertDialog(
          title: Text(isExpense ? '지출 카테고리 관리' : '수입 카테고리 관리'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...(isExpense ? expenseCategories : incomeCategories)
                  .map((category) {
                return ListTile(
                  title: Text(category),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        if (isExpense) {
                          expenseCategories.remove(category);
                        } else {
                          incomeCategories.remove(category);
                        }
                      });
                      _saveData(); // 카테고리 삭제 후 저장
                      Navigator.pop(context);
                      manageCategories(isExpense);
                    },
                  ),
                );
              }).toList(),
              TextField(
                decoration: InputDecoration(labelText: '새 카테고리'),
                onChanged: (value) {
                  newCategory = value;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '색상 선택'),
                value: selectedColor,
                items: colors.keys.map((colorName) {
                  return DropdownMenuItem(
                    value: colorName,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colors[colorName],
                          radius: 10,
                        ),
                        SizedBox(width: 8),
                        Text(colorName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedColor = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('닫기'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (newCategory.isNotEmpty) {
                    final newCategoryWithColor = '$newCategory|$selectedColor';
                    if (isExpense) {
                      expenseCategories.add(newCategoryWithColor);
                    } else {
                      incomeCategories.add(newCategoryWithColor);
                    }
                  }
                });
                _saveData(); // 새 카테고리 추가 후 저장
                Navigator.pop(context);
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }
}

// 소비 내역 자세히 보기
class Detail extends StatefulWidget {
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 147, 165, 173),
          title: Text('12월 소비 내역'),
        ),
        body: Stack(
          children: [
            Positioned.fill(
                child: GestureDetector(
                    onTap: () {
                      Navigator.popAndPushNamed(context, '/secondimage');
                    },
                    child: Image.asset(
                      'assets/images/thql1.png',
                      fit: BoxFit.cover,
                    )))
          ],
        ));
  }
}

class SecondImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 147, 165, 173),
          title: Text('12월 소비 내역'),
        ),
        body: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
              'assets/images/thql2.png',
              fit: BoxFit.cover,
            ))
          ],
        ));
  }
}

class EcoPage extends StatelessWidget {
  final int points;
  final Function(int) updatePoints;

  EcoPage({required this.points, required this.updatePoints});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.07),
                      child: Text(
                        '경제 지식',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.04,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.04,
                    top: screenHeight * 0.05,
                    child: Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.11,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/eco');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        "동영상",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.28,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/card');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "카드뉴스",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.45,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/web');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "웹툰",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.62,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/han');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "한은소식",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.07,
                    top: screenHeight * 0.21,
                    child: Container(
                      width: screenWidth * 0.86,
                      height: screenHeight * 0.75,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFF93A5AD)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: ListView(
                        children: [
                          for (var i = 0; i < 5; i++) ...[
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(screenWidth * 0.03),
                                  width: screenWidth * 0.75,
                                  height: screenHeight * 0.13,
                                  decoration: ShapeDecoration(
                                    color: Color(0x00D9D9D9),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 2, color: Color(0xFF93A5AD)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.05,
                                  top: screenHeight * 0.04,
                                  child: Container(
                                    width: screenWidth * 0.35,
                                    height: screenHeight * 0.1,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/image${i + 1}.png'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.5,
                                  top: screenHeight * 0.12,
                                  child: SizedBox(
                                    width: screenWidth * 0.14,
                                    height: screenHeight * 0.03,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final Uri url = Uri.parse(
                                            'https://www.bok.or.kr/portal/bbs/B0000535/view.do?nttId=10087964&searchCnd=1&searchKwd=&pageUnit=12&depth=201151&pageIndex=2&menuNo=201721&oldMenuNo=201151&programType=multiCont');

                                        // URL 열기
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);

                                          // 링크 클릭 시 포인트 추가 및 팝업 메시지 표시
                                          updatePoints(500); // 포인트 500 추가

                                          // 화면 중앙에 팝업 메시지 표시
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content:
                                                    Text('500포인트가 추가되었습니다!'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('확인'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Text(
                                        '동영상 보기',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: screenHeight * 0.012,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class cardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.07),
                      child: Text(
                        '경제 지식',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.04,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.04,
                    top: screenHeight * 0.05,
                    child: Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.11,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/eco');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "동영상",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.28,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/card');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        "카드뉴스",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.45,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/web');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "웹툰",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.62,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/han');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "한은소식",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.07,
                    top: screenHeight * 0.21,
                    child: Container(
                      width: screenWidth * 0.86,
                      height: screenHeight * 0.75,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFF93A5AD)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: ListView(
                        children: [
                          for (var i = 0; i < 6; i++) ...[
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(screenWidth * 0.03),
                                  width: screenWidth * 0.75,
                                  height: screenHeight * 0.13,
                                  decoration: ShapeDecoration(
                                    color: Color(0x00D9D9D9),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 2, color: Color(0xFF93A5AD)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.05,
                                  top: screenHeight * 0.04,
                                  child: Container(
                                    width: screenWidth * 0.35,
                                    height: screenHeight * 0.1,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/${i * 2 + 1}.png'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.45,
                                  top: screenHeight * 0.04,
                                  child: Container(
                                    width: screenWidth * 0.26,
                                    height: screenHeight * 0.08,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/${2 * (i + 1)}.png'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.45,
                                  top: screenHeight * 0.12,
                                  child: Container(
                                    width: screenWidth * 0.26,
                                    height: screenHeight * 0.02,
                                    decoration: ShapeDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 2, color: Color(0xFF93A5AD)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.5,
                                  top: screenHeight * 0.12,
                                  child: SizedBox(
                                    width: screenWidth * 0.14,
                                    height: screenHeight * 0.03,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final Uri url = Uri.parse(
                                            'https://www.bok.or.kr/portal/bbs/B0000365/view.do?nttId=10088163&searchCnd=1&searchKwd=&depth2=201214&date=&sdate=&edate=&sort=1&pageUnit=12&depth=201214&pageIndex=1&menuNo=201138&oldMenuNo=201151&programType=multiCont');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Text(
                                        '카드뉴스 보기',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: screenHeight * 0.012,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class webPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.07),
                      child: Text(
                        '경제 지식',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.04,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.04,
                    top: screenHeight * 0.05,
                    child: Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.11,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/eco');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "동영상",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.28,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/card');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "카드뉴스",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.45,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/web');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        "웹툰",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.62,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/han');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "한은소식",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.07,
                    top: screenHeight * 0.21,
                    child: Container(
                      width: screenWidth * 0.86,
                      height: screenHeight * 0.75,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFF93A5AD)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: ListView(
                        children: [
                          for (var i = 0; i < 8; i++) ...[
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(screenWidth * 0.03),
                                  width: screenWidth * 0.75,
                                  height: screenHeight * 0.13,
                                  decoration: ShapeDecoration(
                                    color: Color(0x00D9D9D9),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 2, color: Color(0xFF93A5AD)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.05,
                                  top: screenHeight * 0.04,
                                  child: Container(
                                    width: screenWidth * 0.35,
                                    height: screenHeight * 0.1,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/img${i + 1}.png'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.45,
                                  top: screenHeight * 0.04,
                                  child: Container(
                                    width: screenWidth * 0.26,
                                    height: screenHeight * 0.08,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/img${i + 9}.png'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.45,
                                  top: screenHeight * 0.12,
                                  child: Container(
                                    width: screenWidth * 0.26,
                                    height: screenHeight * 0.02,
                                    decoration: ShapeDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 2, color: Color(0xFF93A5AD)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.5,
                                  top: screenHeight * 0.12,
                                  child: SizedBox(
                                    width: screenWidth * 0.14,
                                    height: screenHeight * 0.03,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final Uri url = Uri.parse(
                                            'https://www.bok.or.kr/portal/bbs/B0000320/view.do?nttId=10058718&searchCnd=1&searchKwd=&depth2=201304&date=&sdate=&edate=&sort=1&pageUnit=12&depth=201304&pageIndex=1&menuNo=201305&oldMenuNo=201151&programType=multiCont');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Text(
                                        '웹툰 보기',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: screenHeight * 0.012,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class hanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.07),
                      child: Text(
                        '경제 지식',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.04,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.04,
                    top: screenHeight * 0.05,
                    child: Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.11,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/eco');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "동영상",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.28,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/card');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "카드뉴스",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.45,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/web');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Color(0xFF93A5AD),
                      ),
                      child: Text(
                        "웹툰",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.62,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/han');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.18, screenHeight * 0.09),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 3,
                            color: Color(0xFFEEEEEE),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth * 0.06),
                            topRight: Radius.circular(screenWidth * 0.06),
                          ),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        "한은소식",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.07,
                    top: screenHeight * 0.21,
                    child: Container(
                      width: screenWidth * 0.86,
                      height: screenHeight * 0.75,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFF93A5AD)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: ListView(
                        children: [
                          for (var i = 0; i < 6; i++) ...[
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(screenWidth * 0.03),
                                  width: screenWidth * 0.75,
                                  height: screenHeight * 0.13,
                                  decoration: ShapeDecoration(
                                    color: Color(0x00D9D9D9),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 2, color: Color(0xFF93A5AD)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.05,
                                  top: screenHeight * 0.04,
                                  child: Container(
                                    width: screenWidth * 0.35,
                                    height: screenHeight * 0.1,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/han${i + 1}.png'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.45,
                                  top: screenHeight * 0.04,
                                  child: Container(
                                    width: screenWidth * 0.26,
                                    height: screenHeight * 0.08,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/han${i + 7}.png'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.45,
                                  top: screenHeight * 0.12,
                                  child: Container(
                                    width: screenWidth * 0.26,
                                    height: screenHeight * 0.02,
                                    decoration: ShapeDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 2, color: Color(0xFF93A5AD)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.5,
                                  top: screenHeight * 0.12,
                                  child: SizedBox(
                                    width: screenWidth * 0.14,
                                    height: screenHeight * 0.03,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final Uri url = Uri.parse(
                                            'https://www.bok.or.kr/portal/bbs/B0000204/view.do?nttId=10082489&searchCnd=1&searchKwd=&depth2=200042&date=&sdate=&edate=&sort=1&pageUnit=12&depth=200042&pageIndex=1&menuNo=200042&oldMenuNo=201151&programType=multiCont');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Text(
                                        '한은소식 보기',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: screenHeight * 0.012,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // 텍스트 입력 컨트롤러
  final TextEditingController _controller = TextEditingController();

  // 전송된 메시지를 저장할 리스트
  List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    // 화면 크기 가져오기
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            // 배경색
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: screenWidth,
                height: screenHeight,
                decoration: BoxDecoration(color: Color(0xFF93A5AD)),
              ),
            ),
            // 커뮤니티 텍스트
            Positioned(
              left: screenWidth * 0.3,
              top: screenHeight * 0.05,
              child: Text(
                '커뮤니티',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.1,
                  fontFamily: 'Gmarket Sans TTF',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // 메시지 리스트 (말풍선)
            Positioned(
              left: screenWidth * 0.07,
              top: screenHeight * 0.14,
              child: Container(
                width: screenWidth * 0.86,
                height: screenHeight * 0.7, // 메시지 영역
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    // 각 메시지를 말풍선 형태로 표시
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Align(
                        alignment: Alignment.centerLeft, // 왼쪽 정렬
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            children: [
                              // 텍스트 메시지
                              Expanded(
                                child: Text(
                                  messages[index],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenWidth * 0.045,
                                    fontFamily: 'Gmarket Sans TTF',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // 신고 버튼
                              IconButton(
                                icon: Icon(
                                  Icons.report,
                                  color: Colors.red,
                                  size: screenWidth * 0.05,
                                ),
                                onPressed: () {
                                  // 신고 기능
                                  _showReportDialog(context, messages[index]);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // 하단 전송 바
            Positioned(
              left: screenWidth * 0.07,
              top: screenHeight * 0.85,
              child: Container(
                width: screenWidth * 0.86,
                height: screenHeight * 0.1,
                decoration: ShapeDecoration(
                  color: Color(0xFFD9D9D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // 텍스트 입력 필드
                    Container(
                      width: screenWidth * 0.7,
                      height: screenHeight * 0.05,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: '메시지를 입력하세요...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    // 전송 버튼
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          setState(() {
                            // 입력된 텍스트를 messages 리스트에 추가
                            messages.add(_controller.text);
                          });
                          _controller.clear(); // 입력 필드 비우기
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 신고 다이얼로그
  void _showReportDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('신고'),
          content: Text('이 메시지를 신고하시겠습니까?\n\n$message'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 신고 처리 로직 (예: 서버에 신고 내용 전송)
                Navigator.pop(context);
                _showSnackBar(context, '메시지가 신고되었습니다.');
              },
              child: Text('신고'),
            ),
          ],
        );
      },
    );
  }

  // 신고 후 SnackBar로 알림 표시
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class foodPage extends StatelessWidget {
  final int points;
  final Function(int) updatePoints;

  foodPage({required this.points, required this.updatePoints});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter, // 상단 중앙 정렬
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: screenHeight * 0.07), // 상단 여백 조정
                      child: Text(
                        'SHOP',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.04,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.04,
                    top: screenHeight * 0.05,
                    child: Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back), // 뒤로 가기 화살표 아이콘
                        onPressed: () {
                          Navigator.pop(context); // 뒤로 가기 동작
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.11,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/food');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(screenWidth * 0.18, screenHeight * 0.09),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(screenWidth * 0.06),
                              topRight: Radius.circular(screenWidth * 0.06),
                            ),
                          ),
                          backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                      child: Text(
                        "음식", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: screenHeight * 0.015, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.28,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/drink');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(screenWidth * 0.18, screenHeight * 0.09),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(screenWidth * 0.06),
                              topRight: Radius.circular(screenWidth * 0.06),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: Text(
                        "음료", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: screenHeight * 0.015, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.45,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/color');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(screenWidth * 0.18, screenHeight * 0.09),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(screenWidth * 0.06),
                              topRight: Radius.circular(screenWidth * 0.06),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: Text(
                        "색변경", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: screenHeight * 0.015, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.07,
                    top: screenHeight * 0.21,
                    child: Container(
                      width: screenWidth * 0.86,
                      height: screenHeight * 0.75,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFF93A5AD)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: ListView(
                        children: [
                          // 동영상 항목 리스트 (중복된 구조로 반복)
                          for (var i = 0; i < 5; i++) ...[
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(screenWidth * 0.03),
                                  width: screenWidth * 0.77,
                                  height: screenHeight * 0.13,
                                  decoration: ShapeDecoration(
                                    color: Color(0x00D9D9D9),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 2, color: Color(0xFF93A5AD)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.05,
                                  top: screenHeight * 0.04,
                                  child: Container(
                                    width: screenWidth * 0.22,
                                    height: screenHeight * 0.1,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/food${i + 1}.png'), // 로컬 이미지 불러오기
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.28,
                                  top: screenHeight * 0.035,
                                  child: SizedBox(
                                    width: screenWidth * 0.2,
                                    height: screenHeight * 0.1,
                                    child: TextButton(
                                      onPressed: () {
                                        // 팝업창 표시
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('나 키위 머것따'), // 팝업창 제목
                                              content: Column(
                                                mainAxisSize: MainAxisSize
                                                    .min, // 콘텐츠 크기를 내용에 맞게
                                                children: [
                                                  Image.asset(
                                                    'assets/images/character_1.png', // 로컬 이미지 경로
                                                    width: 100, // 이미지 너비
                                                    height: 185, // 이미지 높이
                                                    fit: BoxFit.cover,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          10), // 이미지와 텍스트 사이 간격
                                                  Text('움냠냠냠냠냠우걱우걱'), // 팝업창 내용
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // 팝업창 닫기
                                                  },
                                                  child: Text('닫기'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero, // 버튼 내부 여백 제거
                                      ),
                                      child: Text(
                                        '키위',
                                        style: TextStyle(
                                          color: Colors.black, // 텍스트 색상
                                          fontSize:
                                              screenHeight * 0.05, // 텍스트 크기
                                          fontWeight: FontWeight.w500, // 텍스트 두께
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.5,
                                  top: screenHeight * 0.05,
                                  child: SizedBox(
                                    width: screenWidth * 0.35,
                                    height: screenHeight * 0.35,
                                    child: Text(
                                      '\$1,500',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenHeight * 0.05,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 40,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6), // 여백 설정
                      decoration: BoxDecoration(
                        color: Colors.red, // 배경색
                        borderRadius: BorderRadius.circular(12), // 둥근 모서리
                      ),
                      child: Text(
                        points.toString() + 'P', // 포인트 값
                        style: TextStyle(
                          color: Colors.white, // 텍스트 색상
                          fontSize: screenHeight * 0.02, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class drinkPage extends StatelessWidget {
  final int points;
  final Function(int) updatePoints;

  drinkPage({required this.points, required this.updatePoints});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter, // 상단 중앙 정렬
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: screenHeight * 0.07), // 상단 여백 조정
                      child: Text(
                        'SHOP',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.04,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.04,
                    top: screenHeight * 0.05,
                    child: Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back), // 뒤로 가기 화살표 아이콘
                        onPressed: () {
                          Navigator.pop(context); // 뒤로 가기 동작
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.11,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/food');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(screenWidth * 0.18, screenHeight * 0.09),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(screenWidth * 0.06),
                              topRight: Radius.circular(screenWidth * 0.06),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: Text(
                        "음식", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: screenHeight * 0.015, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.28,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/drink');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(screenWidth * 0.18, screenHeight * 0.09),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(screenWidth * 0.06),
                              topRight: Radius.circular(screenWidth * 0.06),
                            ),
                          ),
                          backgroundColor: Colors.white),
                      child: Text(
                        "음료", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: screenHeight * 0.015, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.45,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/color');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(screenWidth * 0.18, screenHeight * 0.09),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(screenWidth * 0.06),
                              topRight: Radius.circular(screenWidth * 0.06),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: Text(
                        "색변경", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: screenHeight * 0.015, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.07,
                    top: screenHeight * 0.21,
                    child: Container(
                      width: screenWidth * 0.86,
                      height: screenHeight * 0.75,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFF93A5AD)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: ListView(
                        children: [
                          // 동영상 항목 리스트 (중복된 구조로 반복)
                          for (var i = 0; i < 6; i++) ...[
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(screenWidth * 0.03),
                                  width: screenWidth * 0.77,
                                  height: screenHeight * 0.13,
                                  decoration: ShapeDecoration(
                                    color: Color(0x00D9D9D9),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 2, color: Color(0xFF93A5AD)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.05,
                                  top: screenHeight * 0.04,
                                  child: Container(
                                    width: screenWidth * 0.22,
                                    height: screenHeight * 0.1,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/drink${i + 1}.png'), // 로컬 이미지 불러오기
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.28,
                                  top: screenHeight * 0.035,
                                  child: SizedBox(
                                    width: screenWidth * 0.2,
                                    height: screenHeight * 0.1,
                                    child: TextButton(
                                      onPressed: () {
                                        // 버튼 클릭 시 실행할 동작
                                        print("물 버튼이 클릭되었습니다.");
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero, // 버튼 내부 여백 제거
                                      ),
                                      child: Text(
                                        '물',
                                        style: TextStyle(
                                          color: Colors.black, // 텍스트 색상
                                          fontSize:
                                              screenHeight * 0.05, // 텍스트 크기
                                          fontWeight: FontWeight.w500, // 텍스트 두께
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.5,
                                  top: screenHeight * 0.05,
                                  child: SizedBox(
                                    width: screenWidth * 0.35,
                                    height: screenHeight * 0.35,
                                    child: Text(
                                      '\$1,000',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenHeight * 0.05,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 40,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6), // 여백 설정
                      decoration: BoxDecoration(
                        color: Colors.red, // 배경색
                        borderRadius: BorderRadius.circular(12), // 둥근 모서리
                      ),
                      child: Text(
                        points.toString() + 'P', // 포인트 값
                        style: TextStyle(
                          color: Colors.white, // 텍스트 색상
                          fontSize: screenHeight * 0.02, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class colorPage extends StatelessWidget {
  final int points;
  final Function(int) updatePoints;

  colorPage({required this.points, required this.updatePoints});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter, // 상단 중앙 정렬
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: screenHeight * 0.07), // 상단 여백 조정
                      child: Text(
                        'SHOP',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenHeight * 0.04,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.04,
                    top: screenHeight * 0.05,
                    child: Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back), // 뒤로 가기 화살표 아이콘
                        onPressed: () {
                          Navigator.pop(context); // 뒤로 가기 동작
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.11,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/food');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(screenWidth * 0.18, screenHeight * 0.09),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(screenWidth * 0.06),
                              topRight: Radius.circular(screenWidth * 0.06),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: Text(
                        "음식", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: screenHeight * 0.015, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.28,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/drink');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(screenWidth * 0.18, screenHeight * 0.09),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(screenWidth * 0.06),
                              topRight: Radius.circular(screenWidth * 0.06),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: Text(
                        "음료", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: screenHeight * 0.015, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.45,
                    top: screenHeight * 0.14,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/color');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(screenWidth * 0.18, screenHeight * 0.09),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(screenWidth * 0.06),
                              topRight: Radius.circular(screenWidth * 0.06),
                            ),
                          ),
                          backgroundColor: Colors.white),
                      child: Text(
                        "색변경", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: screenHeight * 0.015, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.07,
                    top: screenHeight * 0.21,
                    child: Container(
                      width: screenWidth * 0.86,
                      height: screenHeight * 0.75,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Color(0xFF93A5AD)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: ListView(
                        children: [
                          // 동영상 항목 리스트 (중복된 구조로 반복)
                          for (var i = 0; i < 6; i++) ...[
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(screenWidth * 0.03),
                                  width: screenWidth * 0.77,
                                  height: screenHeight * 0.13,
                                  decoration: ShapeDecoration(
                                    color: Color(0x00D9D9D9),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 2, color: Color(0xFF93A5AD)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.07,
                                  top: screenHeight * 0.038,
                                  child: Container(
                                    width: screenWidth * 0.15,
                                    height: screenHeight * 0.1,
                                    decoration: ShapeDecoration(
                                      color: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.3,
                                  top: screenHeight * 0.05,
                                  child: SizedBox(
                                    width: screenWidth * 0.35,
                                    height: screenHeight * 035,
                                    child: Text(
                                      '빨강',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenHeight * 0.05,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: screenWidth * 0.5,
                                  top: screenHeight * 0.05,
                                  child: SizedBox(
                                    width: screenWidth * 0.35,
                                    height: screenHeight * 0.35,
                                    child: Text(
                                      '\$1,000',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenHeight * 0.05,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 40,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6), // 여백 설정
                      decoration: BoxDecoration(
                        color: Colors.red, // 배경색
                        borderRadius: BorderRadius.circular(12), // 둥근 모서리
                      ),
                      child: Text(
                        points.toString() + 'P', // 포인트 값
                        style: TextStyle(
                          color: Colors.white, // 텍스트 색상
                          fontSize: screenHeight * 0.02, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
