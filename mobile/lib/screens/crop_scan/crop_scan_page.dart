import 'package:flutter/material.dart';

class CropScanPage extends StatefulWidget {
  const CropScanPage({super.key});

  @override
  State<CropScanPage> createState() => _CropScanPageState();
}

class _CropScanPageState extends State<CropScanPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Color?> _colorAnimation;

  ScanStatus _scanStatus = ScanStatus.ready;
  double _scanProgress = 0.0;
  final List<ScanResult> _scanResults = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.green,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startScan() async {
    setState(() {
      _scanStatus = ScanStatus.scanning;
      _scanProgress = 0.0;
      _scanResults.clear();
    });

    _controller.reset();
    _controller.forward();

    // Simulate scan progress
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _scanProgress = i.toDouble();
        });
      }
    }

    // Generate scan results
    await _generateScanResults();

    setState(() {
      _scanStatus = ScanStatus.completed;
    });
  }

  Future<void> _generateScanResults() async {
    final results = [
      ScanResult(
        parameter: 'Leaf Health',
        value: 87,
        status: HealthStatus.healthy,
        description: 'Leaves show optimal chlorophyll content',
        recommendation: 'Continue current nutrient regimen',
      ),
      ScanResult(
        parameter: 'Pest Detection',
        value: 12,
        status: HealthStatus.lowRisk,
        description: 'Minimal pest activity detected',
        recommendation: 'Monitor for aphids in next 7 days',
      ),
      ScanResult(
        parameter: 'Disease Risk',
        value: 25,
        status: HealthStatus.moderate,
        description: 'Moderate risk of fungal infection',
        recommendation: 'Apply preventive fungicide treatment',
      ),
      ScanResult(
        parameter: 'Nutrient Levels',
        value: 78,
        status: HealthStatus.healthy,
        description: 'Adequate nitrogen and potassium levels',
        recommendation: 'Maintain current fertilization schedule',
      ),
      ScanResult(
        parameter: 'Water Stress',
        value: 15,
        status: HealthStatus.healthy,
        description: 'Optimal soil moisture levels',
        recommendation: 'Continue current irrigation pattern',
      ),
      ScanResult(
        parameter: 'Growth Stage',
        value: 65,
        status: HealthStatus.healthy,
        description: 'Crop in flowering stage',
        recommendation: 'Prepare for pollination phase',
      ),
    ];

    for (final result in results) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _scanResults.add(result);
        });
      }
    }
  }

  void _resetScan() {
    setState(() {
      _scanStatus = ScanStatus.ready;
      _scanProgress = 0.0;
      _scanResults.clear();
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Crop Health Scan',
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
          if (_scanStatus == ScanStatus.completed)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.green[800]),
              onPressed: _resetScan,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Scan Area
            _buildScanArea(),
            const SizedBox(height: 30),

            // Progress Section
            if (_scanStatus == ScanStatus.scanning) _buildProgressSection(),

            // Results Section
            if (_scanStatus == ScanStatus.completed) _buildResultsSection(),

            // Action Button
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanArea() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[50]!,
            Colors.lightGreen[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Scanner Frame
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),

          // Scanning Animation
          if (_scanStatus == ScanStatus.scanning)
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  left: 0,
                  right: 0,
                  top: _scanAnimation.value * 250 - 2,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green[400]!.withOpacity(0.8),
                          Colors.green,
                          Colors.green[400]!.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 64,
                  color: _getStatusColor(),
                ),
                const SizedBox(height: 16),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusSubtext(),
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
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
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Scanning in Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _scanProgress / 100,
                backgroundColor: Colors.grey[200],
                valueColor:
                    AlwaysStoppedAnimation<Color>(_colorAnimation.value!),
                borderRadius: BorderRadius.circular(10),
                minHeight: 12,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Analyzing crop health...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${_scanProgress.toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsSection() {
    return Container(
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
              Icon(Icons.assignment_turned_in, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Scan Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._scanResults.map((result) => _buildResultCard(result)),
        ],
      ),
    );
  }

  Widget _buildResultCard(ScanResult result) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(result.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: _getStatusColor(result.status).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(result.status),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getHealthIcon(result.status),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      result.parameter,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${result.value}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(result.status),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  result.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '💡 ${result.recommendation}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _scanStatus == ScanStatus.ready ? _startScan : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: Colors.green.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _scanStatus == ScanStatus.ready ? Icons.play_arrow : Icons.check,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _scanStatus == ScanStatus.ready
                  ? 'Start Health Scan'
                  : 'Scan Completed',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  IconData _getStatusIcon() {
    switch (_scanStatus) {
      case ScanStatus.ready:
        return Icons.camera_alt;
      case ScanStatus.scanning:
        return Icons.scanner;
      case ScanStatus.completed:
        return Icons.verified;
    }
  }

  Color _getStatusColor([HealthStatus? status]) {
    if (status != null) {
      switch (status) {
        case HealthStatus.healthy:
          return Colors.green;
        case HealthStatus.lowRisk:
          return Colors.blue;
        case HealthStatus.moderate:
          return Colors.orange;
        case HealthStatus.critical:
          return Colors.red;
      }
    }

    switch (_scanStatus) {
      case ScanStatus.ready:
        return Colors.green;
      case ScanStatus.scanning:
        return Colors.orange;
      case ScanStatus.completed:
        return Colors.green;
    }
  }

  String _getStatusText() {
    switch (_scanStatus) {
      case ScanStatus.ready:
        return 'Ready to Scan';
      case ScanStatus.scanning:
        return 'Scanning in Progress';
      case ScanStatus.completed:
        return 'Scan Complete';
    }
  }

  String _getStatusSubtext() {
    switch (_scanStatus) {
      case ScanStatus.ready:
        return 'Position your device to capture crop images for AI analysis';
      case ScanStatus.scanning:
        return 'Analyzing plant health, nutrients, and potential risks';
      case ScanStatus.completed:
        return 'Detailed health report generated successfully';
    }
  }

  IconData _getHealthIcon(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return Icons.check_circle;
      case HealthStatus.lowRisk:
        return Icons.info;
      case HealthStatus.moderate:
        return Icons.warning;
      case HealthStatus.critical:
        return Icons.error;
    }
  }
}

enum ScanStatus { ready, scanning, completed }

enum HealthStatus { healthy, lowRisk, moderate, critical }

class ScanResult {
  final String parameter;
  final int value;
  final HealthStatus status;
  final String description;
  final String recommendation;

  ScanResult({
    required this.parameter,
    required this.value,
    required this.status,
    required this.description,
    required this.recommendation,
  });
}
