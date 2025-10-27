// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/map_service.dart';

class WeatherUpdatesMap extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng)? onLocationSelected;

  const WeatherUpdatesMap({
    super.key,
    this.initialLocation,
    this.onLocationSelected,
  });

  @override
  State<WeatherUpdatesMap> createState() => _WeatherUpdatesMapState();
}

class _WeatherUpdatesMapState extends State<WeatherUpdatesMap> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _address = 'Select location for weather updates';
  bool _isLoading = true;
  bool _mapCreated = false;
  MapType _currentMapType = MapType.normal;

  final Set<Marker> _markers = {};
  final LatLng _defaultLocation =
      const LatLng(20.5937, 78.9629); // India center

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
      _updateMarker();
      await _getAddressFromLocation();
    } else {
      await _goToCurrentLocation();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _goToCurrentLocation() async {
    try {
      Position? position = await MapService.getCurrentLocation();
      if (position != null) {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _updateMarker();

        if (_mapCreated && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_selectedLocation!, 12),
          );
        }
        await _getAddressFromLocation();
      } else {
        _selectedLocation = _defaultLocation;
        _updateMarker();
        await _getAddressFromLocation();
      }
    } catch (e) {
      print('Error getting current location: $e');
      _selectedLocation = _defaultLocation;
      _updateMarker();
      await _getAddressFromLocation();
    }
  }

  void _updateMarker() {
    if (_selectedLocation == null) return;

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('weather_location'),
        position: _selectedLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Weather Location',
          snippet: _address,
        ),
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _selectedLocation = newPosition;
          });
          _getAddressFromLocation();
        },
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getAddressFromLocation() async {
    if (_selectedLocation == null) return;

    try {
      String address = await MapService.getAddressFromLatLng(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );
      if (mounted) {
        setState(() => _address = address);
        _updateMarker();
      }
    } catch (e) {
      print('Error getting address: $e');
      if (mounted) {
        setState(() => _address = 'Unable to get address');
      }
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _updateMarker();
    _getAddressFromLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapCreated = true;

    if (_selectedLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 12),
      );
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      if (widget.onLocationSelected != null) {
        widget.onLocationSelected!(_selectedLocation!);
      }
      Navigator.pop(context, {
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'address': _address,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildMapTypeToggle() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: _toggleMapType,
          icon: Icon(
            _currentMapType == MapType.normal ? Icons.satellite : Icons.map,
            color: Colors.blue[800],
          ),
          tooltip: _currentMapType == MapType.normal
              ? 'Switch to Satellite View'
              : 'Switch to Normal View',
        ),
      ),
    );
  }

  Widget _buildMapInstructions() {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Colors.blue,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _currentMapType == MapType.normal
                    ? 'Tap on map to select location for weather updates'
                    : 'Drag the marker to adjust location precisely',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Select Weather Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[800]),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: Colors.blue[800]),
            onPressed: _goToCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Address Display
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Map
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.blue),
                            SizedBox(height: 16),
                            Text(
                              'Loading weather map...',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation ?? _defaultLocation,
                          zoom: _selectedLocation != null ? 12 : 5,
                        ),
                        markers: _markers,
                        onTap: _onMapTap,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: true,
                        mapToolbarEnabled: false,
                        mapType: _currentMapType,
                      ),
              ),

              // Instructions and Button
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Select location for accurate weather forecasts',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirmSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Confirm Weather Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Overlay controls
          _buildMapTypeToggle(),
          _buildMapInstructions(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
