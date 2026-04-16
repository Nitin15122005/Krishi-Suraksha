import 'package:flutter/material.dart';
import 'package:agri_claim_mobile/services/api_service.dart';
import 'package:agri_claim_mobile/services/storage_service.dart';
import 'package:agri_claim_mobile/models/weather_model.dart';
import 'package:agri_claim_mobile/models/farm_model.dart';
import 'package:agri_claim_mobile/screens/farm/farm_details_page.dart';
// Enum to manage our complex loading state
enum PageStatus { loading, ready, error }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // --- State Variables ---
  PageStatus _pageStatus = PageStatus.loading;
  String _pageError = '';
  
  // Data
  String _farmerName = "Farmer";
  List<Farm> _farmList = [];
  AppWeather? _weatherData;
  // Selected Farm
  Farm? _selectedFarm;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _pageStatus = PageStatus.loading;
    });

    try {
      // 1. Get farmer's name from storage
      final name = await _storageService.getFarmerName();
      // 2. Fetch all farms
      final farms = await _apiService.getFarms();

      // 3. Check if we have farms
      if (farms.isEmpty) {
        // No farms yet, just show the welcome message
        setState(() {
          _farmerName = name ?? "Farmer";
          _pageStatus = PageStatus.ready;
          _farmList = [];
        });
        return; // Stop here
      }

      // 4. We have farms! Select the first one.
      final firstFarm = farms.first;

      // 5. Fetch weather for that first farm
      final weather = await _apiService.getWeather(
        firstFarm.latitude,
        firstFarm.longitude,
      );

      // 6. All data is loaded. Update the UI.
      setState(() {
        _farmerName = name ?? "Farmer";
        _farmList = farms;
        _selectedFarm = firstFarm;
        _weatherData = weather;
        _pageStatus = PageStatus.ready;
      });

    } catch (e) {
      setState(() {
        _pageStatus = PageStatus.error;
        _pageError = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  // Called when user selects a different farm from the dropdown
  Future<void> _onFarmSelected(Farm farm) async {
    setState(() {
      _selectedFarm = farm;
      _weatherData = null; // Set weather to null to show loading
    });

    try {
      // Fetch new weather for the selected farm
      final weather = await _apiService.getWeather(
        farm.latitude,
        farm.longitude,
      );
      setState(() {
        _weatherData = weather;
      });
    } catch (e) {

      // Handle error for weather fetch
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not fetch weather: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _buildBodyContent(), // Build body based on status
    );
  }

  // --- Body Content Switcher ---

  Widget _buildBodyContent() {
    switch (_pageStatus) {
      case PageStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case PageStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: $_pageError',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchDashboardData,
                  child: const Text('Try Again'),
                )
              ],
            ),
          ),
        );

      case PageStatus.ready:
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
               _buildWeatherCard(),
              _buildMyFarmsSection(),
              _buildQuickActions(),
             
            ],
          ),
        );
    }
  }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $_farmerName",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Welcome back",
                style: TextStyle(
                  color: Color.fromARGB(255, 54, 58, 55),
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const Spacer(),

          // 🔔 Notification moved here
          IconButton(
            icon: const Badge(
              label: Text('5'),
              child: Icon(Icons.notifications_none, color: Colors.black),
            ),
            onPressed: () {},
          ),

          // 🔄 Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchDashboardData,
          ),
        ],
      ),
    ),
  );
}  
  // --- Location/Notification Bar ---

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
  // --- Weather Card ---
 Widget _buildWeatherCard() {
  return Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(20),
    decoration: _cardDecoration(),
    child: _buildWeatherContent(),
  );
}

 Widget _buildWeatherContent() {
  if (_weatherData == null && _farmList.isNotEmpty) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_farmList.isEmpty) {
    return const Center(child: Text("Add a farm to see weather info."));
  }

  return Column(
    children: [
      Icon(
        _getWeatherIcon(_weatherData!.weatherCode),
        size: 70,
        color: const Color(0xFFA9E981),
      ),

      const SizedBox(height: 12),

      Text(
        '${_weatherData!.temperature.toStringAsFixed(0)}°C',
        style: const TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: Color(0xFF173300),
        ),
      ),

      const SizedBox(height: 6),

      Text(
        _weatherData!.weatherCondition,
        style: TextStyle(color: Colors.grey[600]),
      ),

      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 14),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildWeatherStat(
              '${_weatherData!.humidity.toStringAsFixed(0)}%', "Humidity"),
          _buildWeatherStat(
              '${_weatherData!.precipitation.toStringAsFixed(1)} mm', "Rain"),
          _buildWeatherStat(
              '${_weatherData!.windSpeed.toStringAsFixed(1)} m/s', "Wind"),
        ],
      ),
    ],
  );
}
  // --- My Farms Section ---
  Widget _buildMyFarmsSection() {
  return Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(18),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "My Farms",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF173300),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("View all"),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 🔹 Empty State
        if (_farmList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "No farms added yet",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

        // 🔹 Scrollable Area (FIXED HEIGHT)
        if (_farmList.isNotEmpty)
          SizedBox(
            
            height: 160, // 🔥 FIXED HEIGHT
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _farmList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final farm = _farmList[index];

                final isSelected =
                    _selectedFarm?.farmID == farm.farmID;

                return GestureDetector(
                  onTap: () {
                    _onFarmSelected(farm);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEAF5E4) // selected highlight
                          : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: const Color.fromARGB(93, 80, 161, 81), width: 1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco,
                        color: Color(0xFF000000)),
                            // color: Color(0xFFA9E981)),
                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                farm.farmID,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Crop: ${farm.cropType}",
                                style: TextStyle(
                                    color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.arrow_forward_ios,
                            size: 14),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );
}

Widget _buildQuickActions() {
  return Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(60),
    ),
    child: Row(
      children: [
        _actionPill(
          icon: Icons.add,
          label: "Add Farm",
          isActive: true,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _actionPill(
          icon: Icons.analytics_outlined,
          label: "Prediction",
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _actionPill(
          icon: Icons.description_outlined,
          label: "Reports",
          onTap: () {},
        ),
      ],
    ),
  );
}
Widget _actionPill({
  required IconData icon,
  required String label,
  bool isActive = false,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA9E981) : Colors.grey[100],
          borderRadius: BorderRadius.circular(48),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.black),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),
  );

}
  // Helper for the small weather stat columns
   Widget _buildWeatherStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Helper to get an icon from the weather code
  IconData _getWeatherIcon(int code) {
    switch (code) {
      case 1000: // Clear
        return Icons.wb_sunny_outlined;
      case 1100: // Mostly Clear
      case 1101: // Partly Cloudy
      case 1102: // Mostly Cloudy
        return Icons.wb_cloudy_outlined;
      case 1001: // Cloudy
        return Icons.cloud_outlined;
      case 4000: // Drizzle
      case 4001: // Rain
      case 4200: // Light Rain
      case 4201: // Heavy Rain
        return Icons.grain_outlined; // Represents rain
      case 8000: // Thunderstorm
        return Icons.thunderstorm_outlined;
      default:
        return Icons.wb_cloudy_outlined;
    }
  }
}