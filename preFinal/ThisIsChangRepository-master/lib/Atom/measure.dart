import 'dart:math';

double measure(double lat1, double lon1, double lat2, double lon2) {
  double R = 6378.137; // Radius of earth in KM
  double dLat = lat2 * pi / 180 - lat1 * pi / 180;
  double dLon = lon2 * pi / 180 - lon1 * pi / 180;
  double a = sin(dLat/2) * sin(dLat/2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
      sin(dLon/2) * sin(dLon/2);
  double c = 2 * atan2(sqrt(a), sqrt(1-a));
  double d = R * c;
  print(d * 1000);
  return d * 1000; // meters
}