import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;

        return Column(
          children: [
            Container(
              width: screenWidth, // 화면의 너비에 맞게 조정
              height: screenHeight, // 화면의 높이에 맞게 조정
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: screenHeight * 0.75, // 75% 위치로 조정
                    child: Container(
                      width: screenWidth,
                      height: screenHeight * 0.15, // 화면의 15% 높이
                      decoration: BoxDecoration(color: Color(0xFFBCBCBC)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: screenHeight * 0.115), // 하단 여백을 화면 높이에 맞게 조정
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/month');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFDDDDDD),
                              fixedSize: Size(screenWidth * 0.25,
                                  screenWidth * 0.25), // 버튼 크기를 화면 크기에 맞게 조정
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              '이달의\n내역',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.05, // 글자 크기 비율로 조정
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
                  Positioned(
                    left: screenWidth * 0.18,
                    top: screenHeight * 0.93, // 텍스트 위치를 화면 크기에 맞게 조정
                    child: Text(
                      '티끌 모아 태산',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.1, // 글자 크기 비율로 조정
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.77,
                    top: screenHeight * 0.18,
                    child: Text(
                      '500,000',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.04, // 글자 크기 비율로 조정
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.37,
                    top: screenHeight * 0.075,
                    child: Text(
                      '금주 지출 목표',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.03,
                    top: screenHeight * 0.66, // 위치를 상대적으로 조정
                    child: Container(
                      width: screenWidth * 0.3, // 크기를 화면에 맞게 조정
                      height: screenHeight * 0.07, // 크기를 화면에 맞게 조정
                      decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.05,
                    top: screenHeight * 0.68,
                    child: Text(
                      '상태',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.19,
                    top: screenHeight * 0.67,
                    child: Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [],
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.79,
                    top: screenHeight * 0.65,
                    child: Container(
                      width: screenWidth * 0.16,
                      height: screenHeight * 0.08,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.67, vertical: 5.08),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [],
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.22,
                    top: screenHeight * 0.22,
                    child: Container(
                      width: screenWidth * 0.56, // 크기를 화면에 맞게 조정
                      height: screenHeight * 0.42, // 크기를 화면에 맞게 조정
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              "https://via.placeholder.com/220x357"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.17,
                    top: screenHeight * 0.12,
                    child: Container(
                      width: screenWidth * 0.63, // 크기 비율로 조정
                      height: screenHeight * 0.06, // 크기 비율로 조정
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.2,
                    top: screenHeight * 0.13,
                    child: Container(
                      width: screenWidth * 0.25, // 크기 비율로 조정
                      height: screenHeight * 0.04, // 크기 비율로 조정
                      decoration: BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.87,
                    top: screenHeight * 0.12,
                    child: Container(
                      width: screenWidth * 0.07, // 크기 비율로 조정
                      height: screenHeight * 0.07, // 크기 비율로 조정
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [],
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.65,
                    top: screenHeight * 0.67,
                    child: Container(
                      width: screenWidth * 0.08,
                      height: screenWidth * 0.08, // 크기 비율로 조정
                      padding: const EdgeInsets.all(7.62),
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
      },
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
    return Column();
  }
}

class CommunityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column();
  }
}
