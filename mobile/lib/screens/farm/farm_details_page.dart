// 📍 FILE: farm/farm_details_page.dart

import 'package:flutter/material.dart';
import 'package:agri_claim_mobile/models/farm_details_model.dart';
import 'package:agri_claim_mobile/services/api_service.dart';
import 'package:agri_claim_mobile/screens/claims/new_claim_page.dart';
import 'package:agri_claim_mobile/models/farm_model.dart';

class FarmDetailsPage extends StatefulWidget {
  final String farmID;
  
  const FarmDetailsPage({super.key, required this.farmID});

  @override
  State<FarmDetailsPage> createState() => _FarmDetailsPageState();
}

class _FarmDetailsPageState extends State<FarmDetailsPage> {
  final ApiService _apiService = ApiService();
  late Future<FarmDetails> _detailsFuture;
  List<Farm> _farmerFarms = [];

  @override
  void initState() {
    super.initState();
    // Start fetching the details as soon as the page loads
    // _detailsFuture = _apiService.getFarmDetails(widget.farmID);
    _loadPageData();
  }

  void _loadPageData() async {
    final detailsFuture = _apiService.getFarmDetails(widget.farmID);
    final farmsFuture = _apiService.getFarms(); 
    
    // Wait for both to finish
    final results = await Future.wait([detailsFuture, farmsFuture]);
    
    setState(() {
      _detailsFuture = Future.value(results[0] as FarmDetails);
      _farmerFarms = results[1] as List<Farm>; 
    });
  }

  void _launchLandRecord(String url) async {
    try {
      await _apiService.launchURL(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
  
  void _handleSubmitClaim(String farmID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewClaimPage(farms: _farmerFarms),
      ),
    ).then((_) {
      setState(() {
         _detailsFuture = _apiService.getFarmDetails(widget.farmID);
      });
    });
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farm: ${widget.farmID}'),
        backgroundColor: Colors.green[800],
      ),
      body: FutureBuilder<FarmDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          // --- Loading State ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // --- Error State ---
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          
          // --- Success State ---
          if (!snapshot.hasData) {
            return const Center(child: Text('Farm not found.'));
          }
          
          final details = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailsCard(details),
                const SizedBox(height: 24),
                _buildActionsCard(details),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsCard(FarmDetails details) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.person_outline, 'Owner ID', details.ownerFarmerID),
            _buildDetailRow(Icons.grass_outlined, 'Crop Type', details.cropType),
            _buildDetailRow(Icons.location_on_outlined, 'Location', details.location),
            _buildDetailRow(Icons.security_outlined, 'Status', details.status,
              // Add a color chip for status
              valueWidget: Chip(
                label: Text(details.status),
                backgroundColor: _getStatusColor(details.status),
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ),
            _buildDetailRow(Icons.assignment_outlined, 'Active Claim',
              details.activeClaimID.isEmpty ? 'None' : details.activeClaimID,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(FarmDetails details) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            
            // --- View Land Record Button ---
            ElevatedButton.icon(
              icon: const Icon(Icons.description_outlined),
              label: const Text('View Land Record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: details.landRecordFileURL.isEmpty
                ? null // Disable button if no URL
                : () => _launchLandRecord(details.landRecordFileURL),
            ),
            if (details.landRecordFileURL.isEmpty)
              const Text('No land record file found.', textAlign: TextAlign.center),
            
            const SizedBox(height: 16),
            
            // --- Submit Claim Button ---
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Submit New Claim'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              // Disable button if farm is not verified or already has an active claim
              onPressed: (details.status == 'Verified' && details.activeClaimID.isEmpty)
                ? () => _handleSubmitClaim(details.farmID)
                : null,
            ),
            
            // Helper text explaining why the button might be disabled
            if (details.status != 'Verified')
              const Text(
                'Farm must be "Verified" to submit a claim.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            if (details.status == 'Verified' && details.activeClaimID.isNotEmpty)
              const Text(
                'This farm already has an active claim.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: valueWidget ?? Text(
              value,
              style: const TextStyle(fontSize: 16),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'pendingverification':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}