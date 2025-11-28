class Trip{
  final double fuelSaved;
  final double fuelUsed;
  final double distance;
  final double moneySaved;
  final double cost;
  final DateTime timestamp;
  final String tripName;
  final int vehicleId;
  bool isFavorite;
  final List<String> wayPoints;

  Trip({
    required this.vehicleId,
    this.isFavorite = false,
    required this.timestamp,
    required this.tripName,
    required this.fuelSaved,
    required this.fuelUsed,
    required this.distance,
    required this.moneySaved,
    required this.cost,
    required this.wayPoints
  });
}