import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'GmarketSansTTF'),
    title: "App Default",
    initialRoute: '/',
    routes: {
      '/': (context) => homepage(),
      '/login': (context) => LoginPage(),
      '/main': (context) => MainPage(),
      '/community': (context) => CommunityPage(),
      '/eco': (context) => EcoPage(),
      '/month': (context) => MonthPage(),
      '/detail2': (context) => Detail(
            records: [],
            selectedMonth: '',
          ),
      '/weekgoal': (context) => WeekGoal(),
      '/mypage': (context) => MyPage(),
      '/card': (context) => cardPage(),
      '/web': (context) => webPage(),
      '/han': (context) => hanPage(),
      '/food': (context) => foodPage(),
      '/drink': (context) => drinkPage(),
      '/color': (context) => colorPage(),
    },
    onGenerateRoute: (settings) {
      if (settings.name == '/detail') {
        final selectedDate = settings.arguments as DateTime;
        return MaterialPageRoute(
          builder: (context) => DetailPage(selectedDate: selectedDate),
        );
      }
      return null; // Fallback for unknown routes
    },
  ));
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
                    top: screenHeight * 0.08, // 화면 위쪽 여백 (기존 0.05에서 0.08로 변경)
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
                    left: screenWidth * 0.12, // 텍스트를 좌측으로 조금 이동
                    bottom: 20,
                    child: Container(
                      width: screenWidth * 0.76, // 길이를 늘려줌
                      alignment: Alignment.center, // 텍스트를 가운데로 맞춤
                      child: Text(
                        randomQuote,
                        maxLines: 1, // 두 줄이 되지 않도록 설정
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.06, // 폰트 크기를 줄임
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.05, // 왼쪽 여백
                    top: screenHeight * 0.05, // 위쪽 여백
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 퍼센트 그래프
                        Stack(
                          children: [
                            // 그래프의 배경
                            Container(
                              width: screenWidth * 0.9, // 전체 막대 길이
                              height: screenHeight * 0.02, // 막대 높이
                              decoration: BoxDecoration(
                                color: Color(0xFFE0E0E0), // 배경 색상 (연회색)
                                borderRadius:
                                    BorderRadius.circular(5), // 모서리 둥글게
                              ),
                            ),
                            // 그래프의 진행도
                            Container(
                              width: screenWidth * 0.5, // 진행된 부분의 길이 (50% 예제)
                              height: screenHeight * 0.02,
                              decoration: BoxDecoration(
                                color: Color(0xFF76C7C0), // 진행된 부분의 색상
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01), // 그래프와 텍스트 간 간격
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
                          '500,000',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.04, // 금액 크기
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 캐릭터 이미지 추가
                  Positioned(
                    left: screenWidth * 0.35, // 화면 중앙에 맞추기 위해 수정
                    top: screenHeight * 0.3, // 위에서 적당한 위치로 수정
                    child: Image.asset(
                      'assets/images/character.png', // 이미지 경로 수정
                      width: screenWidth * 0.3, // 적절한 크기로 조정
                      height: screenWidth * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.03,
                    top: screenHeight * 0.63,
                    child: Container(
                      width: screenWidth * 0.3,
                      height: screenHeight * 0.07,
                      decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: Center(
                        child: Text(
                          '상태',
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
                  IconButton(
                    icon: Icon(Icons.store,
                        size: 30, color: Colors.black), // 상점 모양 아이콘
                    onPressed: () {
                      // 버튼 클릭 시 동작
                      Navigator.pushNamed(context, '/food');
                    },
                    tooltip: '상점으로 이동', // 버튼 위에 커서를 올렸을 때 표시될 힌트
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

class WeekGoal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 393,
          height: 852,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Color(0xFF93A5AD)),
          child: Stack(
            children: [
              Positioned(
                left: 50,
                top: 442,
                child: Container(
                  width: 99,
                  height: 25,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 21.44,
                        top: 4.29,
                        child: Container(
                          width: 74.27,
                          height: 17.14,
                          decoration: ShapeDecoration(
                            color: Color(0xFFEEEEEE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 34.68,
                        top: 6.66,
                        child: SizedBox(
                          width: 64.32,
                          height: 13.57,
                          child: Text(
                            '20.000',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Gmarket Sans TTF',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 47,
                top: 423,
                child: Container(
                  width: 238,
                  height: 46,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 238,
                          height: 46,
                          decoration: ShapeDecoration(
                            color: Color(0xFF93A5AD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 5,
                        child: SizedBox(
                          width: 230,
                          height: 38,
                          child: Text(
                            '지난 주에 20,000원을 아껴서\n                       를 리워드로 받았어!',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'Gmarket Sans TTF',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 284.59,
                top: 464.61,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(-2.59),
                  child: Container(
                    width: 30,
                    height: 23,
                    decoration: ShapeDecoration(
                      color: Color(0xFF93A5AD),
                      shape: StarBorder.polygon(sides: 3),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 43,
                top: 500,
                child: Container(
                  width: 54,
                  height: 81,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://via.placeholder.com/54x81"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 54,
                top: 590,
                child: Container(
                  width: 282,
                  height: 77,
                  decoration: ShapeDecoration(
                    color: Color(0xFFC9DEE8),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 2, color: Color(0xFF98AAB2)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 305,
                top: 639,
                child: Container(
                  width: 24,
                  height: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(width: 16, height: 18, child: Stack()),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 55,
                top: 695,
                child: Container(
                  width: 282,
                  height: 77,
                  decoration: ShapeDecoration(
                    color: Color(0xFFC9DEE8),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 2, color: Color(0xFF98AAB2)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 307,
                top: 747,
                child: Container(
                  width: 24,
                  height: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(width: 16, height: 18, child: Stack()),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 135,
                top: 612,
                child: SizedBox(
                  width: 92,
                  height: 53,
                  child: Text(
                    '나이키위',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 23,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 147,
                top: 713,
                child: SizedBox(
                  width: 68,
                  height: 24,
                  child: Text(
                    '따뜻한 패딩',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 69,
                top: 608,
                child: Container(
                  width: 59,
                  height: 44,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: FlutterLogo(),
                ),
              ),
              Positioned(
                left: 69,
                top: 696,
                child: Container(
                  width: 66,
                  height: 63,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: FlutterLogo(),
                ),
              ),
              Positioned(
                left: 210,
                top: 724,
                child: SizedBox(
                  width: 119,
                  height: 24,
                  child: Text(
                    '\$350,000',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 23,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 222,
                top: 614,
                child: SizedBox(
                  width: 148,
                  height: 36,
                  child: Text(
                    '\$150,000',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 23,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 51,
                top: 338,
                child: SizedBox(
                  width: 46,
                  height: 19,
                  child: Text(
                    '식비',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 308,
                top: 338,
                child: SizedBox(
                  width: 49,
                  height: 17,
                  child: Text(
                    '기타',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 263,
                top: 230,
                child: Text(
                  '500,000',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Gmarket Sans TTF',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 290,
                top: 395,
                child: Text(
                  '500,000',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Gmarket Sans TTF',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 135,
                top: 139,
                child: Text(
                  '금주 지출 목표',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Gmarket Sans TTF',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 139,
                top: 299,
                child: Text(
                  '지난 주 지출 내역\n',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Gmarket Sans TTF',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 58,
                top: 63,
                child: SizedBox(
                  width: 277,
                  height: 48,
                  child: Text(
                    '금주 지출 목표',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 53,
                top: 163,
                child: Container(
                  width: 288,
                  height: 65,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://via.placeholder.com/288x65"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 132,
                top: 181,
                child: Container(
                  width: 195,
                  height: 32,
                  decoration: ShapeDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
                  ),
                ),
              ),
              Positioned(
                left: 66,
                top: 181,
                child: Container(
                  width: 102,
                  height: 32,
                  decoration: ShapeDecoration(
                    color: Color(0xFFFF3B30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        bottomLeft: Radius.circular(7),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 333,
                top: 228,
                child: Container(height: 20.81, child: Stack()),
              ),
              Positioned(
                left: 287,
                top: 413,
                child: Container(
                  width: 46,
                  height: 75,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://via.placeholder.com/46x75"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 134,
                top: 565,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(-1.57),
                  child: Container(
                    width: 30,
                    height: 29,
                    decoration: ShapeDecoration(
                      color: Color(0xFF93A5AD),
                      shape: StarBorder.polygon(sides: 3),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 102,
                top: 505,
                child: Container(
                  width: 238,
                  height: 46,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 238,
                          height: 46,
                          decoration: ShapeDecoration(
                            color: Color(0xFF93A5AD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 5,
                        top: 8,
                        child: SizedBox(
                          width: 230,
                          height: 38,
                          child: Text(
                            '지출을 줄였다면, 살 수 있었던\n물건들을 알려줄게!',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'Gmarket Sans TTF',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 323,
                top: 556,
                child: Container(
                  width: 28,
                  height: 28,
                  padding: const EdgeInsets.only(
                    top: 3.25,
                    left: 3.19,
                    right: 3.20,
                    bottom: 3.25,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [],
                  ),
                ),
              ),
              Positioned(
                left: 15,
                top: 12,
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.only(
                      top: 6, left: 4, right: 4, bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildGoalProgressBar() {
  return Stack(
    children: [
      Container(
        width: 300,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(7),
        ),
      ),
      Container(
        width: 120, // Progress
        height: 32,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(7),
            bottomLeft: Radius.circular(7),
          ),
        ),
      ),
    ],
  );
}

Widget _buildRewardCard() {
  return Container(
    padding: const EdgeInsets.all(10),
    width: 350,
    decoration: BoxDecoration(
      color: const Color(0xFFC9DEE8),
      border: Border.all(color: const Color(0xFF98AAB2), width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '지난 주에 20,000원을 아껴서\n"나이키위"를 리워드로 받았어!',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlutterLogo(size: 50),
            Text(
              '\$150,000',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildExpensesList() {
  return Column(
    children: [
      _buildExpenseItem('식비', '\$500,000', Colors.blue),
      const SizedBox(height: 10),
      _buildExpenseItem('기타', '\$500,000', Colors.orange),
    ],
  );
}

Widget _buildExpenseItem(String category, String amount, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        category,
        style: TextStyle(fontSize: 18, color: color),
      ),
      Text(
        amount,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ],
  );
}

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String _nickname = 'nickname';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 393,
          height: 852,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Color(0xFF93A5AD)),
          child: Stack(
            children: [
              Positioned(
                left: 27,
                top: 242,
                child: Container(
                  width: 333,
                  height: 578,
                  decoration: ShapeDecoration(
                    color: Color(0xFFEEEEEE),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 3, color: Color(0xFF93A5AD)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              // 중간 생략...
              Positioned(
                left: 156,
                top: 131,
                child: Container(
                  width: 178,
                  height: 32,
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
                        offset: Offset(0, 5),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 닉네임 텍스트
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          _nickname,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'Gmarket Sans TTF',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // 수정 아이콘
                      IconButton(
                        icon: Icon(Icons.edit, size: 18, color: Colors.black),
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
                                      Navigator.of(context).pop(); // 다이얼로그 닫기
                                    },
                                    child: Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _nickname = nicknameController.text;
                                      });
                                      Navigator.of(context).pop(); // 다이얼로그 닫기
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
            ],
          ),
        ),
      ],
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
      totalExpense =
          expenseList.fold(0.0, (sum, e) => sum + (e['amount'] ?? 0.0));
    }

    if (incomeData != null) {
      List<dynamic> incomeList = jsonDecode(incomeData);
      totalIncome =
          incomeList.fold(0.0, (sum, e) => sum + (e['amount'] ?? 0.0));
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
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPage(selectedDate: selectedDay),
                        ),
                      );
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

// 소비 내역 자세히 보기
class Detail extends StatefulWidget {
  final List<Map<String, dynamic>> records; // 소비 내역
  final String selectedMonth; // 선택한 달

  Detail({required this.records, required this.selectedMonth});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  String? selectedCategory; // 선택된 카테고리
  double totalAmount = 0.0; // 총 소비 금액
  Map<String, double> categoryTotals = {}; // 카테고리별 총 금액

  // 카테고리 색상 맵
  final Map<String, Color> categoryColors = {
    '식비': Colors.orange,
    '쇼핑': Colors.green,
    '이체': Colors.blue,
    '기타': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() {
    // 전체 금액 및 카테고리별 합계 계산
    double total = 0.0;
    Map<String, double> tempCategoryTotals = {};

    for (var record in widget.records) {
      if (record['month'] == widget.selectedMonth) {
        final category = record['category'];
        final amount = record['amount'] ?? 0.0;

        total += amount;

        if (tempCategoryTotals.containsKey(category)) {
          tempCategoryTotals[category] = tempCategoryTotals[category]! + amount;
        } else {
          tempCategoryTotals[category] = amount;
        }
      }
    }

    setState(() {
      totalAmount = total;
      categoryTotals = tempCategoryTotals;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 카테고리에 해당하는 내역 필터링
    final filteredRecords = selectedCategory == null
        ? []
        : widget.records
            .where((record) =>
                record['month'] == widget.selectedMonth &&
                record['category'] == selectedCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedMonth} 소비 내역'),
      ),
      body: Column(
        children: [
          // 총 소비 금액 표시
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${widget.selectedMonth} 총 소비 금액: ${totalAmount.toStringAsFixed(0)}원',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // 카테고리별 비율 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: categoryTotals.keys.map((category) {
                final percentage =
                    (categoryTotals[category]! / totalAmount) * 100;
                return Flexible(
                  flex: percentage.toInt(),
                  child: Container(
                    height: 20,
                    color: categoryColors[category],
                  ),
                );
              }).toList(),
            ),
          ),

          // 카테고리 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: categoryTotals.keys.map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: selectedCategory == category
                          ? categoryColors[category]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: categoryColors[category]!),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: selectedCategory == category
                            ? Colors.white
                            : categoryColors[category],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 선택된 카테고리 내역
          Expanded(
            child: selectedCategory == null
                ? Center(child: Text('카테고리를 선택하세요.'))
                : ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      return ListTile(
                        title: Text(record['description']),
                        trailing: Text('${record['amount']}원'),
                      );
                    },
                  ),
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
            _buildTableCell('삭제', isHeader: true),
          ],
        ),
        ...filteredRecords.map((record) {
          return TableRow(
            children: [
              _buildTableCell(record['category'] ?? ''),
              _buildTableCell(record['content'] ?? ''),
              _buildTableCell(record['amount'] ?? ''),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    records.remove(record);
                  });
                  _saveData();
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

    showDialog(
      context: context,
      builder: (context) {
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
                  selectedCategory = value;
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final record = {
                    'category': selectedCategory ?? '',
                    'content': content,
                    'amount': amount,
                    'date': _selectedDay.toString(),
                  };
                  if (isExpense) {
                    expenseRecords.add(record);
                  } else {
                    incomeRecords.add(record);
                  }
                });
                _saveData();
                Navigator.pop(context);
              },
              child: Text('추가'),
            ),
          ],
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

class EcoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 393,
              height: 852,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: MediaQuery.of(context).size.height * 1.0,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter, // 상단 중앙 정렬
                    child: Padding(
                      padding: const EdgeInsets.only(top: 59), // 상단 여백 조정
                      child: Text(
                        '경제 지식',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    top: 40,
                    child: Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back), // 뒤로 가기 화살표 아이콘
                        onPressed: () {
                          Navigator.pop(context); // 뒤로 가기 동작
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 44,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/eco');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                      child: const Text(
                        "동영상", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 113,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/card');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "카드뉴스", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 182,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/web');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "웹툰", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 251,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/han');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "한은소식", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 27,
                    top: 186,
                    child: Container(
                      width: 340,
                      height: 644,
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
                                  margin: EdgeInsets.all(10),
                                  width: 294,
                                  height: 111,
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
                                  left: 20,
                                  top: 30,
                                  child: Container(
                                    width: 139.13,
                                    height: 79,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/image${i + 1}.png'), // 로컬 이미지 불러오기
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 180,
                                  top: 30,
                                  child: Container(
                                    width: 100,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/image${i + 6}.png'), // 로컬 이미지 불러오기
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 180,
                                  top: 90,
                                  child: Container(
                                    width: 100,
                                    height: 18,
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
                                  left: 205,
                                  top: 90,
                                  child: SizedBox(
                                    width: 54,
                                    height: 15,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final Uri url = Uri.parse(
                                            'https://www.bok.or.kr/portal/bbs/B0000535/view.do?nttId=10087964&searchCnd=1&searchKwd=&pageUnit=12&depth=201151&pageIndex=2&menuNo=201721&oldMenuNo=201151&programType=multiCont');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Text(
                                        '동영상 보기',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 393,
              height: 852,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: MediaQuery.of(context).size.height * 1.0,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter, // 상단 중앙 정렬
                    child: Padding(
                      padding: const EdgeInsets.only(top: 59), // 상단 여백 조정
                      child: Text(
                        '경제 지식',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    top: 40,
                    child: Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back), // 뒤로 가기 화살표 아이콘
                        onPressed: () {
                          Navigator.pop(context); // 뒤로 가기 동작
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 44,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/eco');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "동영상", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 113,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/card');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Colors.white),
                      child: const Text(
                        "카드뉴스", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 182,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/web');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "웹툰", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 251,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/han');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "한은소식", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 27,
                    top: 186,
                    child: Container(
                      width: 340,
                      height: 644,
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
                                  margin: EdgeInsets.all(10),
                                  width: 294,
                                  height: 111,
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
                                  left: 20,
                                  top: 30,
                                  child: Container(
                                    width: 139.13,
                                    height: 79,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/${i * 2 + 1}.png'), // 로컬 이미지 불러오기
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 180,
                                  top: 30,
                                  child: Container(
                                    width: 100,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/${2 * (i + 1)}.png'), // 로컬 이미지 불러오기
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 180,
                                  top: 90,
                                  child: Container(
                                    width: 100,
                                    height: 18,
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
                                  left: 200,
                                  top: 90,
                                  child: SizedBox(
                                    width: 70,
                                    height: 15,
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
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
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

class webPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 393,
              height: 852,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: MediaQuery.of(context).size.height * 1.0,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter, // 상단 중앙 정렬
                    child: Padding(
                      padding: const EdgeInsets.only(top: 59), // 상단 여백 조정
                      child: Text(
                        '경제 지식',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    top: 40,
                    child: Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back), // 뒤로 가기 화살표 아이콘
                        onPressed: () {
                          Navigator.pop(context); // 뒤로 가기 동작
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 44,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/eco');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "동영상", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 113,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/card');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "카드뉴스", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 182,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/web');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Colors.white),
                      child: const Text(
                        "웹툰", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 251,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/han');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "한은소식", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 27,
                    top: 186,
                    child: Container(
                      width: 340,
                      height: 644,
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
                          for (var i = 0; i < 8; i++) ...[
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  width: 294,
                                  height: 111,
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
                                  left: 20,
                                  top: 30,
                                  child: Container(
                                    width: 139.13,
                                    height: 79,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/img${i + 1}.png'), // 로컬 이미지 불러오기
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 180,
                                  top: 30,
                                  child: Container(
                                    width: 100,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/img${i + 9}.png'), // 로컬 이미지 불러오기
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 180,
                                  top: 90,
                                  child: Container(
                                    width: 100,
                                    height: 18,
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
                                  left: 205,
                                  top: 90,
                                  child: SizedBox(
                                    width: 54,
                                    height: 15,
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
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
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

class hanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 393,
              height: 852,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: MediaQuery.of(context).size.height * 1.0,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter, // 상단 중앙 정렬
                    child: Padding(
                      padding: const EdgeInsets.only(top: 59), // 상단 여백 조정
                      child: Text(
                        '경제 지식',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    top: 40,
                    child: Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back), // 뒤로 가기 화살표 아이콘
                        onPressed: () {
                          Navigator.pop(context); // 뒤로 가기 동작
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 44,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/eco');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "동영상", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 113,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/card');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "카드뉴스", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 182,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/web');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "웹툰", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 251,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/han');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Colors.white),
                      child: const Text(
                        "한은소식", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 27,
                    top: 186,
                    child: Container(
                      width: 340,
                      height: 644,
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
                                  margin: EdgeInsets.all(10),
                                  width: 294,
                                  height: 111,
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
                                  left: 20,
                                  top: 30,
                                  child: Container(
                                    width: 139.13,
                                    height: 79,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/han${i + 1}.png'), // 로컬 이미지 불러오기
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 180,
                                  top: 30,
                                  child: Container(
                                    width: 100,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/han${i + 7}.png'), // 로컬 이미지 불러오기
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 180,
                                  top: 90,
                                  child: Container(
                                    width: 100,
                                    height: 18,
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
                                  left: 200,
                                  top: 90,
                                  child: SizedBox(
                                    width: 70,
                                    height: 15,
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
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
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

class CommunityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 393,
          height: 852,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 393,
                  height: 852,
                  decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                ),
              ),
              Positioned(
                left: 120,
                top: 63,
                child: Text(
                  '커뮤니티',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontFamily: 'Gmarket Sans TTF',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 27,
                top: 122,
                child: Container(
                  width: 340,
                  height: 697,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 3, color: Color(0xFF93A5AD)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 27,
                top: 122,
                child: Container(
                  width: 340,
                  height: 697,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 3, color: Color(0xFF93A5AD)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 54,
                top: 149,
                child: Container(
                  width: 286,
                  height: 56,
                  decoration: ShapeDecoration(
                    color: Color(0xFF93A5AD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 54,
                top: 331,
                child: Container(
                  width: 286,
                  height: 56,
                  decoration: ShapeDecoration(
                    color: Color(0xFF93A5AD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 54,
                top: 240,
                child: Container(
                  width: 286,
                  height: 56,
                  decoration: ShapeDecoration(
                    color: Color(0xFF93A5AD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 54,
                top: 240,
                child: Container(
                  width: 286,
                  height: 56,
                  decoration: ShapeDecoration(
                    color: Color(0xFF93A5AD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 54,
                top: 513,
                child: Container(
                  width: 286,
                  height: 108,
                  decoration: ShapeDecoration(
                    color: Color(0xFF93A5AD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 54,
                top: 422,
                child: Container(
                  width: 286,
                  height: 56,
                  decoration: ShapeDecoration(
                    color: Color(0xFFBCBCBC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 54,
                top: 656,
                child: Container(
                  width: 286,
                  height: 56,
                  decoration: ShapeDecoration(
                    color: Color(0xFFBCBCBC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 89,
                top: 225,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(-1.57),
                  child: Container(
                    width: 40,
                    height: 25,
                    decoration: ShapeDecoration(
                      color: Color(0xFF93A5AD),
                      shape: StarBorder.polygon(sides: 3),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 89,
                top: 316,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(-1.57),
                  child: Container(
                    width: 40,
                    height: 25,
                    decoration: ShapeDecoration(
                      color: Color(0xFF93A5AD),
                      shape: StarBorder.polygon(sides: 3),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 89,
                top: 407,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(-1.57),
                  child: Container(
                    width: 40,
                    height: 25,
                    decoration: ShapeDecoration(
                      color: Color(0xFF93A5AD),
                      shape: StarBorder.polygon(sides: 3),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 89,
                top: 641,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(-1.57),
                  child: Container(
                    width: 40,
                    height: 25,
                    decoration: ShapeDecoration(
                      color: Color(0xFF93A5AD),
                      shape: StarBorder.polygon(sides: 3),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 300,
                top: 498,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(-1.57),
                  child: Container(
                    width: 40,
                    height: 25,
                    decoration: ShapeDecoration(
                      color: Color(0xFFBCBCBC),
                      shape: StarBorder.polygon(
                        side: BorderSide(width: 2, color: Color(0xFFBCBCBC)),
                        sides: 3,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 300,
                top: 732,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(-1.57),
                  child: Container(
                    width: 40,
                    height: 25,
                    decoration: ShapeDecoration(
                      color: Color(0xFFBCBCBC),
                      shape: StarBorder.polygon(
                        side: BorderSide(width: 2, color: Color(0xFFBCBCBC)),
                        sides: 3,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 29,
                top: 740,
                child: Container(
                  width: 338,
                  height: 77,
                  decoration: ShapeDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 46,
                top: 756,
                child: Opacity(
                  opacity: 0.20,
                  child: Container(
                    width: 254,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 4),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 307,
                top: 756,
                child: Container(
                  width: 47,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 313,
                top: 762,
                child: SizedBox(
                  width: 39,
                  height: 23,
                  child: Text(
                    '전송',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 61,
                top: 673,
                child: Text(
                  '주식 잘 아시는 분 있으실까요??',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontFamily: 'Gmarket Sans TTF',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 64,
                top: 428,
                child: SizedBox(
                  width: 264,
                  height: 53,
                  child: Text(
                    '오늘도 화이팅! 다같이 절약합시당!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 64,
                top: 524,
                child: SizedBox(
                  width: 264,
                  height: 97,
                  child: Text(
                    '안녕하세요 이번에 처음 들어왔는데 잘부탁드려용 요즘 너무 과소비해서... 다음달엔 줄이도록 노력해보겠습니다!!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 61,
                top: 338,
                child: SizedBox(
                  width: 283,
                  height: 52,
                  child: Text(
                    '저 이번 달에 평소보다 20만원이나 줄였어요!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 71,
                top: 149,
                child: Text(
                  '저 이번 달에 평소보다 20만원이나 줄였어요!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontFamily: 'Gmarket Sans TTF',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 71,
                top: 253,
                child: SizedBox(
                  width: 283,
                  height: 52,
                  child: Text(
                    '휴... 전 30만원이나 더썼네요... \n',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 305,
                top: 188,
                child: SizedBox(
                  width: 30,
                  height: 21,
                  child: Text(
                    '신고',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 15,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 304,
                top: 279,
                child: SizedBox(
                  width: 30,
                  height: 21,
                  child: Text(
                    '신고',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 15,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 307,
                top: 694,
                child: SizedBox(
                  width: 30,
                  height: 21,
                  child: Text(
                    '신고',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 15,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 304,
                top: 461,
                child: SizedBox(
                  width: 30,
                  height: 21,
                  child: Text(
                    '신고',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 15,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 306,
                top: 603,
                child: SizedBox(
                  width: 30,
                  height: 21,
                  child: Text(
                    '신고',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 15,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 306,
                top: 369,
                child: SizedBox(
                  width: 30,
                  height: 21,
                  child: Text(
                    '신고',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 15,
                      fontFamily: 'Gmarket Sans TTF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 15,
                top: 12,
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.only(
                      top: 6, left: 4, right: 4, bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class foodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 393,
              height: 852,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: MediaQuery.of(context).size.height * 1.0,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter, // 상단 중앙 정렬
                    child: Padding(
                      padding: const EdgeInsets.only(top: 59), // 상단 여백 조정
                      child: Text(
                        'SHOP',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    top: 40,
                    child: Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back), // 뒤로 가기 화살표 아이콘
                        onPressed: () {
                          Navigator.pop(context); // 뒤로 가기 동작
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 44,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/food');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                      child: const Text(
                        "음식", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 113,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/drink');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "음료", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 182,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/color');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "색변경", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 27,
                    top: 186,
                    child: Container(
                      width: 340,
                      height: 644,
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
                                  margin: EdgeInsets.all(10),
                                  width: 294,
                                  height: 111,
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
                                  left: 20,
                                  top: 30,
                                  child: Container(
                                    width: 70,
                                    height: 70,
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
                                  left: 110,
                                  top: 50,
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Text(
                                      '키위',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 185,
                                  top: 50,
                                  child: SizedBox(
                                    width: 150,
                                    height: 70,
                                    child: Text(
                                      '\$1,500',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
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

class drinkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 393,
              height: 852,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: MediaQuery.of(context).size.height * 1.0,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter, // 상단 중앙 정렬
                    child: Padding(
                      padding: const EdgeInsets.only(top: 59), // 상단 여백 조정
                      child: Text(
                        'SHOP',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    top: 40,
                    child: Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back), // 뒤로 가기 화살표 아이콘
                        onPressed: () {
                          Navigator.pop(context); // 뒤로 가기 동작
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 44,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/food');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "음식", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 113,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/drink');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Colors.white),
                      child: const Text(
                        "음료", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 182,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/color');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "색변경", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 27,
                    top: 186,
                    child: Container(
                      width: 340,
                      height: 644,
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
                                  margin: EdgeInsets.all(10),
                                  width: 294,
                                  height: 111,
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
                                  left: 20,
                                  top: 30,
                                  child: Container(
                                    width: 70,
                                    height: 70,
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
                                  left: 110,
                                  top: 50,
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Text(
                                      '물',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 185,
                                  top: 50,
                                  child: SizedBox(
                                    width: 150,
                                    height: 70,
                                    child: Text(
                                      '\$1,000',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
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

class colorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 393,
              height: 852,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: MediaQuery.of(context).size.height * 1.0,
                      decoration: BoxDecoration(color: Color(0xFF93A5AD)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter, // 상단 중앙 정렬
                    child: Padding(
                      padding: const EdgeInsets.only(top: 59), // 상단 여백 조정
                      child: Text(
                        'SHOP',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35,
                          fontFamily: 'Gmarket Sans TTF',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    top: 40,
                    child: Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back), // 뒤로 가기 화살표 아이콘
                        onPressed: () {
                          Navigator.pop(context); // 뒤로 가기 동작
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 44,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/food');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "음식", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 113,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/drink');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Color(0xFF93A5AD)),
                      child: const Text(
                        "음료", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 182,
                    top: 117,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/color');
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3,
                              color: Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          backgroundColor: Colors.white),
                      child: const Text(
                        "색변경", // 버튼 텍스트
                        style: TextStyle(
                          color: Colors.black, // 텍스트 색상
                          fontSize: 14, // 텍스트 크기
                          fontWeight: FontWeight.bold, // 텍스트 두께
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 27,
                    top: 186,
                    child: Container(
                      width: 340,
                      height: 644,
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
                          for (var i = 0; i < 8; i++) ...[
                            Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  width: 294,
                                  height: 111,
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
                                  left: 20,
                                  top: 30,
                                  child: Container(
                                    width: 70,
                                    height: 70,
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
                                  left: 110,
                                  top: 50,
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Text(
                                      '빨강',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 185,
                                  top: 50,
                                  child: SizedBox(
                                    width: 150,
                                    height: 70,
                                    child: Text(
                                      '\$1,000',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
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
