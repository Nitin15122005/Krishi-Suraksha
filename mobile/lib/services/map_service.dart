// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print

import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  // Check location permissions
  static Future<bool> checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        print('Location permission denied');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get address from coordinates
  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Build address string
        List<String> addressParts = [];
        if (place.street != null && place.street!.isNotEmpty)
          addressParts.add(place.street!);
        if (place.locality != null && place.locality!.isNotEmpty)
          addressParts.add(place.locality!);
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty)
          addressParts.add(place.administrativeArea!);
        if (place.country != null && place.country!.isNotEmpty)
          addressParts.add(place.country!);

        return addressParts.join(', ');
      }
      return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
    } catch (e) {
      print('Error getting address: $e');
      return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
    }
  }

  // Get coordinates from address
  static Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  // Calculate polygon area in acres using spherical law of cosines
  static Future<double> calculatePolygonArea(List<LatLng> points) async {
    if (points.length < 3) return 0.0;

    // Close the polygon if not closed
    List<LatLng> polygonPoints = List.from(points);
    if (polygonPoints.first != polygonPoints.last) {
      polygonPoints.add(polygonPoints.first);
    }

    double area = 0.0;
    const double earthRadius = 6371000.0; // meters

    for (int i = 0; i < polygonPoints.length - 1; i++) {
      LatLng p1 = polygonPoints[i];
      LatLng p2 = polygonPoints[i + 1];

      double lat1 = p1.latitude * math.pi / 180;
      double lon1 = p1.longitude * math.pi / 180;
      double lat2 = p2.latitude * math.pi / 180;
      double lon2 = p2.longitude * math.pi / 180;

      area += (lon2 - lon1) * (2 + math.sin(lat1) + math.sin(lat2));
    }

    area = area * earthRadius * earthRadius / 2.0;
    area = area.abs();

    // Convert from square meters to acres (1 acre = 4046.86 square meters)
    double areaInAcres = area / 4046.86;
    return areaInAcres;
  }

  // Calculate centroid of polygon
  static LatLng calculateCentroid(List<LatLng> points) {
    double sumLat = 0.0;
    double sumLng = 0.0;

    for (final point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }

    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  // Check if point is inside polygon
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool c = false;
    int n = polygon.length;
    int j = n - 1;

    for (int i = 0; i < n; j = i++) {
      if (((polygon[i].latitude > point.latitude) !=
              (polygon[j].latitude > point.latitude)) &&
          (point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        c = !c;
      }
    }

    return c;
  }
}
