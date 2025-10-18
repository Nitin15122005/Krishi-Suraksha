// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class NewClaimPage extends StatefulWidget {
  const NewClaimPage({super.key});

  @override
  State<NewClaimPage> createState() => _NewClaimPageState();
}

class _NewClaimPageState extends State<NewClaimPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cropTypeController = TextEditingController();
  final TextEditingController _landAreaController = TextEditingController();
  final TextEditingController _damageDateController = TextEditingController();
  final TextEditingController _damageTypeController = TextEditingController();
  final TextEditingController _estimatedLossController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _surveyNumberController = TextEditingController();

  List<String> _selectedEvidence = [];
  bool _isSubmitting = false;
  DateTime? _selectedDate;

  // Dropdown options
  final List<String> _cropTypes = [
    'Wheat',
    'Rice',
    'Corn',
    'Soybean',
    'Cotton',
    'Sugarcane',
    'Pulses',
    'Oilseeds',
    'Vegetables',
    'Fruits',
    'Other'
  ];

  final List<String> _damageTypes = [
    'Pest Attack',
    'Disease Outbreak',
    'Flood Damage',
    'Drought',
    'Storm/Hail Damage',
    'Fire Damage',
    'Soil Erosion',
    'Wild Animal Damage',
    'Heavy Rainfall',
    'Other Natural Calamity'
  ];

  @override
  void dispose() {
    _cropTypeController.dispose();
    _landAreaController.dispose();
    _damageDateController.dispose();
    _damageTypeController.dispose();
    _estimatedLossController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _surveyNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _damageDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _addEvidence() {
    // TODO: Implement image picker or file upload
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Evidence"),
        content: Text("Choose evidence type:"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open camera
            },
            child: Text("Camera"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open gallery
            },
            child: Text("Gallery"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Add document
            },
            child: Text("Document"),
          ),
        ],
      ),
    );
  }

  void _removeEvidence(int index) {
    setState(() {
      _selectedEvidence.removeAt(index);
    });
  }

  void _submitClaim() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // TODO: BACKEND - Submit claim data to API
    try {
      final claimData = {
        'cropType': _cropTypeController.text,
        'landArea': _landAreaController.text,
        'damageDate': _damageDateController.text,
        'damageType': _damageTypeController.text,
        'estimatedLoss': _estimatedLossController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'surveyNumber': _surveyNumberController.text,
        'evidence': _selectedEvidence,
      };

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      // TODO: Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit claim: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Claim Submitted"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your claim has been submitted successfully!"),
            SizedBox(height: 8),
            Text(
              "Claim ID: CLM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "You can track the status in your claims section.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to claims page
            },
            child: Text("View My Claims"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to claims page
            },
            child: Text("Done"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'File New Claim',
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
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              const SizedBox(height: 30),

              // Crop Information
              _buildCropInformationSection(),
              const SizedBox(height: 25),

              // Damage Details
              _buildDamageDetailsSection(),
              const SizedBox(height: 25),

              // Location Information
              _buildLocationSection(),
              const SizedBox(height: 25),

              // Evidence Section
              _buildEvidenceSection(),
              const SizedBox(height: 30),

              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.green[800], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Claim Filing Guidelines",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[900],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Please provide accurate information. False claims may lead to rejection.",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropInformationSection() {
    return _buildSection(
      title: "Crop Information",
      icon: Icons.agriculture,
      children: [
        _buildDropdownField(
          controller: _cropTypeController,
          label: "Crop Type",
          hintText: "Select crop type",
          items: _cropTypes,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select crop type';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _landAreaController,
          label: "Land Area Affected",
          hintText: "e.g., 2.5 acres, 1 hectare",
          icon: Icons.square_foot,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter land area';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _surveyNumberController,
          label: "Survey Number (Optional)",
          hintText: "Enter land survey number",
          icon: Icons.numbers,
          validator: (value) {
            return null; // Optional field
          },
        ),
      ],
    );
  }

  Widget _buildDamageDetailsSection() {
    return _buildSection(
      title: "Damage Details",
      icon: Icons.warning_amber,
      children: [
        _buildDropdownField(
          controller: _damageTypeController,
          label: "Type of Damage",
          hintText: "Select damage type",
          items: _damageTypes,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select damage type';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _damageDateController,
          label: "Date of Damage",
          hintText: "Select date",
          icon: Icons.calendar_today,
          readOnly: true,
          onTap: () => _selectDate(context),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select damage date';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _estimatedLossController,
          label: "Estimated Loss Amount",
          hintText: "e.g., ₹15,000",
          icon: Icons.currency_rupee,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter estimated loss';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _descriptionController,
          label: "Damage Description",
          hintText: "Describe the damage in detail...",
          icon: Icons.description,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please describe the damage';
            }
            if (value.length < 20) {
              return 'Description must be at least 20 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: "Location Information",
      icon: Icons.location_on,
      children: [
        _buildFormField(
          controller: _locationController,
          label: "Farm Location",
          hintText: "Enter complete farm address",
          icon: Icons.map,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter farm location';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEvidenceSection() {
    return _buildSection(
      title: "Evidence & Documentation",
      icon: Icons.attach_file,
      children: [
        Text(
          "Add supporting evidence (photos, documents)",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),

        // Evidence Grid
        if (_selectedEvidence.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _selectedEvidence.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo, color: Colors.grey[500]),
                        Text(
                          'Evidence ${index + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeEvidence(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
        ],

        // Add Evidence Button
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
            ),
          ),
          child: TextButton(
            onPressed: _addEvidence,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, color: Colors.grey[500]),
                const SizedBox(height: 4),
                Text(
                  "Add Evidence",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Supported: Photos (JPG, PNG), Documents (PDF)",
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(icon, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.green),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required List<String> items,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: controller.text.isEmpty ? null : controller.text,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              prefixIcon: Icon(Icons.arrow_drop_down, color: Colors.green),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                controller.text = newValue ?? '';
              });
            },
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: _isSubmitting
          ? ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Submitting Claim...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ElevatedButton(
              onPressed: _submitClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                "Submit Claim",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}
