import 'package:flutter/material.dart';

class AIChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI对话'),
      ),
      body: Center(
        child: Text(
          '这里是AI对话页面',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
