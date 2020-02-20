import 'package:flutter/material.dart';
import 'package:schooler/res/resources.dart';

MainScreenResources _R = R.mainScreen;

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  List<Widget> _tabWidgets;

  @override
  Widget build(BuildContext context) {
    if (_tabWidgets == null) {
      _tabWidgets = _R.tabsInfo.map((info) => info.builder(context)).toList();
    }

    return Scaffold(
      body: _tabWidgets[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: _R.tabsInfo
            .map(
              (info) => BottomNavigationBarItem(
                title: Text(info.name),
                icon: Icon(info.icon),
              ),
            )
            .toList(),
        onTap: _onTabTapped,
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }
}
