import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:wakemeup/widget/location_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController bottomSheetModalAnimationController;
  LatLng? selectedLocation;
  LatLng? currentLocation;
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();

    bottomSheetModalAnimationController = AnimationController(vsync: this);
    _requestLocationPermission().then((value) => print("SUCCESS"));

    Location location = Location();
    location.onLocationChanged.listen((LocationData current) {
      final latitude = current.latitude;
      final longitude = current.longitude;

      if (latitude != null && longitude != null) {
        setState(() {
          currentLocation = LatLng(latitude, longitude);
        });
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  void dispose() {
    bottomSheetModalAnimationController.dispose();
    super.dispose();
  }

  void onSetAlarmButtonPressed(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (context) => BottomSheet(
        animationController: bottomSheetModalAnimationController,
        onClosing: () {},
        builder: (context) => Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Pick Location For Alarm",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 40),
              InkWell(
                onTap: () async {
                  final pickedLocation = await Navigator.push<LatLng>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationPicker(),
                    ),
                  );

                  if (pickedLocation != null) {
                    setState(() {
                      selectedLocation = pickedLocation;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      width: 1,
                      color: Colors.black.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x00000000).withOpacity(0.2),
                        offset: const Offset(1, 1),
                        blurRadius: 22,
                        spreadRadius: -10,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        selectedLocation != null
                          ? "${selectedLocation!.latitude}, ${selectedLocation!.longitude}"
                          : "Pick Location"
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x00000000).withOpacity(1),
                        offset: const Offset(8, 5),
                        blurRadius: 22,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Set Alarm ⏰",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        height: 70,
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          onTap: () => onSetAlarmButtonPressed(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.blue.shade700.withOpacity(0.95),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x00000000).withOpacity(1),
                  offset: const Offset(8, 5),
                  blurRadius: 22,
                  spreadRadius: -10,
                )
              ]
            ),
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                "Set Alarm ⏰",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: const MapOptions(
          initialCenter: LatLng(16.824709, 96.124771),
          initialZoom: 11
        ),
        children: [
          TileLayer(
            urlTemplate: 'http://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
            userAgentPackageName: 'com.happer64bit.wakemeup',
          ),
          CurrentLocationLayer(
            alignPositionOnUpdate: AlignOnUpdate.always,
            alignDirectionOnUpdate: AlignOnUpdate.never,
            style: const LocationMarkerStyle(
              marker: DefaultLocationMarker(),
              markerSize: Size(25, 25),
              markerDirection: MarkerDirection.heading,
            ),
          ),
          if (selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: selectedLocation!,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              ],
            ),
          ],
      ),
    );
  }
}
