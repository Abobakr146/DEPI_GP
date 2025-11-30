import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class RouteOptimizer {
  // Calculate distance between two points using Haversine formula
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // km

    final lat1Rad = point1.latitude * math.pi / 180;
    final lat2Rad = point2.latitude * math.pi / 180;
    final dLat = (point2.latitude - point1.latitude) * math.pi / 180;
    final dLon = (point2.longitude - point1.longitude) * math.pi / 180;

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // Calculate total distance of a route
  static double calculateTotalDistance(List<LatLng> route) {
    if (route.length < 2) return 0;

    double totalDistance = 0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += calculateDistance(route[i], route[i + 1]);
    }
    return totalDistance;
  }

  // Print route with distances - Debug function
  static void printRoute(List<LatLng> route, {String title = 'Route'}) {
    print('\n╔═══════════════════════════════════════════════════════════╗');
    print('║  $title');
    print('╠═══════════════════════════════════════════════════════════╣');

    if (route.isEmpty) {
      print('║  ⚠️  Empty route');
      print('╚═══════════════════════════════════════════════════════════╝\n');
      return;
    }

    double totalDistance = 0;

    for (int i = 0; i < route.length; i++) {
      final point = route[i];
      String label;
      String icon;

      if (i == 0) {
        label = 'START';
        icon = '🟢';
      } else if (i == route.length - 1) {
        label = 'END';
        icon = '🔴';
      } else {
        label = 'WAYPOINT ${i}';
        icon = '🟠';
      }

      print('║  $icon $label');
      print(
        '║     Coordinates: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
      );

      if (i < route.length - 1) {
        final distance = calculateDistance(point, route[i + 1]);
        totalDistance += distance;
        print('║     ↓ ${distance.toStringAsFixed(2)} km');
      }

      if (i < route.length - 1) {
        print('║');
      }
    }

    print('╠═══════════════════════════════════════════════════════════╣');
    print('║  📊 TOTAL DISTANCE: ${totalDistance.toStringAsFixed(2)} km');
    print('║  📍 TOTAL POINTS: ${route.length}');
    print('╚═══════════════════════════════════════════════════════════╝\n');
  }

  // Nearest Neighbor Algorithm - Optimizes route with waypoints
  static List<LatLng> optimizeRouteWithWaypoints({
    required LatLng start,
    required List<LatLng> waypoints,
    required LatLng end,
    bool printDebug = false,
  }) {
    if (waypoints.isEmpty) {
      final route = [start, end];
      if (printDebug) {
        printRoute(route, title: 'Optimized Route (No Waypoints)');
      }
      return route;
    }

    // Print original route before optimization
    if (printDebug) {
      final originalRoute = [start, ...waypoints, end];
      printRoute(originalRoute, title: 'Original Route (Before Optimization)');
    }

    final optimizedRoute = <LatLng>[start];
    final remainingPoints = List<LatLng>.from(waypoints);
    LatLng currentPoint = start;

    // Find nearest unvisited point
    while (remainingPoints.isNotEmpty) {
      double minDistance = double.infinity;
      int nearestIndex = 0;

      for (int i = 0; i < remainingPoints.length; i++) {
        final distance = calculateDistance(currentPoint, remainingPoints[i]);
        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = i;
        }
      }

      currentPoint = remainingPoints[nearestIndex];
      optimizedRoute.add(currentPoint);
      remainingPoints.removeAt(nearestIndex);
    }

    optimizedRoute.add(end);

    // Print optimized route
    if (printDebug) {
      printRoute(
        optimizedRoute,
        title: 'Optimized Route (After Nearest Neighbor)',
      );

      // Calculate savings
      final originalDistance = calculateTotalDistance([
        start,
        ...waypoints,
        end,
      ]);
      final optimizedDistance = calculateTotalDistance(optimizedRoute);
      final savings = originalDistance - optimizedDistance;
      final savingsPercent = (savings / originalDistance * 100);

      print('╔═══════════════════════════════════════════════════════════╗');
      print('║  💰 OPTIMIZATION SAVINGS');
      print('╠═══════════════════════════════════════════════════════════╣');
      print('║  Original Distance:  ${originalDistance.toStringAsFixed(2)} km');
      print(
        '║  Optimized Distance: ${optimizedDistance.toStringAsFixed(2)} km',
      );
      print('║  Distance Saved:     ${savings.toStringAsFixed(2)} km');
      print('║  Improvement:        ${savingsPercent.toStringAsFixed(1)}%');
      print('╚═══════════════════════════════════════════════════════════╝\n');
    }

    return optimizedRoute;
  }
}
