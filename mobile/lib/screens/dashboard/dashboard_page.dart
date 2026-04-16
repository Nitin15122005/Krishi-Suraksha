import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../profile/profile_page.dart';
import '../claims/claims_report_page.dart';
import './home_page.dart';
import './farms_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  bool _isScrolled = false;

  final List<Widget> _pages = [
    const HomePage(),
    ClaimsReportPage(),
    const FarmsPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _navIcon(IconData icon, int index) {
    return Icon(
      icon,
      size: 30,
      color: _selectedIndex == index ? Colors.white : Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      // 🔥 STACK for overlay effect
      body: Stack(
        children: [
          /// 🔥 SCROLL DETECTION
        NotificationListener<ScrollNotification>(
  onNotification: (scroll) {
    // ✅ Only main scroll
    if (scroll.depth == 0) {

      // ✅ Only active page
      if (scroll.context != null) {
        final scrollWidget = scroll.context!.widget;

        // Check if scroll belongs to visible page
        if (scroll.metrics.axis == Axis.vertical) {
          if (scroll.metrics.pixels > 10 && !_isScrolled) {
            setState(() => _isScrolled = true);
          } else if (scroll.metrics.pixels <= 10 && _isScrolled) {
            setState(() => _isScrolled = false);
          }
        }
      }
    }
    return false;
  },
  child: IndexedStack(
    index: _selectedIndex,
    children: _pages,
  ),
),
          /// 🔥 FLOATING TOP BAR
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 80,
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),

            decoration: BoxDecoration(
              color: _isScrolled
                  ? Colors.white.withOpacity(0.95) // translucent
                  : Colors.white.withOpacity(0),
            ),

            
          ),
        ],
      ),

      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 75.0,
        items: <Widget>[
          _navIcon(Icons.home_rounded, 0),
          _navIcon(Icons.assignment_outlined, 1),
          _navIcon(Icons.grass_rounded, 2),
          _navIcon(Icons.person_outline, 3),
        ],
        color: Colors.black.withOpacity(0.9),
        buttonBackgroundColor: const Color(0xFFA9E981),
        backgroundColor: const Color(0xFFF3F3F3),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: _onItemTapped,
      ),
    );
  }
}