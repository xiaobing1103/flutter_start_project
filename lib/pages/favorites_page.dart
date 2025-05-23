import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/animated_card.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.favorites.isEmpty) {
      return Center(child: Text('没有收藏的内容'));
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: appState.favorites.length,
      itemExtent: 100,
      itemBuilder: (context, index) {
        var pair = appState.favorites[index];
        return RepaintBoundary(child: AnimatedCard(pair: pair));
      },
    );
  }
}
