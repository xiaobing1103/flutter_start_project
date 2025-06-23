import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'pages/home_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/login_page.dart';

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: '边界AIchat',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        // 路由配置
        routes: {
          '/': (context) => hasSeenOnboarding ? HomePage() : OnboardingPage(),
          '/login': (context) => LoginPage(),
        },
        // 路由守卫
        onGenerateRoute: (settings) {
          // 这里用 Provider 或其它方式判断是否已登录
          final appState = Provider.of<MyAppState>(context, listen: false);
          final bool isLoggedIn = appState.isLoggedIn; // 你需要在 MyAppState 里实现 isLoggedIn
          if (settings.name != '/login' && !isLoggedIn) {
            return MaterialPageRoute(builder: (context) => LoginPage());
          }
          return null; // 使用默认路由
        },
        initialRoute: '/',
      ),
    );
  }
}
