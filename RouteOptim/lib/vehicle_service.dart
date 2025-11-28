import 'dart:convert';

import 'package:get/get.dart';
import 'package:route_optim/vehicle.dart';
import 'main.dart';

class VehicleService extends GetxService {
  Future<List<Vehicle>> loadAllVehicles() async {
    print('Loading all vehicles from database...');
    var response = await cloud.from('Vehicle').select('manufacture, fuel_type, consumption');
    final vehicles = vehicleFromJson(json.encode(response));
    return vehicles;
  }
}
