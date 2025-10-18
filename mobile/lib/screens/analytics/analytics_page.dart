import 'package:flutter/material.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  // TODO: BACKEND - Replace with actual API data from satellite/database
  final Map<String, dynamic> _cropData = {
    'cropName': 'Wheat',
    'cropHealth': 0.82,
    'growthStage': 'Flowering',
    'plantingDate': '2024-10-15',
    'expectedHarvest': '2025-03-20',
    'totalArea': '5.2 acres',
    'soilHealth': 0.75,
    'ndviIndex': 0.68,
    'ndwiIndex': 0.45,
    'temperature': 28.5,
    'humidity': 65.0,
    'rainfall': 120.0,
    'pestRisk': 'Low',
    'diseaseRisk': 'Medium',
    'nutrientStatus': 'Optimal',
    'yieldPrediction': '3.2 tons/acre',
  };

  final List<Map<String, dynamic>> _healthMetrics = [
    {
      'name': 'Soil Moisture',
      'value': 0.78,
      'status': 'Optimal',
      'trend': 'up'
    },
    {'name': 'Chlorophyll', 'value': 0.65, 'status': 'Good', 'trend': 'stable'},
    {'name': 'Nitrogen', 'value': 0.72, 'status': 'Optimal', 'trend': 'up'},
    {'name': 'Water Stress', 'value': 0.15, 'status': 'Low', 'trend': 'down'},
    {'name': 'Biomass', 'value': 0.81, 'status': 'High', 'trend': 'up'},
  ];

  final List<Map<String, dynamic>> _satelliteData = [
    {'date': 'Dec 20', 'ndvi': 0.72, 'health': 0.85},
    {'date': 'Dec 15', 'ndvi': 0.68, 'health': 0.82},
    {'date': 'Dec 10', 'ndvi': 0.65, 'health': 0.78},
    {'date': 'Dec 05', 'ndvi': 0.62, 'health': 0.75},
    {'date': 'Dec 01', 'ndvi': 0.58, 'health': 0.70},
  ];

  final List<Map<String, dynamic>> _weatherForecast = [
    {'day': 'Today', 'temp': '28°C', 'rain': '10%', 'icon': Icons.wb_sunny},
    {'day': 'Tom', 'temp': '27°C', 'rain': '20%', 'icon': Icons.wb_cloudy},
    {'day': 'Wed', 'temp': '26°C', 'rain': '40%', 'icon': Icons.grain},
    {'day': 'Thu', 'temp': '25°C', 'rain': '30%', 'icon': Icons.wb_cloudy},
    {'day': 'Fri', 'temp': '28°C', 'rain': '10%', 'icon': Icons.wb_sunny},
  ];

  final List<Map<String, dynamic>> _alerts = [
    {
      'type': 'warning',
      'title': 'Moderate Disease Risk',
      'message': 'Watch for fungal infections due to humidity',
      'time': '2 hours ago'
    },
    {
      'type': 'info',
      'title': 'Optimal Growth Phase',
      'message': 'Crop is in flowering stage - monitor nutrients',
      'time': '1 day ago'
    },
    {
      'type': 'success',
      'title': 'Irrigation Complete',
      'message': 'Soil moisture levels optimal',
      'time': '2 days ago'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Crop Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.green[800]),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Crop Overview Card
            _buildCropOverviewCard(),
            const SizedBox(height: 20),

            // Health Metrics Grid
            _buildHealthMetricsGrid(),
            const SizedBox(height: 20),

            // Satellite Data Section
            _buildSatelliteDataSection(),
            const SizedBox(height: 20),

            // Weather & Environment
            _buildWeatherSection(),
            const SizedBox(height: 20),

            // Risk Analysis
            _buildRiskAnalysisSection(),
            const SizedBox(height: 20),

            // Alerts & Notifications
            _buildAlertsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCropOverviewCard() {
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.agriculture, color: Colors.green, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cropData['cropName'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_cropData['totalArea']} • ${_cropData['growthStage']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildHealthIndicator(_cropData['cropHealth']),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _OverviewItem(
                  label: 'Planting Date',
                  value: _formatDate(_cropData['plantingDate']),
                  icon: Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _OverviewItem(
                  label: 'Expected Harvest',
                  value: _formatDate(_cropData['expectedHarvest']),
                  icon: Icons.agriculture,
                ),
              ),
              Expanded(
                child: _OverviewItem(
                  label: 'Yield Prediction',
                  value: _cropData['yieldPrediction'],
                  icon: Icons.analytics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: _healthMetrics.length,
          itemBuilder: (context, index) {
            final metric = _healthMetrics[index];
            return _HealthMetricCard(metric: metric);
          },
        ),
      ],
    );
  }

  Widget _buildSatelliteDataSection() {
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
              Icon(Icons.satellite, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Satellite Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.speed, color: Colors.blue, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'NDVI: ${_cropData['ndviIndex']}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _satelliteData.length,
                          itemBuilder: (context, index) {
                            final data = _satelliteData[index];
                            return _SatelliteDataRow(data: data);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: _buildNDVIGauge(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSection() {
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
              Icon(Icons.cloud, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Weather & Environment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _WeatherMetric(
                  label: 'Temperature',
                  value: '${_cropData['temperature']}°C',
                  icon: Icons.thermostat,
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _WeatherMetric(
                  label: 'Humidity',
                  value: '${_cropData['humidity']}%',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _WeatherMetric(
                  label: 'Rainfall',
                  value: '${_cropData['rainfall']}mm',
                  icon: Icons.beach_access,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _weatherForecast.length,
              itemBuilder: (context, index) {
                final forecast = _weatherForecast[index];
                return _WeatherForecastCard(forecast: forecast);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAnalysisSection() {
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
              Icon(Icons.warning, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Risk Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _RiskIndicator(
                  label: 'Pest Risk',
                  level: _cropData['pestRisk'],
                  color: _getRiskColor(_cropData['pestRisk']),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _RiskIndicator(
                  label: 'Disease Risk',
                  level: _cropData['diseaseRisk'],
                  color: _getRiskColor(_cropData['diseaseRisk']),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _RiskIndicator(
                  label: 'Nutrient Status',
                  level: _cropData['nutrientStatus'],
                  color: _getNutrientColor(_cropData['nutrientStatus']),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
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
              Icon(Icons.notifications, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Alerts & Recommendations',
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
            children: _alerts.map((alert) => _AlertCard(alert: alert)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator(double health) {
    Color color = health > 0.7
        ? Colors.green
        : health > 0.4
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${(health * 100).toInt()}% Health',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNDVIGauge() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: _cropData['ndviIndex'],
                strokeWidth: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                    _getNDVIColor(_cropData['ndviIndex'])),
              ),
            ),
            Column(
              children: [
                Text(
                  'NDVI',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _cropData['ndviIndex'].toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getNDVIColor(_cropData['ndviIndex']),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Vegetation Index',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getNDVIColor(double value) {
    if (value > 0.6) return Colors.green;
    if (value > 0.4) return Colors.orange;
    return Colors.red;
  }

  Color _getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getNutrientColor(String status) {
    switch (status.toLowerCase()) {
      case 'optimal':
        return Colors.green;
      case 'adequate':
        return Colors.blue;
      case 'deficient':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String date) {
    // Simple date formatting - TODO: Use proper date formatting
    return date.split('-').reversed.join('/');
  }

  void _refreshData() {
    // TODO: BACKEND - Refresh data from API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Refreshing crop data...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _OverviewItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HealthMetricCard extends StatelessWidget {
  final Map<String, dynamic> metric;

  const _HealthMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    Color color = metric['value'] > 0.7
        ? Colors.green
        : metric['value'] > 0.4
            ? Colors.orange
            : Colors.red;

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
              ),
              Icon(trendIcon, color: trendColor, size: 12),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${(metric['value'] * 100).toInt()}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: metric['value'],
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(2),
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

class _SatelliteDataRow extends StatelessWidget {
  final Map<String, dynamic> data;

  const _SatelliteDataRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              data['date'],
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              'NDVI: ${data['ndvi']}',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${(data['health'] * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _WeatherMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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

class _WeatherForecastCard extends StatelessWidget {
  final Map<String, dynamic> forecast;

  const _WeatherForecastCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            forecast['day'],
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Icon(forecast['icon'], color: Colors.blue, size: 20),
          const SizedBox(height: 4),
          Text(
            forecast['temp'],
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              fontSize: 12,
            ),
          ),
          Text(
            forecast['rain'],
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskIndicator extends StatelessWidget {
  final String label;
  final String level;
  final Color color;

  const _RiskIndicator({
    required this.label,
    required this.level,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            level,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    Color color = alert['type'] == 'warning'
        ? Colors.orange
        : alert['type'] == 'success'
            ? Colors.green
            : Colors.blue;

    IconData icon = alert['type'] == 'warning'
        ? Icons.warning_amber
        : alert['type'] == 'success'
            ? Icons.check_circle
            : Icons.info;

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
