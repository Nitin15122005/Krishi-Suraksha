import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agri_claim_mobile/services/api_service.dart';
import 'package:agri_claim_mobile/screens/map/map_selection_page.dart';
import 'package:agri_claim_mobile/services/storage_service.dart'; 
import 'package:agri_claim_mobile/services/cloudinary_service.dart';
// import 'dart:convert';

class AddFarmPage extends StatefulWidget {
  const AddFarmPage({super.key});

  @override
  State<AddFarmPage> createState() => _AddFarmPageState();
}

class _AddFarmPageState extends State<AddFarmPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Form controllers
  final _farmIdController = TextEditingController();
  final _cropTypeController = TextEditingController();

  final _cloudinaryService = CloudinaryService(); 
  final _storageService = StorageService();

  // File state
  File? _landRecordFile;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>>? _farmBoundary;
  String _farmAddress = '';

  bool _isLoading = false;

  @override
  void dispose() {
    _farmIdController.dispose();
    _cropTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // You can also use ImageSource.gallery
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _landRecordFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectOnMap() async {
    // Navigate to the map page and wait for the result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // Set isFarmLocation to true
        builder: (context) => const MapSelectionPage(isFarmLocation: true),
      ),
    );

    // When the map page 'pops', it returns the data
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _farmBoundary = List<Map<String, dynamic>>.from(result['boundary']);
        _farmAddress = result['address'];
      });
    }
  }
  
  Future<void> _submitFarm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_farmBoundary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the farm area on the map.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_landRecordFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a land record file.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      // 1. Get FarmerID for the folder path
      final farmerID = await _storageService.getFarmerID();
      if (farmerID == null) throw Exception("You are not logged in.");
      
      // 2. Upload Land Record to Cloudinary
      final String landRecordURL = await _cloudinaryService.uploadLandRecord(
        _landRecordFile!,
        _farmIdController.text,
        farmerID,
      );
      
      // 3. Call our API Service with the new URL
      final message = await _apiService.addFarm(
        farmID: _farmIdController.text,
        boundary: _farmBoundary!,
        cropType: _cropTypeController.text,
        landRecordFileURL: landRecordURL, // Pass the URL
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      
      Navigator.of(context).pop();

    } catch(e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a New Farm'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Farm Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _farmIdController,
                decoration: const InputDecoration(
                  labelText: 'Farm ID',
                  hintText: 'e.g., FARM_004',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.yard_outlined),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a Farm ID' : null,
              ),
              const SizedBox(height: 16),
              _buildMapSelector(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cropTypeController,
                decoration: const InputDecoration(
                  labelText: 'Crop Type',
                  hintText: 'e.g., Wheat, Rice, Corn',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.grass_rounded),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a crop type' : null,
              ),
              const SizedBox(height: 24),
              
              // --- Land Record Picker ---
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Select Land Record (7/12)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16)
                ),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 12),
              if (_landRecordFile != null)
                Center(
                  child: Text(
                    'File: ${_landRecordFile!.path.split('/').last}',
                    style: TextStyle(color: Colors.green[800], fontStyle: FontStyle.italic),
                  ),
                ),
              const SizedBox(height: 32),

              // --- Submit Button ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading ? null : _submitFarm,
                child: _isLoading
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                  : const Text('Register Farm'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Farm Location",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400)
          ),
          child: ListTile(
            leading: Icon(Icons.map_outlined, color: Colors.green),
            title: Text(
              _farmBoundary == null
                ? 'No farm area selected'
                : 'Farm Area Selected',
              style: TextStyle(
                color: _farmBoundary == null ? Colors.grey[600] : Colors.green[800],
                fontWeight: _farmBoundary == null ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Text(
              _farmBoundary == null
                ? 'Tap to draw on map'
                : '${_farmBoundary!.length} points | $_farmAddress',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _selectOnMap,
          ),
        ),
      ],
    );
  }
}