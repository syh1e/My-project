import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MaterialApp(
    title: "App Default",
    initialRoute: '/',
    routes: {
      '/': (context) => homepage(),
      '/login': (context) => loginpage(),
      '/select1': (context) => select1page(),
      '/walk': (context) => walkpage(),
      '/run': (context) => runpage(),
    },
  ));
}

class homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text("Button"),
            )
          ],
        ),
      ),
    );
  }
}

class loginpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "LOGIN",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Color(0xFFAFCCA9),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 100),
                child: Icon(
                  CupertinoIcons.person_crop_circle,
                  color: Color(0x9A7A7D7A),
                  size: 150,
                ),
              ),
              Padding(
                // padding: const EdgeInsets.all(8.0),
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
                    decoration: InputDecoration(
                      labelText: "user name",
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                  ),
                ),
              ),
              Padding(
                // padding: const EdgeInsets.all(8.0),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/select1');
                  },
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Color(0x9A7A7D7A).withOpacity(0.2),
                    backgroundColor: Color(0xFF89BE63).withOpacity(0.5),
                    foregroundColor: Color.fromRGBO(40, 40, 40, 0.604),
                    minimumSize: Size(double.infinity, 50), // 버튼 크기
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Color.fromRGBO(40, 40, 40, 0.604),
                      ),
                    ),
                  ),
                  child: Text("login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class select1page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/walk');
              },
              child: Text("걷기"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/run');
              },
              child: Text("뛰기"),
            )
          ],
        ),
      ),
    );
  }
}

class walkpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: Text("Button"),
            )
          ],
        ),
      ),
    );
  }
}

class runpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: Text("Button"),
            )
          ],
        ),
      ),
    );
  }
}
