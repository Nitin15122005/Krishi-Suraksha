import 'package:flutter/material.dart';
import '../profile/profile_page.dart'; 
import '../claims/claims_report_page.dart'; 
import './home_page.dart';
import './farms_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    ClaimsReportPage(),
    const FarmsPage(),
    const ProfilePage(), 
    // -----------------------
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.only(bottom: 0), // IMPORTANT
      child: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
    ),
    bottomNavigationBar: _buildBottomNavBar(),
  );
}


Widget _buildBottomNavBar() {
  return CurvedNavigationBar(
    index: _selectedIndex,
    height: 75.0,
    items: <Widget>[
      Icon(Icons.home_rounded, size: 30, color: _selectedIndex == 0 ? Colors.white : Colors.grey),
      Icon(Icons.assignment_outlined, size: 30, color: _selectedIndex == 1 ? Colors.white : Colors.grey),
      Icon(Icons.grass_rounded, size: 30, color: _selectedIndex == 2 ? Colors.white : Colors.grey),
      Icon(Icons.person_outline, size: 30, color: _selectedIndex == 3 ? Colors.white : Colors.grey),
    ],
    color: Colors.black, // Background of the bar
    buttonBackgroundColor:  const Color(0xFFA9E981), // Color of the floating circle
    backgroundColor: Colors.transparent, // Match this to your Scaffold background
    animationCurve: Curves.easeInOut,
    animationDuration: const Duration(milliseconds: 400),
    onTap: (index) {
      _onItemTapped(index);
    },
    letIndexChange: (index) => true,
  );
}

}