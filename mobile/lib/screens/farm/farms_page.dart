// 📍 FILE: farms_page.dart

import 'package:flutter/material.dart';
import 'package:agri_claim_mobile/screens/farm/add_farm_page.dart'; // ⬅️ ADD THIS

class FarmsPage extends StatelessWidget {
  const FarmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Farms"),
        backgroundColor: Colors.green[800],
      ),
      body: const Center(
        // TODO: Build the full list of farms here
        // (using GET /farms/by-farmer/:farmerID)
        child: Text("Full list of all farms will go here."),
      ),
      // ⬇️ ADD THIS BUTTON ⬇️
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFarmPage()),
          );
        },
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}