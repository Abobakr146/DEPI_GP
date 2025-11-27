import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'geocoding_response.dart';
import 'routing_response.dart';

const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiaGlzaGFtaGF0ZW0iLCJhIjoiY21pYm82ZzJqMHVvbTJsczQwZnBwd20zOSJ9.S39J9fY023DATGzHegv1GA';

class MapService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status! < 500,
    ),
  );

  final CancelToken _cancelToken = CancelToken();

  void cancel() {
    _cancelToken.cancel();
  }

  void dispose() {
    _dio.close();
  }

  // Search location using Mapbox Geocoding API
  Future<GeocodingResponse?> searchLocation(String query) async {
    if (query.length < 2) return null;

    try {
      final response = await _dio.get(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json',
        queryParameters: {
          'access_token': MAPBOX_ACCESS_TOKEN,
          'limit': 5,
          'autocomplete': true,
        },
        cancelToken: _cancelToken,
      );

      if (response.statusCode == 200) {
        final geocodingResp = geocodingResponseFromJson(
          json.encode(response.data),
        );
        return geocodingResp;
      }
      return null;
    } on DioException catch (e) {
      print('Dio error searching location: ${e.message}');
      return null;
    } catch (e) {
      print('Error searching location: $e');
      return null;
    }
  }

  // Reverse geocode (get address from coordinates)
  Future<GeocodingResponse?> reverseGeocode(LatLng position) async {
    try {
      final response = await _dio.get(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${position.longitude},${position.latitude}.json',
        queryParameters: {'access_token': MAPBOX_ACCESS_TOKEN, 'limit': 1},
        cancelToken: _cancelToken,
      );

      if (response.statusCode == 200) {
        final geocodingResp = geocodingResponseFromJson(
          json.encode(response.data),
        );
        return geocodingResp;
      }
      return null;
    } on DioException catch (e) {
      print('Dio error reverse geocoding: ${e.message}');
      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  // Calculate route with waypoints using OSRM
  Future<RoutingResponse?> calculateRoute(List<LatLng> coordinates) async {
    if (coordinates.length < 2) return null;

    try {
      final coordStrings = coordinates
          .map((coord) => '${coord.longitude},${coord.latitude}')
          .toList();
      final coordString = coordStrings.join(';');

      final response = await _dio.get(
        'https://router.project-osrm.org/route/v1/driving/$coordString',
        queryParameters: {'overview': 'full', 'geometries': 'geojson'},
        cancelToken: _cancelToken,
      );

      if (response.statusCode == 200) {
        final routingResp = routingResponseFromJson(json.encode(response.data));
        return routingResp;
      }
      return null;
    } on DioException catch (e) {
      print('Dio error calculating route: ${e.message}');
      return null;
    } catch (e) {
      print('Error calculating route: $e');
      return null;
    }
  }
}
