import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 引入 SharedPreferences
import 'package:model_viewer_plus/model_viewer_plus.dart'; // Ensure this import is present

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
            Theme.of(context).colorScheme.primaryContainer, // 状态栏颜色跟随主题
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark, // 状态栏图标颜色根据主题动态调整
      ),
    );

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: hasSeenOnboarding ? MyHomePage() : OnboardingPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0; // 当前选中的页面索引

  @override
  Widget build(BuildContext context) {
    // 设置状态栏透明
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
            Theme.of(context).colorScheme.primaryContainer, // 状态栏颜色跟随主题
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark, // 状态栏图标颜色根据主题动态调整
      ),
    );

    // 根据 selectedIndex 显示不同的页面
    Widget content;
    if (selectedIndex == 0) {
      content = GeneratorPage();
    } else {
      content = FavoritesPage();
    }

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: false,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value; // 更新选中的页面索引
                  });
                },
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300), // 动画持续时间
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: content, // 显示选中的页面
                switchInCurve: Curves.easeInOut, // 切换进入的动画曲线
                switchOutCurve: Curves.easeInOut, // 切换退出的动画曲线
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('收藏'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('下一个'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('没有收藏的内容'),
      );
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(), // 添加回弹效果
      padding: const EdgeInsets.all(16),
      itemCount: appState.favorites.length,
      itemExtent: 100, // 设置固定高度，优化性能
      itemBuilder: (context, index) {
        var pair = appState.favorites[index];
        return RepaintBoundary(
          // 防止不必要的重绘
          child: AnimatedCard(pair: pair),
        );
      },
    );
  }
}

class AnimatedCard extends StatelessWidget {
  const AnimatedCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // 添加 const
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 8, // 添加阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 圆角
        ),
        color: theme.colorScheme.primaryContainer,
        child: ListTile(
          leading: Icon(
            Icons.favorite,
            color: theme.colorScheme.secondary,
          ),
          title: Text(
            pair.asPascalCase,
            style: theme.textTheme.titleLarge!.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '这是一个收藏的单词',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
        color: theme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(pair.asLowerCase, style: style),
        ));
  }
}

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // 初始化状态栏颜色为第一页的颜色
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: (_pages[0] as Container).color!,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    // 添加 PageController 的监听器
    _pageController.addListener(() {
      final page = _pageController.page ?? 0.0;
      final currentIndex = page.floor();
      final nextIndex =
          (page.ceil() < _pages.length) ? page.ceil() : currentIndex;
      // 获取当前页面和下一个页面的颜色
      final currentColor = (_pages[currentIndex] as Container).color!;
      final nextColor = (_pages[nextIndex] as Container).color!;
      // 计算颜色的过渡
      final progress = page - currentIndex;
      final blendedColor = Color.lerp(currentColor, nextColor, progress);
      // 实时更新状态栏颜色
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: blendedColor,
          statusBarIconBrightness: Brightness.light,
        ),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // 释放 PageController
    super.dispose();
  }

  final List<Widget> _pages = [
    Container(color: Colors.blue),
    Container(color: Colors.green),
    Container(color: Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(
        context,
        title: '欢迎来到 Namer App',
        description: '一个有趣的单词生成器应用！',
        color: Colors.blue,
        image: Icons.language, // 添加默认图标
        modelUrl: 'assets/models/black_rat__free_download.glb', // 添加 3D 模型路径
      ),
      _buildPage(
        context,
        title: '收藏你喜欢的单词',
        description: '轻松收藏并管理你喜欢的单词。',
        color: Colors.green,
        image: Icons.favorite,
      ),
      _buildPage(
        context,
        title: '开始你的旅程',
        description: '立即探索并发现更多有趣的功能！',
        color: Colors.purple,
        image: Icons.explore,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length, // 使用 pages 的长度
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) => pages[index], // 使用 pages 的内容
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          if (_currentPage == pages.length - 1)
            Positioned(
              bottom: 40,
              right: 20,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('hasSeenOnboarding', true);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
                child: Text('开始'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context,
      {required String title,
      required String description,
      required Color color,
      required IconData image,
      String? modelUrl}) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (modelUrl != null)
            SizedBox(
              height: 200,
              child: ModelViewer(
                src: modelUrl, // 3D 模型文件路径
                alt: "3D 模型",
                autoRotate: true,
                cameraControls: true,
              ),
            )
          else
            Icon(image, size: 100, color: Colors.white),
          SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
