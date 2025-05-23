import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/big_card.dart';
import '../services/api_service.dart';

class GeneratorPage extends StatefulWidget {
  @override
  _GeneratorPageState createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final ApiService _apiService = ApiService(baseUrl: 'https://ai1foo.com');
  String _explanation = '';
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController(); // 添加滚动控制器

  void _fetchExplanation(String word) async {
    setState(() {
      _explanation = '';
      _isLoading = true;
    });

    final data = {
      "prompt": "你是一个乐于解答各种问题的助手，你的任务是为用户提供专业、准确、有见地的建议。",
      "type": "Web-推荐对话",
      "params": '[{"role":"user","content":"请解释单词 $word 的意思和用法"}]'
    };

    try {
      final stream = _apiService.postStreamSingleChar(
          '/api/v1/chat2/v35_RZTbEEo3XAw3LPJh',
          data: data);
      await for (final char in stream) {
        setState(() {
          print('Received char: $char');
          _explanation += char;
        });
        await Future.delayed(Duration(milliseconds: 50));
        // 仅在 _explanation 不为空时滚动到底部
        if (_explanation.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              // 检查 ScrollController 是否已附加
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 100),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon = appState.favorites.contains(pair)
        ? Icons.favorite
        : Icons.favorite_border;

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
                onPressed: () => appState.toggleFavorite(),
                icon: Icon(icon),
                label: Text('收藏'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => appState.getNext(),
                child: Text('下一个'),
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _fetchExplanation(pair.asLowerCase),
            child: Text('解释单词'),
          ),
          if (_isLoading) CircularProgressIndicator(),
          if (_explanation.isNotEmpty) // 将解释内容显示独立出来
            Container(
              width: double.infinity,
              height: 200,
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Markdown(
                controller: _scrollController,
                data: _explanation,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
              ),
            ),
        ],
      ),
    );
  }
}
