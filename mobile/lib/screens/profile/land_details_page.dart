// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import '../../models/user_model.dart';

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
  LandDetail? _editingLand;

  @override
  void initState() {
    super.initState();
    // If user has land details, we can show them for editing
    if (widget.user.landDetails.isNotEmpty) {
      _isEditing = true;
      _editingLand = widget.user.landDetails.first;
      _fillFormData(_editingLand!);
    }
  }

  void _fillFormData(LandDetail land) {
    _surveyNumberController.text = land.surveyNumber;
    _areaController.text = land.area;
    _locationController.text = land.location;
    _soilTypeController.text = land.soilType;
    _selectedCrops = List.from(land.crops);
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

  void _saveLandDetails() {
    if (_formKey.currentState!.validate() && _selectedCrops.isNotEmpty) {
      final landDetail = LandDetail(
        surveyNumber: _surveyNumberController.text.trim(),
        area: _areaController.text.trim(),
        location: _locationController.text.trim(),
        soilType: _soilTypeController.text.trim(),
        crops: _selectedCrops,
      );

      // TODO: BACKEND - Save land details to backend
      // For now, just navigate back
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
          _isEditing ? 'Edit Land Details' : 'Add Land Details',
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
                label: 'Survey Number',
                hintText: 'Enter survey number',
                icon: Icons.numbers,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter survey number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Area
              _buildFormField(
                controller: _areaController,
                label: 'Land Area',
                hintText: 'e.g., 2.5 acres, 1 hectare',
                icon: Icons.square_foot,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter land area';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Location
              _buildFormField(
                controller: _locationController,
                label: 'Location',
                hintText: 'Enter land location/address',
                icon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Soil Type
              _buildFormField(
                controller: _soilTypeController,
                label: 'Soil Type',
                hintText: 'e.g., Black soil, Red soil, Loamy',
                icon: Icons.landscape,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter soil type';
                  }
                  return null;
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
                  onPressed: _saveLandDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Update Land Details' : 'Save Land Details',
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
          'Crops Grown',
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
                          hintText: 'Enter crop name',
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
                    'Selected Crops:',
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
                    'No crops added yet',
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
          title: const Text("Delete Land Details"),
          content:
              const Text("Are you sure you want to delete these land details?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteLandDetails();
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

  void _deleteLandDetails() {
    // TODO: BACKEND - Delete land details from backend
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
