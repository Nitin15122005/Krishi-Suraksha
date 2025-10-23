// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../map/map_selection_page.dart';

class LandDetailsPage extends StatefulWidget {
  final UserModel user;

  const LandDetailsPage({super.key, required this.user});

  @override
  State<LandDetailsPage> createState() => _LandDetailsPageState();
}

class _LandDetailsPageState extends State<LandDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _surveyNumberController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _soilTypeController = TextEditingController();
  final TextEditingController _cropsController = TextEditingController();

  List<String> _selectedCrops = [];
  bool _isEditing = false;
  FarmModel? _editingFarm;
  Map<String, dynamic>? _selectedLocation;

  @override
  void initState() {
    super.initState();
    // If user has farm details, we can show them for editing
    if (widget.user.farms.isNotEmpty) {
      _isEditing = true;
      _editingFarm = widget.user.farms.first;
      _fillFormData(_editingFarm!);
    }
  }

  void _fillFormData(FarmModel farm) {
    _surveyNumberController.text = ""; // Survey number not in FarmModel
    _areaController.text = farm.area.toString();
    _locationController.text = farm.location;
    _soilTypeController.text = ""; // Soil type not in FarmModel
    _selectedCrops = [farm.cropType]; // Single crop type in FarmModel
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapSelectionPage(
          isFarmLocation: true,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLocation = result;
        _locationController.text = result['address'];
      });
    }
  }

  void _addCrop() {
    final crop = _cropsController.text.trim();
    if (crop.isNotEmpty && !_selectedCrops.contains(crop)) {
      setState(() {
        _selectedCrops.add(crop);
        _cropsController.clear();
      });
    }
  }

  void _removeCrop(String crop) {
    setState(() {
      _selectedCrops.remove(crop);
    });
  }

  void _saveFarmDetails() {
    if (_formKey.currentState!.validate() && _selectedCrops.isNotEmpty) {
      // TODO: BACKEND - Save farm details to blockchain and Firebase
      // This should:
      // 1. Generate FarmID in backend
      // 2. Store in Blockchain: FarmID, OwnerFarmerID, Location, CropType, LandRecordHash, ActiveClaimID, Area, Timestamp
      // 3. Store in Firebase: Full farm mirror, documents, images, historical records

      final farmData = FarmModel(
        farmId: _isEditing
            ? _editingFarm!.farmId
            : "FARM_${DateTime.now().millisecondsSinceEpoch}",
        ownerFarmerId: widget.user.farmerId,
        location: _selectedLocation != null
            ? "lat:${_selectedLocation!['latitude']},lon:${_selectedLocation!['longitude']}"
            : _locationController.text,
        cropType: _selectedCrops.first, // Using first crop as main crop type
        area: double.tryParse(_areaController.text) ?? 0.0,
        description: "Farm description", // You might want to add this field
      );

      // Navigate back
      Navigator.pop(context);
    } else if (_selectedCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one crop'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Farm Details' : 'Add Farm Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[800]),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Survey Number
              _buildFormField(
                controller: _surveyNumberController,
                label: 'Survey Number (Optional)',
                hintText: 'Enter survey number',
                icon: Icons.numbers,
                validator: (value) {
                  return null; // Optional field
                },
              ),
              const SizedBox(height: 20),

              // Area
              _buildFormField(
                controller: _areaController,
                label: 'Land Area (acres)',
                hintText: 'e.g., 2.5',
                icon: Icons.square_foot,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter land area';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Location
              _buildFormField(
                controller: _locationController,
                label: 'Location',
                hintText: 'Select farm location on map',
                icon: Icons.location_on,
                maxLines: 2,
                readOnly: true,
                onTap: _selectLocation,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select farm location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Soil Type
              _buildFormField(
                controller: _soilTypeController,
                label: 'Soil Type (Optional)',
                hintText: 'e.g., Black soil, Red soil, Loamy',
                icon: Icons.landscape,
                validator: (value) {
                  return null; // Optional field
                },
              ),
              const SizedBox(height: 20),

              // Crops Section
              _buildCropsSection(),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveFarmDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Update Farm Details' : 'Save Farm Details',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.green),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildCropsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Main Crop Type',
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Add Crop Input
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cropsController,
                        decoration: InputDecoration(
                          hintText: 'Enter main crop type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onFieldSubmitted: (_) => _addCrop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addCrop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Selected Crops
                if (_selectedCrops.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Selected Crop:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedCrops
                        .map((crop) => Chip(
                              label: Text(crop),
                              backgroundColor: Colors.green[50],
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeCrop(crop),
                              labelStyle: TextStyle(
                                color: Colors.green[800],
                                fontSize: 12,
                              ),
                            ))
                        .toList(),
                  ),
                ] else ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'No crop added yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Farm Details"),
          content:
              const Text("Are you sure you want to delete these farm details?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteFarmDetails();
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteFarmDetails() {
    // TODO: BACKEND - Delete farm details from blockchain and Firebase
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _surveyNumberController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    _soilTypeController.dispose();
    _cropsController.dispose();
    super.dispose();
  }
}
