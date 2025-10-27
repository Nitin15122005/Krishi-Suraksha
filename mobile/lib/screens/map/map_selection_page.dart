// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/map_service.dart';

class MapSelectionPage extends StatefulWidget {
  final LatLng? initialLocation;
  final bool isFarmLocation;
  final List<LatLng>? initialPolygon;

  const MapSelectionPage({
    super.key,
    this.initialLocation,
    this.isFarmLocation = false,
    this.initialPolygon,
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
  bool _isDrawingPolygon = false;
  List<LatLng> _polygonPoints = [];
  double _calculatedArea = 0.0;
  MapType _currentMapType = MapType.normal;

  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};
  final LatLng _defaultLocation =
      const LatLng(20.5937, 78.9629); // India center

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    if (widget.initialPolygon != null && widget.initialPolygon!.isNotEmpty) {
      _polygonPoints = List.from(widget.initialPolygon!);
      _updatePolygon();
      await _calculateArea();
      // Center map on the polygon
      if (_polygonPoints.isNotEmpty) {
        _selectedLocation = _polygonPoints.first;
        await _getAddressFromLocation();
      }
    } else if (widget.initialLocation != null) {
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
            CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
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

  void _updatePolygon() {
    _polygons.clear();
    if (_polygonPoints.length > 2) {
      _polygons.add(
        Polygon(
          polygonId: const PolygonId('farm_boundary'),
          points: _polygonPoints,
          strokeWidth: 3,
          strokeColor: Colors.green,
          fillColor: Colors.green.withOpacity(0.15),
        ),
      );
    }

    // Update markers for polygon points
    _markers.clear();
    for (int i = 0; i < _polygonPoints.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('polygon_point_$i'),
          position: _polygonPoints[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Point ${i + 1}'),
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _polygonPoints[i] = newPosition;
              _updatePolygon();
              _calculateArea();
            });
          },
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _calculateArea() async {
    if (_polygonPoints.length < 3) {
      setState(() => _calculatedArea = 0.0);
      return;
    }

    try {
      double area = await MapService.calculatePolygonArea(_polygonPoints);
      setState(() => _calculatedArea = area);
    } catch (e) {
      print('Error calculating area: $e');
      setState(() => _calculatedArea = 0.0);
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
    if (!widget.isFarmLocation) {
      // Single point selection mode
      setState(() {
        _selectedLocation = location;
      });
      _updateMarker();
      _getAddressFromLocation();
    } else if (_isDrawingPolygon) {
      // Polygon drawing mode
      setState(() {
        _polygonPoints.add(location);
      });
      _updatePolygon();
      _calculateArea();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapCreated = true;

    if (_selectedLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
      );
    } else if (_polygonPoints.isNotEmpty) {
      // Fit camera to show entire polygon
      _fitCameraToPolygon();
    }
  }

  void _fitCameraToPolygon() {
    if (_polygonPoints.isEmpty || _mapController == null) return;

    final bounds = _getBounds(_polygonPoints);
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (final point in points) {
      minLat = minLat == null
          ? point.latitude
          : (point.latitude < minLat ? point.latitude : minLat);
      maxLat = maxLat == null
          ? point.latitude
          : (point.latitude > maxLat ? point.latitude : maxLat);
      minLng = minLng == null
          ? point.longitude
          : (point.longitude < minLng ? point.longitude : minLng);
      maxLng = maxLng == null
          ? point.longitude
          : (point.longitude > maxLng ? point.longitude : maxLng);
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  void _startDrawing() {
    setState(() {
      _isDrawingPolygon = true;
      _polygonPoints.clear();
      _calculatedArea = 0.0;
      _updatePolygon();
    });
  }

  void _undoLastPoint() {
    if (_polygonPoints.isNotEmpty) {
      setState(() {
        _polygonPoints.removeLast();
        _updatePolygon();
        _calculateArea();
      });
    }
  }

  void _clearPolygon() {
    setState(() {
      _polygonPoints.clear();
      _calculatedArea = 0.0;
      _updatePolygon();
    });
  }

  void _finishDrawing() {
    if (_polygonPoints.length >= 3) {
      setState(() {
        _isDrawingPolygon = false;
      });
      // Auto-close the polygon if not already closed
      if (_polygonPoints.first != _polygonPoints.last) {
        _polygonPoints.add(_polygonPoints.first);
        _updatePolygon();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('At least 3 points are required to create a polygon'),
          backgroundColor: Colors.orange,
        ),
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
    if (widget.isFarmLocation) {
      // Farm boundary selection
      if (_polygonPoints.length >= 3) {
        Navigator.pop(context, {
          'type': 'polygon',
          'boundary': _polygonPoints
              .map((point) => {
                    'latitude': point.latitude,
                    'longitude': point.longitude,
                  })
              .toList(),
          'area': _calculatedArea,
          'center': {
            'latitude': _getCentroid(_polygonPoints).latitude,
            'longitude': _getCentroid(_polygonPoints).longitude,
          },
          'address': _address,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please draw your farm boundary first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // Single point selection
      if (_selectedLocation != null) {
        Navigator.pop(context, {
          'type': 'point',
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
  }

  LatLng _getCentroid(List<LatLng> points) {
    double sumLat = 0;
    double sumLng = 0;

    for (final point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }

    return LatLng(sumLat / points.length, sumLng / points.length);
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
            color: Colors.green[800],
          ),
          tooltip: _currentMapType == MapType.normal
              ? 'Switch to Satellite View'
              : 'Switch to Normal View',
        ),
      ),
    );
  }

  Widget _buildFarmControls() {
    if (!widget.isFarmLocation) return SizedBox();

    return Positioned(
      top: 16,
      left: 16,
      right: 80, // Leave space for map type toggle
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _currentMapType == MapType.normal
                      ? Icons.map
                      : Icons.satellite,
                  size: 16,
                  color: Colors.green[800],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Farm Boundary Selection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (_calculatedArea > 0)
              Text(
                'Calculated Area: ${_calculatedArea.toStringAsFixed(2)} acres',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            SizedBox(height: 8),
            Row(
              children: [
                if (!_isDrawingPolygon)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startDrawing,
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Draw Boundary'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _finishDrawing,
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Finish Drawing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                if (_isDrawingPolygon && _polygonPoints.isNotEmpty)
                  IconButton(
                    onPressed: _undoLastPoint,
                    icon: Icon(Icons.undo, color: Colors.orange),
                    tooltip: 'Undo last point',
                  ),
                if (_polygonPoints.isNotEmpty)
                  IconButton(
                    onPressed: _clearPolygon,
                    icon: Icon(Icons.clear, color: Colors.red),
                    tooltip: 'Clear all points',
                  ),
              ],
            ),
            if (_isDrawingPolygon)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tap on map to add points. Minimum 3 points required.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
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
                    ? 'Use satellite view to better identify farm boundaries'
                    : 'Switch to normal view for better road visibility',
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
          widget.isFarmLocation ? 'Select Farm Boundary' : 'Select Location',
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
          if (!widget.isFarmLocation)
            IconButton(
              icon: Icon(Icons.my_location, color: Colors.green[800]),
              onPressed: _goToCurrentLocation,
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Address Display
              if (!widget.isFarmLocation)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green, size: 20),
                      SizedBox(width: 8),
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
                            SizedBox(height: 2),
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
                            SizedBox(height: 16),
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
                        polygons: _polygons,
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
                      widget.isFarmLocation
                          ? 'Draw your farm boundary by tapping on the map'
                          : 'Tap on the map to select location',
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
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.isFarmLocation
                              ? 'Confirm Farm Boundary'
                              : 'Confirm Location',
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
          if (widget.isFarmLocation) _buildFarmControls(),
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
