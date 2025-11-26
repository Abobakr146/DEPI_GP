class Trip{
  final double fuelSaved;
  final double fuelUsed;
  final double distance;
  final double moneySaved;
  final double cost;
  final DateTime timestamp;
  final String tripName;
  final int vehicleId;
  final bool isFavorite;

  const Trip({
    required this.vehicleId,
    required this.isFavorite,
    required this.timestamp,
    required this.tripName,
    required this.fuelSaved,
    required this.fuelUsed,
    required this.distance,
    required this.moneySaved,
    required this.cost
  });
}