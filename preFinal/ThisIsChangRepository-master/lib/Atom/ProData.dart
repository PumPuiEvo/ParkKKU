import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProData extends ChangeNotifier {
  Set<Marker> allMarker = {};

  Set<Marker> getMarker() => allMarker;

  void clear() {
    allMarker.clear();
    notifyListeners();
  }

  void setMarker(Set<Marker> marker) {
    allMarker = marker;
    print("AlllMarker = new");
    notifyListeners();
  }

  void test(double la, double long) {
    allMarker.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: const MarkerId("Your Pin Location"),
        position: LatLng(la, long), //Position on mark @ChangNoi
        infoWindow: const InfoWindow(
          title: "Your Pin Location", //title message on mark @ChangNoi
          snippet: 'message', //snippet message on mark @ChangNoi
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
  }

  void addMaker(Marker marker) {
    allMarker.add(marker);
    notifyListeners();
  }

  void addAllMaker(Set<Marker> marker) {
    allMarker.addAll(marker);
    notifyListeners();
  }
}
