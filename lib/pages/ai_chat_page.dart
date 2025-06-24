import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AIChatPage extends StatefulWidget {
  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with TickerProviderStateMixin {
  // 用于 SearchIndexChangeFont 动画
  final List<Map<String, dynamic>> changeLists = [
    {
      'title': 'AI对话',
      'desc': '智能对话助手，解答你的问题',
      'color': Color(0xFF3ab7ad),
    },
    {
      'title': '图片创作',
      'desc': '元气满满的库洛米，3D卡通头像',
      'color': Color(0xFF9a70e4),
    },
    {
      'title': '音乐创作',
      'desc': '轻松生成专属音乐，多种风格',
      'color': Color(0xFFa084e8),
    },
    {
      'title': '视频创作',
      'desc': '让创意动起来,一键生成视频',
      'color': Color(0xFF1195ff),
    },
  ];

  int currentIndex = 0;
  String typewriterText = '';
  late AnimationController _controller;
  Animation<int>? _typingAnimation;
  late VoidCallback _typingListener;
  late AnimationStatusListener _statusListener;

  bool _showMoreDialog = false;
  final GlobalKey _gridKey = GlobalKey();

  // 动画控制器和动画
  AnimationController? _popupController;
  Animation<Offset>? _popupOffsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _typingListener = () {
      final desc = changeLists[currentIndex]['desc'] as String;
      final value = _typingAnimation?.value.clamp(0, desc.length) ?? 0;
      setState(() {
        typewriterText = desc.substring(0, value);
      });
    };
    _statusListener = (status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 1200), () {
          if (!mounted) return; // 修复关键
          setState(() {
            currentIndex = (currentIndex + 1) % changeLists.length;
          });
          _startTypewriter();
        });
      }
    };
    _startTypewriter();

    // 弹窗动画初始化
    _popupController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );
    _popupOffsetAnimation = Tween<Offset>(
      begin: Offset(1, -1), // 右上
      end: Offset(0, 0), // 原位
    ).animate(CurvedAnimation(
      parent: _popupController!,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startTypewriter() {
    final desc = changeLists[currentIndex]['desc'] as String;
    _controller.duration = Duration(milliseconds: desc.length * 60);

    // 先移除旧监听器，防止重复注册
    _typingAnimation?.removeListener(_typingListener);
    _typingAnimation?.removeStatusListener(_statusListener);

    _typingAnimation =
        StepTween(begin: 0, end: desc.length).animate(_controller)
          ..addListener(_typingListener)
          ..addStatusListener(_statusListener);

    setState(() {
      typewriterText = '';
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _typingAnimation?.removeListener(_typingListener);
    _typingAnimation?.removeStatusListener(_statusListener);
    _controller.dispose();
    _popupController?.dispose();
    super.dispose();
  }

  // 模拟 icons 数据
  List<Map<String, String>> get icons => [
        {
          'name': 'AI模型',
          'icon':
              'https://file.1foo.com/2025/05/12/264f9a8e5d15cbd744ae52420c4b6aa2.svg',
        },
        {
          'name': 'AI生图',
          'icon':
              'http://file.1foo.com/2025/05/13/295cb58d1ea857689f1f6ec0ad727d78.svg',
        },
        {
          'name': 'AI修图',
          'icon':
              'http://file.1foo.com/2025/05/13/0d03a9aa9061e97c13a967de9f7504ca.svg',
        },
        {
          'name': 'AI翻译',
          'icon':
              'http://file.1foo.com/2025/05/12/ddf0c6163ca881e7140d3dfc5f59dd3b.svg',
        },
        {
          'name': 'AI智能体',
          'icon':
              'http://file.1foo.com/2025/05/12/2cf32787346c7c691c8ee7da69bfec95.svg',
        },
        {
          'name': 'AI写作',
          'icon':
              'http://file.1foo.com/2025/05/13/8f5c28c3400e95d0e3077224b6dbe697.svg',
        },
        {
          'name': 'PDF操作',
          'icon':
              'http://file.1foo.com/2025/05/13/89dc284745a5c3a5b19969472a880608.svg',
        },
        {
          'name': '日报',
          'icon':
              'http://file.1foo.com/2025/05/13/eaa9ab8910ba7a61b5c1ad4e252394b3.svg',
        },
        {
          'name': '论文',
          'icon':
              'http://file.1foo.com/2025/05/13/1fd17a28f9546b879584ca1fb6243d39.svg',
        },
        {
          'name': 'AI视频',
          'icon':
              'http://file.1foo.com/2025/05/12/343ce3359e28a04889a097e1b37f22d8.svg',
        },
        {
          'name': 'AI音乐',
          'icon':
              'http://file.1foo.com/2025/05/12/7db57e95b36c2d76f76254931b2b5858.svg',
        },
        {
          'name': 'AI文档',
          'icon':
              'http://file.1foo.com/2025/05/12/7822a70dbf311907ffa8a8b7ed071107.svg',
        },
        {
          'name': 'AI语音',
          'icon':
              'http://file.1foo.com/2025/05/12/7d5d5a6db3802b847f12f0608b56a485.svg',
        }
      ];

  @override
  Widget build(BuildContext context) {
    // 处理 icons 展示逻辑
    List<Map<String, String>> displayIcons;
    List<Map<String, String>> moreIcons = [];
    if (icons.length > 9) {
      displayIcons = List<Map<String, String>>.from(icons.take(9));
      displayIcons.add({
        'name': '更多',
        'icon':
            'http://file.1foo.com/2025/05/13/5e8a8e07bac49a1b4f89a81d1693afd6.svg',
      });
      moreIcons = icons.sublist(9);
    } else {
      displayIcons = icons;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.9,
                  //   width: double.infinity,
                  //    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.only(top: 100.0, bottom: 20),
                        child: Text(
                          '边界AICHAT',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      // SearchIndexChangeFont
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          children: [
                            Text(
                              changeLists[currentIndex]['title'],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            AnimatedDefaultTextStyle(
                              duration: Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 16,
                                color: changeLists[currentIndex]['color'],
                              ),
                              child: Text(typewriterText),
                            ),
                          ],
                        ),
                      ),
                      // SearchBox
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            // 跳转到AI对话页面或弹窗
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('跳转到AI对话页面')),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 16),
                                    SvgPicture.network(
                                      'http://file.1foo.com/2025/05/12/d243723a7afe9a5094e2526aeeaf3ca6.svg',
                                      width: 30,
                                      height: 30,
                                      placeholderBuilder: (context) => Icon(
                                          Icons.image,
                                          size: 30,
                                          color: Colors.grey),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SvgPicture.network(
                                      'https://file.1foo.com/2025/05/12/62d17d38098262e805a05e78cabe0b6d.svg',
                                      width: 30,
                                      height: 30,
                                      placeholderBuilder: (context) => Icon(
                                          Icons.image,
                                          size: 30,
                                          color: Colors.grey),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: SvgPicture.network(
                                        'http://file.1foo.com/2025/05/12/7902991dcf48b54691b7f45ddaa88c97.svg',
                                        width: 30,
                                        height: 30,
                                        placeholderBuilder: (context) => Icon(
                                            Icons.image,
                                            size: 30,
                                            color: Colors.grey),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // SeletedModels
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Stack(
                          children: [
                            // SeletedModels内容（相对定位）
                            GridView.builder(
                              key: _gridKey,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: displayIcons.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.7,
                              ),
                              itemBuilder: (context, idx) {
                                final item = displayIcons[idx];
                                final iconUrl = item['icon']!;
                                final isSvg =
                                    iconUrl.toLowerCase().endsWith('.svg');
                                if (item['name'] == '更多') {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showMoreDialog = true;
                                      });
                                      _popupController?.forward(from: 0);
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.all(8),
                                          child: SvgPicture.network(
                                            iconUrl,
                                            width: 36,
                                            height: 36,
                                            placeholderBuilder: (context) =>
                                                Icon(Icons.more_horiz,
                                                    size: 36,
                                                    color: Colors.grey),
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          item['name']!,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87),
                                          maxLines: 1, // 新增
                                          overflow: TextOverflow.ellipsis, // 新增
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('点击了${item['name']}')),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: isSvg
                                            ? SvgPicture.network(
                                                iconUrl,
                                                width: 30,
                                                height: 30,
                                                placeholderBuilder: (context) =>
                                                    Icon(Icons.image,
                                                        size: 30,
                                                        color: Colors.grey),
                                              )
                                            : Image.network(
                                                iconUrl,
                                                width: 30,
                                                height: 30,
                                                fit: BoxFit.contain,
                                              ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        item['name']!,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87),
                                        maxLines: 1, // 新增
                                        overflow: TextOverflow.ellipsis, // 新增
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ), // 弹窗（绝对定位，完全覆盖SeletedModels区域）
                            if (_showMoreDialog)
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showMoreDialog = false;
                                    });
                                  },
                                  child: Center(
                                    child: SlideTransition(
                                      position: _popupOffsetAnimation!,
                                      child: GestureDetector(
                                        onTap: () {}, // 阻止冒泡
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 18,
                                                spreadRadius: 2,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          padding: EdgeInsets.all(5),
                                          constraints: BoxConstraints(
                                            minHeight: 280, // 你可以根据实际内容调整
                                            minWidth: 300, // 可选，保证宽度
                                          ),
                                          child: GridView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: moreIcons.length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 5,
                                              mainAxisSpacing: 10,
                                              crossAxisSpacing: 10,
                                              childAspectRatio: 0.7,
                                            ),
                                            itemBuilder: (context, idx) {
                                              final item = moreIcons[idx];
                                              final iconUrl = item['icon']!;
                                              final isSvg = iconUrl
                                                  .toLowerCase()
                                                  .endsWith('.svg');
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _showMoreDialog = false;
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            '点击了${item['name']}')),
                                                  );
                                                },
                                                child: Center(
                                                  // 让内容在格子内居中
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center, // 横向居中
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: isSvg
                                                            ? SvgPicture
                                                                .network(
                                                                iconUrl,
                                                                width: 30,
                                                                height: 30,
                                                                placeholderBuilder:
                                                                    (context) => Icon(
                                                                        Icons
                                                                            .image,
                                                                        size:
                                                                            30,
                                                                        color: Colors
                                                                            .grey),
                                                              )
                                                            : Image.network(
                                                                iconUrl,
                                                                width: 30,
                                                                height: 30,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                      ),
                                                      // SizedBox(height: 4),
                                                      Text(
                                                        item['name']!,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black87),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // 可选：底部TabBar等
                    ],
                  ),
                ],
              ),
            ),
            // 弹窗（只覆盖SeletedModels区域，点击弹窗外关闭，点击弹窗内不关闭）
          ],
        ),
      ),
    );
  }
}
