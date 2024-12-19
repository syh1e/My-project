import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppState with ChangeNotifier {
  // Variables
  String _name = 'nickname';
  int _points = 100;
  double _thisMonthIncome = 10000.0;
  double _thisMonthSpending = 5000.0;
  double _weeklyGoal = 100000.0;
  double _weeklySpending = 5000.0;
  double _lastWeekGoal = 100000.0;
  double _lastWeekSpending = 50000.0;

  List<Map<String, String>> _expenseRecords = [];
  List<Map<String, String>> _incomeRecords = [];
  List<String> _expenseCategories = [];
  List<String> _incomeCategories = [];

  // Getters
  String get name => _name;
  int get points => _points;
  double get thisMonthIncome => _thisMonthIncome;
  double get thisMonthSpending => _thisMonthSpending;
  double get weeklyGoal => _weeklyGoal;
  double get weeklySpending => _weeklySpending;
  double get lastWeekGoal => _lastWeekGoal;
  double get lastWeekSpending => _lastWeekSpending;
  List<Map<String, String>> get expenseRecords => _expenseRecords;
  List<Map<String, String>> get incomeRecords => _incomeRecords;
  List<String> get expenseCategories => _expenseCategories;
  List<String> get incomeCategories => _incomeCategories;

  // Load all data from SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load simple data
    _name = prefs.getString('name') ?? 'nickname';
    _points = prefs.getInt('points') ?? 100;
    _thisMonthIncome = prefs.getDouble('thisMonthIncome') ?? 10000.0;
    _thisMonthSpending = prefs.getDouble('thisMonthSpending') ?? 5000.0;
    _weeklyGoal = prefs.getDouble('weeklyGoal') ?? 100000.0;
    _weeklySpending = prefs.getDouble('weeklySpending') ?? 5000.0;
    _lastWeekGoal = prefs.getDouble('lastWeekGoal') ?? 100000.0;
    _lastWeekSpending = prefs.getDouble('lastWeekSpending') ?? 50000.0;

    String? expenseData = prefs.getString('expenseRecords');
    if (expenseData != null) {
      List<dynamic> expenseList = jsonDecode(expenseData);
      _expenseRecords =
          expenseList.map((e) => Map<String, String>.from(e)).toList();
    }

    String? incomeData = prefs.getString('incomeRecords');
    if (incomeData != null) {
      List<dynamic> incomeList = jsonDecode(incomeData);
      _incomeRecords =
          incomeList.map((e) => Map<String, String>.from(e)).toList();
    }

    String? expenseCategoriesData = prefs.getString('expenseCategories');
    if (expenseCategoriesData != null) {
      _expenseCategories = List<String>.from(jsonDecode(expenseCategoriesData));
    }

    String? incomeCategoriesData = prefs.getString('incomeCategories');
    if (incomeCategoriesData != null) {
      _incomeCategories = List<String>.from(jsonDecode(incomeCategoriesData));
    }
    notifyListeners();
  }

  // Save all data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save simple data
    prefs.setString('name', _name);
    prefs.setInt('points', _points);
    prefs.setDouble('thisMonthIncome', _thisMonthIncome);
    prefs.setDouble('thisMonthSpending', _thisMonthSpending);
    prefs.setDouble('weeklyGoal', _weeklyGoal);
    prefs.setDouble('weeklySpending', _weeklySpending);
    prefs.setDouble('lastWeekGoal', _lastWeekGoal);
    prefs.setDouble('lastWeekSpending', _lastWeekSpending);

    // Save records and categories
    prefs.setString('expenseRecords', jsonEncode(_expenseRecords));
    prefs.setString('incomeRecords', jsonEncode(_incomeRecords));
    prefs.setString('expenseCategories', jsonEncode(_expenseCategories));
    prefs.setString('incomeCategories', jsonEncode(_incomeCategories));

    notifyListeners();
  }

  // Update simple data
  Future<void> updateName(String newName) async {
    _name = newName;
    await _saveData();
  }

  Future<void> updatePoints(int pointsDelta) async {
    _points += pointsDelta; // pointsDelta가 양수일 경우 포인트가 증가하고, 음수일 경우 감소합니다.
    await _saveData();
  }

  Future<void> addThisMonthSpending(double amount) async {
    _thisMonthSpending += amount;
    await _saveData();
  }

  Future<void> addThisMonthIncome(double amount) async {
    _thisMonthIncome += amount;
    await _saveData();
  }

  Future<void> setWeeklyGoal(double goal) async {
    _weeklyGoal = goal;
    await _saveData();
  }

  Future<void> updateWeeklySpending(double amount) async {
    _weeklySpending += amount;
    await _saveData();
  }

  Future<void> setLastWeekGoal(double goal) async {
    _lastWeekGoal = goal;
    await _saveData();
  }

  Future<void> updateLastWeekSpending(double amount) async {
    _lastWeekSpending += amount;
    await _saveData();
  }

  Future<void> addRecord({
    required bool isExpense,
    required String category,
    required String content,
    required String amount,
    required String date,
  }) async {
    final record = {
      'category': category,
      'content': content,
      'amount': amount,
      'date': date,
    };

    if (isExpense) {
      _expenseRecords.add(record);
      _thisMonthSpending += double.parse(amount);
    } else {
      _incomeRecords.add(record);
      _thisMonthIncome += double.parse(amount);
    }
    await _saveData();
  }

  Future<void> addCategory(bool isExpense, String category) async {
    if (category.isNotEmpty) {
      if (isExpense) {
        _expenseCategories.add(category);
      } else {
        _incomeCategories.add(category);
      }
      await _saveData();
    }
  }

  Future<void> removeCategory(bool isExpense, String category) async {
    if (isExpense) {
      _expenseCategories.remove(category);
    } else {
      _incomeCategories.remove(category);
    }
    await _saveData();
  }

/*

  Future<void> addRecordDialog(bool isExpense) async {
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
              onPressed: () => Navigator.pop(context, true),
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
                Navigator.pop(context, true);
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
    
    await _saveData();
  }

  Future<void> manageCategories(bool isExpense) async {
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
    
    await _saveData();
  }*/
}
