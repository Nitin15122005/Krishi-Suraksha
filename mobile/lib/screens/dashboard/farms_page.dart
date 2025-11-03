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
    // Load the farms when the page is first built
    _farmsFuture = _apiService.getFarms();
  }
  
  // Function to allow refreshing the list (e.g., with a pull-to-refresh)
  void _refreshFarms() {
    setState(() {
      _farmsFuture = _apiService.getFarms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Farms"),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFarms, // Refresh button
          ),
        ],
      ),
      body: FutureBuilder<List<Farm>>(
        future: _farmsFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          
          // 3. No Data State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "You haven't added any farms yet.\nClick the '+' button to add one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // 4. Success State (Display the list)
          final farms = snapshot.data!;
          return ListView.builder(
            itemCount: farms.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final farm = farms[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  title: Text(farm.farmID, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Crop: ${farm.cropType}"),
                      Text("Location: ${farm.location}"),
                      Text("Status: ${farm.status}"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FarmDetailsPage(farmID: farm.farmID),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // After returning from AddFarmPage, refresh the list
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFarmPage()),
          );
          // If we come back, refresh the farm list
          _refreshFarms();
        },
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}