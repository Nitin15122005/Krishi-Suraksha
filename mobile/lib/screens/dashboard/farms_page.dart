import 'package:flutter/material.dart';
import 'package:agri_claim_mobile/screens/farm/add_farm_page.dart';
import 'package:agri_claim_mobile/services/api_service.dart';
import 'package:agri_claim_mobile/models/farm_model.dart';
import 'package:agri_claim_mobile/screens/farm/farm_details_page.dart';

class FarmsPage extends StatefulWidget {
  const FarmsPage({super.key});

  @override
  State<FarmsPage> createState() => _FarmsPageState();
}

class _FarmsPageState extends State<FarmsPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Farm>> _farmsFuture;

  @override
  void initState() {
    super.initState();
    _farmsFuture = _apiService.getFarms(); // ✅ FIXED
  }

  void _refreshFarms() {
    setState(() {
      _farmsFuture = _apiService.getFarms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: FutureBuilder<List<Farm>>(
              future: _farmsFuture,
              builder: (context, snapshot) {
                // 🔄 Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ❌ Error
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        snapshot.error
                            .toString()
                            .replaceFirst("Exception: ", ""),
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // 📭 Empty
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                // ✅ Data
                final farms = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: farms.length,
                  itemBuilder: (context, index) {
                    return _buildFarmCard(farms[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 🚀 Modern FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFarmPage()),
          );
          _refreshFarms();
        },
        backgroundColor: const Color(0xFFA9E981),
        label: const Text(
          "Add Farm",
          style: TextStyle(color: Colors.black),
        ),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // 🟢 Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 10, 40, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFE5F2DA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Text(
              "My Farms",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _refreshFarms,
            ),
          ],
        ),
      ),
    );
  }

  // 🌱 Farm Card
  Widget _buildFarmCard(Farm farm) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          if (farm.farmID.isEmpty) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FarmDetailsPage(farmID: farm.farmID),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              // 🌿 Icon Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5E4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(width: 12),

              // 📄 Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.farmID,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      "Crop: ${farm.cropType}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 6),

                    _buildStatusBadge(farm.status),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  // 🟢 Status Badge
  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == "active";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEAF5E4) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color:
              isActive ? const Color(0xFF2E7D32) : Colors.grey[700],
        ),
      ),
    );
  }

  // 📭 Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 10),
          const Text(
            "No farms yet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tap 'Add Farm' to get started",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // 🎨 Card Style
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}