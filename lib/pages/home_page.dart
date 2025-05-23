import 'package:flutter/material.dart';
import '../pages/generator_page.dart';
import '../pages/favorites_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget content = selectedIndex == 0 ? GeneratorPage() : FavoritesPage();
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: false,
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text('Home')),
              NavigationRailDestination(
                  icon: Icon(Icons.favorite), label: Text('Favorites')),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
