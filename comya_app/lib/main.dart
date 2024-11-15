import 'package:flutter/material.dart';

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
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/select1page');
              },
              child: Text("Button"),
            )
          ],
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
                Navigator.pushNamed(context, '/walkpage');
              },
              child: Text("Button"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/runpage');
              },
              child: Text("Button"),
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
