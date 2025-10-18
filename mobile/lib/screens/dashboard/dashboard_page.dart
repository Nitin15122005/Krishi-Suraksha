// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../profile/profile_page.dart';
import '../claims/claims_report_page.dart';
import '../../models/user_model.dart';
import '../claims/new_claim_page.dart';
import '../analytics/analytics_page.dart';
import '../weather/weather_page.dart';
import '../crop_scan/crop_scan_page.dart'; // ADD THIS IMPORT

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              floating: true,
              pinned: false,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.person, color: Colors.green[800]),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back!",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "John Farmer",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Badge(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.notifications_none,
                        color: Colors.grey[700], size: 28),
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            // Main Content
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // Crop Health Card - Pass context here
                _buildCropHealthCard(context),

                const SizedBox(height: 20),

                // Stats Overview
                _buildStatsSection(),

                const SizedBox(height: 20),

                // Quick Actions
                _buildQuickActions(context),

                const SizedBox(height: 20),

                // Recent Claims
                _buildRecentClaims(context),

                const SizedBox(height: 30),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildCropHealthCard(BuildContext context) {
    double cropHealth = 0.75; // 75% health
    Color healthColor = cropHealth > 0.7
        ? Colors.green
        : cropHealth > 0.4
            ? Colors.orange
            : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalyticsPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Crop Health",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: healthColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Good",
                    style: TextStyle(
                      color: healthColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Circular Progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: cropHealth,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "${(cropHealth * 100).toInt()}%",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: healthColor,
                          ),
                        ),
                        Text(
                          "Health",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 24),

                // Health Metrics
                Expanded(
                  child: Column(
                    children: [
                      _HealthMetric(
                        label: "Soil Moisture",
                        value: 0.8,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _HealthMetric(
                        label: "Nutrient Level",
                        value: 0.6,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _HealthMetric(
                        label: "Pest Control",
                        value: 0.9,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _HealthMetric(
                        label: "Growth Stage",
                        value: 0.7,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: "Total Claims",
              value: "12",
              subtitle: "+2 this month",
              color: Colors.green,
              icon: Icons.assignment_turned_in,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: "Pending",
              value: "3",
              subtitle: "Under review",
              color: Colors.orange,
              icon: Icons.pending_actions,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: "Approved",
              value: "8",
              subtitle: "Completed",
              color: Colors.blue,
              icon: Icons.verified,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _ActionCard(
                title: "New Claim",
                subtitle: "File a claim",
                icon: Icons.add_circle_outline,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewClaimPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _ActionCard(
                title: "My Claims",
                subtitle: "View all",
                icon: Icons.list_alt,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaimsReportPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _ActionCard(
                title: "Crop Scan",
                subtitle: "Health check",
                icon: Icons.camera_alt,
                color: Colors.purple,
                onTap: () {
                  // UPDATED: Redirect to CropScanPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CropScanPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _ActionCard(
                title: "Weather",
                subtitle: "Forecast",
                icon: Icons.cloud,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentClaims(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Recent Claims",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaimsReportPage(),
                    ),
                  );
                },
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildClaimList(),
        ],
      ),
    );
  }

  List<Widget> _buildClaimList() {
    final claims = [
      _ClaimItem(
        title: "Corn Crop Damage",
        date: "Dec 15, 2024",
        status: "Approved",
        statusColor: Colors.green,
        amount: "₹12,500",
      ),
      _ClaimItem(
        title: "Wheat Harvest Loss",
        date: "Dec 10, 2024",
        status: "Pending",
        statusColor: Colors.orange,
        amount: "₹8,200",
      ),
      _ClaimItem(
        title: "Soil Erosion",
        date: "Nov 28, 2024",
        status: "Rejected",
        statusColor: Colors.red,
        amount: "₹15,000",
      ),
    ];

    return claims
        .map((claim) => Column(
              children: [
                claim,
                if (claims.indexOf(claim) != claims.length - 1)
                  Divider(color: Colors.grey[200], height: 24),
              ],
            ))
        .toList();
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Claims',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == 1) {
              // Claims tab
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClaimsReportPage(),
                ),
              );
            } else if (index == 2) {
              // Analytics tab
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsPage(),
                ),
              );
            } else if (index == 3) {
              // Profile tab
              final demoUser = UserModel(
                id: "1",
                name: "John Farmer",
                email: "john.farmer@email.com",
                phoneNumber: "+91 9876543210",
                profileImage: null,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: demoUser),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _HealthMetric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _HealthMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${(value * 100).toInt()}%",
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimItem extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final String amount;

  const _ClaimItem({
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.agriculture, color: Colors.green, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
