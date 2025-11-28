import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:route_optim/trips.dart';

class FavoriteTripsPage extends StatefulWidget {
  const FavoriteTripsPage({super.key});

  @override
  State<FavoriteTripsPage> createState() => _FavoriteTripsPageState();
}

class _FavoriteTripsPageState extends State<FavoriteTripsPage> {
  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  List<Widget> _buildWaypoints(List<String> waypoints) {
    List<Widget> waypointWidgets = [];
    if (waypoints.isNotEmpty) {
      waypointWidgets.add(
        Row(
          children: [
            const Icon(Icons.circle, color: Colors.green, size: 12),
            const SizedBox(width: 8),
            Text(waypoints.first),
          ],
        ),
      );

      if (waypoints.length > 2) {
        waypointWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 4, bottom: 4),
            child: Text(
              '·\n·\n·',
              style: TextStyle(color: Colors.grey[400], height: 0.5, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        waypointWidgets.add(const SizedBox(height: 8));
      }

      if (waypoints.length > 1) {
        waypointWidgets.add(
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.red, size: 12),
              const SizedBox(width: 8),
              Text(waypoints.last),
            ],
          ),
        );
      }
    }
    return waypointWidgets;
  }

  final favoriteTrips = <Trip>[
    Trip(
        tripName: 'Downtown to Airport',
        timestamp: DateTime(2024, 11, 25),
        distance: 24.5,
        fuelUsed: 2.1,
        cost: 3.85,
        fuelSaved: 0.3,
        moneySaved: 1.50,
        vehicleId: 1,
        isFavorite: true,
        wayPoints: ['Downtown Plaza', 'International Airport']),
    Trip(
        tripName: 'Weekend Roadtrip',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        distance: 120.0,
        fuelUsed: 9.5,
        cost: 45.0,
        fuelSaved: 2.0,
        moneySaved: 10.0,
        vehicleId: 1,
        isFavorite: true,
        wayPoints: ['City A', 'Scenic Viewpoint', 'City B']),
  ].obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Trips'),
      ),
      body: Obx(
            () => ListView.separated(
          padding: const EdgeInsets.all(8.0),
          itemCount: favoriteTrips.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final trip = favoriteTrips[index];
            final isFav = trip.isFavorite.obs;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              elevation: 0.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_car, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(trip.tripName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Obx(() => Icon(isFav.value ? Icons.star : Icons.star_border, color: Colors.amber, size: 20)),
                            onPressed: () {
                              isFav.value = !trip.isFavorite;
                              trip.isFavorite = isFav.value;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          '${_getMonthAbbreviation(trip.timestamp.month)} ${trip.timestamp.day}, ${trip.timestamp.year}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._buildWaypoints(trip.wayPoints),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn('Distance', '${trip.distance} km'),
                        _buildStatColumn('Fuel', '${trip.fuelUsed} L'),
                        _buildStatColumn('Cost', '\$${trip.cost.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}