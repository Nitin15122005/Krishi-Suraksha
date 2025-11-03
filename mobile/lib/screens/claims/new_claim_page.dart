import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agri_claim_mobile/models/farm_model.dart';
import 'package:agri_claim_mobile/services/api_service.dart';
import 'package:agri_claim_mobile/services/cloudinary_service.dart';
import 'package:agri_claim_mobile/services/storage_service.dart'; 

class NewClaimPage extends StatefulWidget {
  final List<Farm> farms;
  const NewClaimPage({super.key, required this.farms});

  @override
  State<NewClaimPage> createState() => _NewClaimPageState();
}

class _NewClaimPageState extends State<NewClaimPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final StorageService _storageService = StorageService();

  final _damageDateController = TextEditingController();
  final _damageTypeController = TextEditingController();
  final _descriptionController = TextEditingController();

  Farm? _selectedFarm;
  final List<File> _evidenceFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  final List<String> _damageTypes = [
    'Pest Attack',
    'Flood Damage',
    'Drought',
    'Storm/Hail Damage',
    'Fire Damage',
    'Heavy Rainfall',
    'Other Natural Calamity'
  ];
  
  @override
  void dispose() {
    _damageDateController.dispose();
    _damageTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _damageDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _addEvidence(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _evidenceFiles.add(File(pickedFile.path));
      });
    }
  }

  void _removeEvidence(int index) {
    setState(() {
      _evidenceFiles.removeAt(index);
    });
  }

  void _showSuccessDialog(String claimID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(children: const [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8), Text("Claim Submitted"),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your claim has been submitted successfully!"),
            SizedBox(height: 8),
            Text(
              "Claim ID: $claimID",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 8),
            Text("Satellite analysis is now in progress.", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous page
            },
            child: Text("Done"),
          ),
        ],
      ),
    );
  }

  void _submitClaim() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedFarm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a farm'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Get FarmerID for folder path
      final farmerID = await _storageService.getFarmerID();
      if (farmerID == null) throw Exception("User not logged in.");

      // 2. Generate ClaimID
      final String claimID = "CLAIM_${DateTime.now().millisecondsSinceEpoch}";
      
      // 3. Upload Evidence Files to Cloudinary
      List<String> evidenceHashes = []; 
      
      for (var file in _evidenceFiles) {
        final String fileUrl = await _cloudinaryService.uploadFile(
          file,
          claimID,
          farmerID,
        );
        evidenceHashes.add(fileUrl);
      }
      
      // 4. Call the API Service with the list of URLs
      final message = await _apiService.submitClaim(
        claimID: claimID,
        farmID: _selectedFarm!.farmID,
        reason: _damageTypeController.text,
        damageDate: _damageDateController.text,
        evidenceHashes: evidenceHashes,
        description: _descriptionController.text,
      );

      _showSuccessDialog(claimID);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
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
              _buildHeaderSection(),
              const SizedBox(height: 30),
              
              // --- SECTION 1: FARM SELECTION (MODIFIED) ---
              _buildSection(
                title: "Select Farm",
                icon: Icons.agriculture,
                children: [
                  // This is now a "smart" dropdown
                  DropdownButtonFormField<Farm>(
                    decoration: _buildInputDecoration(hintText: 'Select your farm', icon: Icons.grass),
                    value: _selectedFarm,
                    items: widget.farms.map((farm) {
                      return DropdownMenuItem<Farm>(
                        value: farm,
                        // Show FarmID and CropType
                        child: Text("${farm.farmID} (${farm.cropType})"),
                      );
                    }).toList(),
                    onChanged: (Farm? farm) {
                      setState(() {
                        _selectedFarm = farm;
                        // Auto-fill crop type!
                        if (farm != null) {
                          _damageTypeController.text = ''; 
                        }
                      });
                    },
                    validator: (value) => (value == null) ? 'Please select a farm' : null,
                  ),
                ],
              ),
              const SizedBox(height: 25),

              _buildSection(
                title: "Damage Details",
                icon: Icons.warning_amber,
                children: [
                  _buildDropdownField(
                    controller: _damageTypeController,
                    label: "Type of Damage",
                    hintText: "Select damage type",
                    items: _damageTypes,
                    validator: (value) => (value == null || value.isEmpty) ? 'Please select damage type' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _damageDateController,
                    label: "Date of Damage",
                    hintText: "Select date",
                    icon: Icons.calendar_today,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please select damage date' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _descriptionController,
                    label: "Damage Description (Optional)",
                    hintText: "Describe the damage...",
                    icon: Icons.description,
                    maxLines: 3,
                    validator: (value) => null, // Optional
                  ),
                ],
              ),
              const SizedBox(height: 25),

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
  
  // Widget _buildEvidenceSection() {
  //   return _buildSection(
  //     title: "Evidence (Optional)",
  //     icon: Icons.attach_file,
  //     children: [
  //       Container(
  //         width: double.infinity,
  //         height: 100,
  //         decoration: BoxDecoration(
  //           color: Colors.grey[50],
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(
  //             color: Colors.grey[300]!,
  //             style: BorderStyle.solid,
  //           ),
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             IconButton(
  //               icon: Icon(Icons.camera_alt, color: Colors.grey[600], size: 40),
  //               onPressed: () => _addEvidence(ImageSource.camera),
  //             ),
  //             IconButton(
  //               icon: Icon(Icons.photo_library, color: Colors.grey[600], size: 40),
  //               onPressed: () => _addEvidence(ImageSource.gallery),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       // Display picked files
  //       GridView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
  //         ),
  //         itemCount: _evidenceFiles.length,
  //         itemBuilder: (context, index) {
  //           // return Stack(
  //           //   children: [
  //           //     Image.file(_evidenceFiles[index], fit: BoxFit.cover),
  //           //     Positioned(
  //           //       top: 0, right: 0,
  //           //       child: GestureDetector(
  //           //         onTap: () => _removeEvidence(index),
  //           //         child: Container(
  //           //           decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
  //           //           child: Icon(Icons.close, color: Colors.white, size: 16),
  //           //         ),
  //           //       ),
  //           //     ),
  //           //   ],
  //           // );
  //           return Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: Colors.grey[300]!),
  //             ),
  //             child: Stack(
  //               fit: StackFit.expand,
  //               children: [
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.circular(8),
  //                   child: Image.file(_evidenceFiles[index], fit: BoxFit.cover),
  //                 ),
  //                 Positioned(
  //                   top: -10, right: -10,
  //                   child: IconButton(
  //                     icon: Icon(Icons.cancel, color: Colors.red.withOpacity(0.9)),
  //                     onPressed: () => _removeEvidence(index),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _buildEvidenceSection() {
    return _buildSection(
      title: "Evidence (Optional)",
      icon: Icons.attach_file,
      children: [
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEvidenceButton(
                icon: Icons.camera_alt,
                label: "Camera",
                onPressed: () => _addEvidence(ImageSource.camera),
              ),
              VerticalDivider(indent: 20, endIndent: 20),
              _buildEvidenceButton(
                icon: Icons.photo_library,
                label: "Gallery",
                onPressed: () => _addEvidence(ImageSource.gallery),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
          ),
          itemCount: _evidenceFiles.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_evidenceFiles[index], fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: -10, right: -10,
                    child: IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red.withOpacity(0.9)),
                      onPressed: () => _removeEvidence(index),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildEvidenceButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green[700], size: 32),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.green[700])),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, required IconData icon}) {
     return InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        prefixIcon: Icon(icon, color: Colors.green),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  "Satellite analysis will automatically assess damage percentage after submission.",
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
                children: const [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
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