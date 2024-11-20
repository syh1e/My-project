import 'package:comya_app/map.dart';
import 'package:flutter/material.dart';

class SetPage extends StatefulWidget {
  const SetPage({Key? key}) : super(key: key);

  @override
  _SetPageState createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  int currentHour = 0;
  int currentMinute = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours wheel
                SizedBox(
                  width: 70,
                  height: 200,
                  child: ListWheelScrollView.useDelegate(
                    onSelectedItemChanged: (value) {
                      setState(() {
                        currentHour = value;
                      });
                    },
                    itemExtent: 55,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 13,
                      builder: (context, index) {
                        return MyHours(
                          hours: index,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '시간',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                // Minutes wheel
                SizedBox(
                  width: 70,
                  height: 200,
                  child: ListWheelScrollView.useDelegate(
                    onSelectedItemChanged: (value) {
                      setState(() {
                        currentMinute = value;
                      });
                    },
                    itemExtent: 55,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 60,
                      builder: (context, index) {
                        return MyMinutes(
                          mins: index,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '분',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 시간과 분을 다음 페이지로 전달
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmPage1(
                      selectedHour: currentHour,
                      selectedMinute: currentMinute,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                "다음 페이지로 이동",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHours extends StatelessWidget {
  final int hours;

  MyHours({required this.hours});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        child: Center(
          child: Text(
            hours.toString(),
            style: TextStyle(
                fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class MyMinutes extends StatelessWidget {
  final int mins;

  MyMinutes({required this.mins});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        child: Center(
          child: Text(
            mins < 10 ? '0' + mins.toString() : mins.toString(),
            style: TextStyle(
                fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class ConfirmPage1 extends StatelessWidget {
  final int selectedHour;
  final int selectedMinute;

  const ConfirmPage1(
      {Key? key, required this.selectedHour, required this.selectedMinute})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 계산된 거리
    double searchRadiusKm = (selectedHour * 60 + selectedMinute) * 0.1;

    return Scaffold(
      appBar: AppBar(
        title: Text("확인 페이지"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "선택된 시간: $selectedHour시간 $selectedMinute분",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Yes Button - Navigate to next page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MapPage(searchRadiusKm: searchRadiusKm),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                "예",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            // No Button - Go back to previous page
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                "아니요",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SetPage2 extends StatefulWidget {
  const SetPage2({Key? key}) : super(key: key);

  @override
  _SetPage2State createState() => _SetPage2State();
}

class _SetPage2State extends State<SetPage2> {
  double currentKms = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // km wheel
                SizedBox(
                  width: 70,
                  height: 200,
                  child: ListWheelScrollView.useDelegate(
                    onSelectedItemChanged: (value) {
                      setState(() {
                        currentKms = value * 0.1; // 0.1 간격으로 증가
                      });
                    },
                    itemExtent: 55,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 70, // 0.0부터 6.9까지
                      builder: (context, index) {
                        return MyKms(kms: index * 0.1); // 0.1 간격으로 설정
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'km',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 선택한 거리 값을 ConfirmPage2로 전달
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmPage2(
                      selectedKm: currentKms,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                "다음 페이지로 이동",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmPage2 extends StatelessWidget {
  final double selectedKm;

  const ConfirmPage2({Key? key, required this.selectedKm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 계산된 거리
    double searchRadiusKm = selectedKm;

    return Scaffold(
      appBar: AppBar(
        title: Text("확인 페이지"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "선택된 거리: ${searchRadiusKm.toStringAsFixed(1)} km",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Yes Button - Navigate to next page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MapPage(searchRadiusKm: searchRadiusKm),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                "예",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            // No Button - Go back to previous page
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                "아니요",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyKms extends StatelessWidget {
  final double kms;

  MyKms({required this.kms});

  @override
  Widget build(BuildContext context) {
    // km 값이 소수점 한 자리까지 표시
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        child: Center(
          child: Text(
            kms.toStringAsFixed(1) + " km", // 소수점 한 자리까지 표시
            style: TextStyle(
                fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
