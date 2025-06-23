// filepath: d:\Documents\Flutter_project\trach\flutter_start_project\lib\pages\login_page.dart
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('登录'),
          onPressed: () {
            // 登录成功后跳转到主页
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
      ),
    );
  }
}
