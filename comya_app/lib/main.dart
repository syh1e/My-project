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
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/select1');
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
                Navigator.pushNamed(context, '/walk');
              },
              child: Text("Button"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/run');
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
