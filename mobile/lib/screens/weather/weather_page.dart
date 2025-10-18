import 'package:flutter/material.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // TODO: BACKEND - Replace with actual weather API data
  final Map<String, dynamic> _currentWeather = {
    'temperature': 28,
    'feelsLike': 30,
    'condition': 'Sunny',
    'humidity': 65,
    'windSpeed': 12,
    'pressure': 1013,
    'visibility': 10,
    'uvIndex': 7,
    'sunrise': '6:30 AM',
    'sunset': '6:45 PM',
    'location': 'Farm Field, Agricultural Zone',
  };

  final List<Map<String, dynamic>> _hourlyForecast = [
    {'time': 'Now', 'temp': 28, 'icon': Icons.wb_sunny, 'rain': 0},
    {'time': '1 PM', 'temp': 29, 'icon': Icons.wb_sunny, 'rain': 0},
    {'time': '2 PM', 'temp': 30, 'icon': Icons.wb_sunny, 'rain': 0},
    {'time': '3 PM', 'temp': 29, 'icon': Icons.wb_cloudy, 'rain': 10},
    {'time': '4 PM', 'temp': 28, 'icon': Icons.wb_cloudy, 'rain': 20},
    {'time': '5 PM', 'temp': 27, 'icon': Icons.grain, 'rain': 40},
    {'time': '6 PM', 'temp': 26, 'icon': Icons.grain, 'rain': 30},
    {'time': '7 PM', 'temp': 25, 'icon': Icons.nightlight_round, 'rain': 10},
    {'time': '8 PM', 'temp': 24, 'icon': Icons.nightlight_round, 'rain': 5},
    {'time': '9 PM', 'temp': 23, 'icon': Icons.nightlight_round, 'rain': 0},
  ];

  final List<Map<String, dynamic>> _dailyForecast = [
    {'day': 'Today', 'high': 30, 'low': 22, 'icon': Icons.wb_sunny, 'rain': 20},
    {'day': 'Wed', 'high': 29, 'low': 21, 'icon': Icons.wb_cloudy, 'rain': 40},
    {'day': 'Thu', 'high': 28, 'low': 20, 'icon': Icons.grain, 'rain': 60},
    {
      'day': 'Fri',
      'high': 27,
      'low': 19,
      'icon': Icons.thunderstorm,
      'rain': 80
    },
    {'day': 'Sat', 'high': 29, 'low': 21, 'icon': Icons.wb_cloudy, 'rain': 30},
    {'day': 'Sun', 'high': 31, 'low': 23, 'icon': Icons.wb_sunny, 'rain': 10},
    {'day': 'Mon', 'high': 32, 'low': 24, 'icon': Icons.wb_sunny, 'rain': 5},
  ];

  final List<Map<String, dynamic>> _weatherAlerts = [
    {
      'type': 'warning',
      'title': 'Heat Advisory',
      'message': 'High temperatures may affect crop growth',
      'time': 'Active until 5 PM'
    },
    {
      'type': 'info',
      'title': 'Rain Expected',
      'message': '40% chance of rain tomorrow afternoon',
      'time': 'Starts 2 PM tomorrow'
    },
  ];

  final List<Map<String, dynamic>> _agriculturalMetrics = [
    {
      'name': 'Soil Moisture',
      'value': 78,
      'status': 'Optimal',
      'trend': 'stable'
    },
    {'name': 'Evaporation', 'value': 5.2, 'status': 'Normal', 'trend': 'up'},
    {
      'name': 'Dew Point',
      'value': 19,
      'status': 'Comfortable',
      'trend': 'stable'
    },
    {'name': 'Growing Degree', 'value': 12, 'status': 'Good', 'trend': 'up'},
    {'name': 'Soil Temp', 'value': 24, 'status': 'Optimal', 'trend': 'stable'},
    {'name': 'Wind Speed', 'value': 12, 'status': 'Moderate', 'trend': 'down'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Weather Forecast',
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
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.green[800]),
            onPressed: _refreshWeather,
          ),
          IconButton(
            icon: Icon(Icons.location_on, color: Colors.green[800]),
            onPressed: _changeLocation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Current Weather Card - KEEPING ORIGINAL
            _buildCurrentWeatherCard(),
            const SizedBox(height: 20),

            // Hourly Forecast - MODIFIED
            _buildHourlyForecast(),
            const SizedBox(height: 20),

            // Daily Forecast - KEEPING ORIGINAL
            _buildDailyForecast(),
            const SizedBox(height: 20),

            // Weather Alerts - KEEPING ORIGINAL
            if (_weatherAlerts.isNotEmpty) ...[
              _buildWeatherAlerts(),
              const SizedBox(height: 20),
            ],

            // Agricultural Metrics - MODIFIED
            _buildAgriculturalMetrics(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!,
            Colors.lightBlue[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Location and Time
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[700], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentWeather['location'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                  ),
                ),
              ),
              Text(
                'Updated now',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Temperature and Condition
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    '${_currentWeather['temperature']}°',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: Colors.blue[900],
                    ),
                  ),
                  Text(
                    _currentWeather['condition'],
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Feels like ${_currentWeather['feelsLike']}°',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.wb_sunny,
                color: Colors.orange,
                size: 80,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weather Details Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _WeatherDetail(
                icon: Icons.water_drop,
                value: '${_currentWeather['humidity']}%',
                label: 'Humidity',
                color: Colors.blue,
              ),
              _WeatherDetail(
                icon: Icons.air,
                value: '${_currentWeather['windSpeed']} km/h',
                label: 'Wind',
                color: Colors.green,
              ),
              _WeatherDetail(
                icon: Icons.speed,
                value: '${_currentWeather['pressure']} hPa',
                label: 'Pressure',
                color: Colors.purple,
              ),
              _WeatherDetail(
                icon: Icons.visibility,
                value: '${_currentWeather['visibility']} km',
                label: 'Visibility',
                color: Colors.orange,
              ),
              _WeatherDetail(
                icon: Icons.light_mode,
                value: '${_currentWeather['uvIndex']}',
                label: 'UV Index',
                color: Colors.red,
              ),
              _WeatherDetail(
                icon: Icons.wb_twilight,
                value: '${_currentWeather['sunrise']}',
                label: 'Sunrise',
                color: Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Forecast',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        // Fixed height container for horizontal scroll - MODIFIED
        Container(
          height: 110, // Reduced height to prevent overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hourlyForecast.length,
            itemBuilder: (context, index) {
              final hour = _hourlyForecast[index];
              return Container(
                width: 70, // Reduced width for each card
                margin: EdgeInsets.only(
                  right: index == _hourlyForecast.length - 1 ? 0 : 8,
                ),
                child: _HourlyForecastCard(forecast: hour),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast() {
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
          Text(
            '7-Day Forecast',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: _dailyForecast
                .map((day) => _DailyForecastRow(forecast: day))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherAlerts() {
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
              Icon(Icons.warning_amber, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Weather Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: _weatherAlerts
                .map((alert) => _WeatherAlertCard(alert: alert))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgriculturalMetrics() {
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
              Icon(Icons.agriculture, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Agricultural Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dynamic grid height based on number of items - MODIFIED
          Container(
            height: (_agriculturalMetrics.length / 2).ceil() *
                100.0, // Calculate height based on rows
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6, // Consistent aspect ratio
              ),
              itemCount: _agriculturalMetrics.length,
              itemBuilder: (context, index) {
                final metric = _agriculturalMetrics[index];
                return _AgriculturalMetricCard(metric: metric);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _refreshWeather() {
    // TODO: BACKEND - Refresh weather data from API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Refreshing weather data...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _changeLocation() {
    // TODO: Implement location change
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Location'),
        content: Text('Location change feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _WeatherDetail({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _HourlyForecastCard extends StatelessWidget {
  final Map<String, dynamic> forecast;

  const _HourlyForecastCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly, // Better space distribution
        children: [
          Text(
            forecast['time'],
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
              fontSize: 11, // Smaller font
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Icon(forecast['icon'], color: Colors.blue, size: 20), // Smaller icon
          Text(
            '${forecast['temp']}°',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              fontSize: 12, // Smaller font
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.water_drop,
                  color: Colors.blue, size: 10), // Smaller icon
              const SizedBox(width: 2),
              Text(
                '${forecast['rain']}%',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 9, // Smaller font
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyForecastRow extends StatelessWidget {
  final Map<String, dynamic> forecast;

  const _DailyForecastRow({required this.forecast});

  @override
  Widget build(BuildContext context) {
    Color rainColor = forecast['rain'] > 60
        ? Colors.red
        : forecast['rain'] > 30
            ? Colors.orange
            : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              forecast['day'],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(forecast['icon'], color: Colors.blue, size: 20),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.water_drop, color: rainColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${forecast['rain']}%',
                  style: TextStyle(
                    color: rainColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${forecast['high']}°',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${forecast['low']}°',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherAlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;

  const _WeatherAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    Color color = alert['type'] == 'warning' ? Colors.orange : Colors.blue;
    IconData icon =
        alert['type'] == 'warning' ? Icons.warning_amber : Icons.info;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert['message'],
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert['time'],
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgriculturalMetricCard extends StatelessWidget {
  final Map<String, dynamic> metric;

  const _AgriculturalMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    Color color = metric['status'] == 'Optimal' || metric['status'] == 'Good'
        ? Colors.green
        : metric['status'] == 'Normal' || metric['status'] == 'Comfortable'
            ? Colors.blue
            : Colors.orange;

    IconData trendIcon = metric['trend'] == 'up'
        ? Icons.arrow_upward
        : metric['trend'] == 'down'
            ? Icons.arrow_downward
            : Icons.arrow_forward;

    Color trendColor = metric['trend'] == 'up'
        ? Colors.green
        : metric['trend'] == 'down'
            ? Colors.red
            : Colors.grey;

    String unit = '';
    if (metric['name'] == 'Soil Moisture') unit = '%';
    if (metric['name'] == 'Evaporation') unit = ' mm';
    if (metric['name'] == 'Dew Point' || metric['name'] == 'Soil Temp')
      unit = '°C';
    if (metric['name'] == 'Growing Degree') unit = '°';
    if (metric['name'] == 'Wind Speed') unit = ' km/h';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric['name'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Icon(trendIcon, color: trendColor, size: 12),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${metric['value']}$unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric['status'],
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
