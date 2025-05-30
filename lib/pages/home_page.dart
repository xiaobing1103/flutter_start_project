import 'package:flutter/material.dart';
import '../pages/generator_page.dart';
import '../pages/favorites_page.dart';
import '../pages/ai_chat_page.dart'; // 新增导入

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (selectedIndex) {
      case 0:
        content = GeneratorPage();
        break;
      case 1:
        content = FavoritesPage();
        break;
      case 2:
        content = AIChatPage();
        break;
      case 3:
        content = Center(child: Text('关于页面')); // 占位，可替换为AboutPage
        break;
      default:
        content = GeneratorPage();
    }
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: content,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '收藏'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI对话'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: '关于'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
