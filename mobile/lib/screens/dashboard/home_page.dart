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
              _buildLocationBar(),
              _buildWeatherCard(),
              _buildMyFarmsSection(),
            ],
          ),
        );
    }
  }

  Widget _buildHeader() {
  String currentDate = "Today"; // We can improve this
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    decoration: BoxDecoration(
      color: Colors.green[800],
      borderRadius: const BorderRadius.only(
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
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                currentDate,
                style: TextStyle(color: Colors.green[100], fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: _fetchDashboardData, 
          ),
        ],
      ),
    ),
  ); 
}

  // --- Location/Notification Bar ---
  Widget _buildLocationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.menu, color: Colors.grey[800], size: 28),

          // Farm Location Dropdown
          if (_farmList.isNotEmpty) // Only show if farms exist
            PopupMenuButton<Farm>(
              onSelected: _onFarmSelected,
              itemBuilder: (BuildContext context) {
                return _farmList.map((farm) {
                  return PopupMenuItem<Farm>(
                    value: farm,
                    child: Text(farm.farmID), // Show Farm ID in dropdown
                  );
                }).toList();
              },
              child: Row(
                children: [
                  Text(
                    _selectedFarm?.farmID ?? "No Farms", // REAL DATA
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900]),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                ],
              ),
            ),
          
          if (_farmList.isEmpty) // Show if no farms
            const Text("No Farms Added Yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          IconButton(
            icon: Badge(
              label: const Text('5'),
              child: Icon(Icons.notifications_none, color: Colors.grey[800], size: 28),
            ),
            onPressed: () {}, // TODO: Navigate to Notifications Page
          ),
        ],
      ),
    );
  }

  // --- Weather Card ---
  Widget _buildWeatherCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          child: _buildWeatherContent(), // AnimatedSwitcher logic
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    // Show a loading spinner *inside* the card
    if (_weatherData == null && _farmList.isNotEmpty) {
      return const Center(
        key: ValueKey('weather_loading'),
        child: CircularProgressIndicator(),
      );
    }

    // Show message if no farms exist
    if (_farmList.isEmpty) {
       return const Center(
        key: ValueKey('no_farms'),
        child: Text("Add a farm to see weather info."),
      );
    }

    // --- This is the main UI for when data is ready ---
    return Column(
      key: ValueKey('data-${_selectedFarm?.farmID}'),
      children: [
        Icon(_getWeatherIcon(_weatherData!.weatherCode), size: 80, color: Colors.blue[400]),
        const SizedBox(height: 16),
        Text(
          '${_weatherData!.temperature.toStringAsFixed(0)}°C', // REAL DATA
          style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.grey[900]),
        ),

        const SizedBox(height: 8),
        Text(
          _weatherData!.weatherCondition, // REAL DATA
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWeatherStat('${_weatherData!.humidity.toStringAsFixed(0)}%', "Humidity"),
            _buildWeatherStat('${_weatherData!.precipitation.toStringAsFixed(1)} mm', "Precipitation"),
            _buildWeatherStat('${_weatherData!.windSpeed.toStringAsFixed(1)} m/s', "Wind Speed"),
          ],
        ),
      ],
    );
  }

  // --- My Farms Section ---
  Widget _buildMyFarmsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My farms",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: This should tap the 'Farms' tab
                },
                child: const Text("View all"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          if (_farmList.isEmpty) // Show if no farms
            const Center(child: Text("You haven't added any farms yet.")),

          // Farm List
          ListView.builder(
            itemCount: _farmList.length > 3 ? 3 : _farmList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final farm = _farmList[index];
              return Card(
                elevation: 0.5,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(farm.farmID), // REAL DATA
                  subtitle: Text("Crop: ${farm.cropType}  |  Status: ${farm.status}"), // REAL DATA
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
          ),
        ],
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