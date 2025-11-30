import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:route_optim/car_route_page.dart';
import 'package:route_optim/profile_page.dart';
import 'package:route_optim/trip_history_page.dart';
import 'package:route_optim/trip_service.dart';
import 'package:route_optim/trips.dart';

import 'login_page.dart';

final trips = <Trip>[
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
  Trip(
      tripName: 'Grocery Run',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      distance: 5.2,
      fuelUsed: 0.5,
      cost: 2.25,
      fuelSaved: 0.1,
      moneySaved: 0.5,
      vehicleId: 2,
      isFavorite: false,
      wayPoints: ['Home', 'Supermarket', 'Home']),
].obs;

final tripService = TripService();
final totalDistance = 0.0.obs;
final totalFuelSaved = 0.0.obs;
final totalMoneySaved = 0.0.obs;

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 // ......... load all trips from database .........

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTrips();
  }

  Future<void> loadTrips() async {
    await tripService.getTripsByID(user!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: SizedBox(
            width: 40,
            height: 40,
            child: Image.asset('assets/images/logo.png'),
          ),
          title: const Text(
            'RouteOptim',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          subtitle: Text('Welcome, ${user?.name.split(' ').first ?? 'Guest'}!'),
          trailing: IconButton(
            onPressed: () {
              Get.to(() => ProfilePage());
            },
            icon: const Icon(Icons.person),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              children: [
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  // color: const Color(0xFF0F2CE8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Text(
                          'Last Trip',
                          style: TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                            onPressed: (){
                              Get.to(() => const TripHistoryPage());
                            },
                            icon: const Icon(Icons.history)
                        )
                      ),
                      Obx(
                        () => trips.isNotEmpty
                            ? Text(
                                trips.last.tripName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Center(
                                child: Text(
                                  'No trips yet. Start your first trip!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => trips.isNotEmpty
                            ?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'Distance',
                                    style: TextStyle(
                                    ),
                                  ),
                                  Text(
                                    '${trips.last.distance} km',
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'Fuel Saved',
                                    style: TextStyle(
                                    ),
                                  ),
                                  Text(
                                    '${trips.last.fuelSaved} L',
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'Money Saved',
                                  ),
                                  Text(
                                    '\$${trips.last.moneySaved}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Travel Mode',
                  style: TextStyle(fontSize: 16),
                ),
                Card(
                  child: Center(
                    child: ListTile(
                      leading: const Icon(
                        Icons.directions_car,
                        color: Colors.blue,
                      ),
                      title: const Text(
                        'Car Route',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Optimize Fuel Consumption'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Get.to(() => const CarRoutePage());
                      },
                    ),
                  ),
                ),
                Card(
                  child: Center(
                    child: ListTile(
                      leading: const Icon(
                        Icons.directions_transit,
                        color: Colors.green,
                      ),
                      title: const Text(
                        'Metro Route',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Fastest Metro Routes'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // ......... navigate to car trip planning page .........
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Stats',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    buildStatCard('Total Trips'),
                    buildStatCard('Fuel Saved'),
                    buildStatCard('Distance Travelled'),
                    buildStatCard('Money Saved'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatCard(String stat) {
    return Card(
      shadowColor: Colors.grey,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(stat),
            Text(
              stat == 'Total Trips'
                  ? '${trips.length}'
                  : stat == 'Fuel Saved'
                  ? '${totalFuelSaved.value} L'
                  : stat == 'Distance Travelled'
                  ? '${totalDistance.value} km'
                  : stat == 'Money Saved'
                  ? '\$${totalMoneySaved.value}'
                  : '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
