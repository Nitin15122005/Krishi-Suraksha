// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/map_service.dart';

class MapSelectionPage extends StatefulWidget {
  final LatLng? initialLocation;
  final bool isFarmLocation;

  const MapSelectionPage({
    super.key,
    this.initialLocation,
    this.isFarmLocation = false,
  });

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _address = 'Select a location';
  bool _isLoading = true;
  bool _mapCreated = false;

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

        // Only animate camera if map controller is ready
        if (_mapCreated && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
          );
        }
        await _getAddressFromLocation();
      } else {
        // Fallback to default location
        _selectedLocation = _defaultLocation;
        _updateMarker();
        await _getAddressFromLocation();
      }
    } catch (e) {
      print('Error getting current location: $e');
      // Fallback to default location
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
        markerId: const MarkerId('selected_location'),
        position: _selectedLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: _address),
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
        _updateMarker(); // Update marker with new address
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

    // If we have a selected location but map wasn't ready, animate to it now
    if (_selectedLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
      );
    }
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isFarmLocation ? 'Select Farm Location' : 'Select Location',
          style: TextStyle(
            fontSize: 18,
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
            icon: Icon(Icons.my_location, color: Colors.green[800]),
            onPressed: _goToCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Address Display
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
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
                        CircularProgressIndicator(color: Colors.green),
                        const SizedBox(height: 16),
                        Text(
                          'Loading map...',
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
                      zoom: _selectedLocation != null ? 15 : 5,
                    ),
                    markers: _markers,
                    onTap: _onMapTap,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: true,
                    mapToolbarEnabled: false,
                  ),
          ),

          // Instructions and Button
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Tap on the map to select location',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _selectedLocation != null ? _confirmSelection : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm Location',
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
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
