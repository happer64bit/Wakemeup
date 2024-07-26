import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng _currentCenter = const LatLng(16.824709, 96.124771);
  late MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    setState(() {
      _currentCenter = camera.center;
    });
  }

  void _confirmLocation() {
    Navigator.pop(context, _currentCenter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
          child: Row(
            children: [
              const Text(
                "Pick Location",
                style: TextStyle(fontSize: 20),
              ),
              const Spacer(),
              TextButton(
                onPressed: _confirmLocation,
                child: const Text("CONFIRM"),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(16.824709, 96.124771),
              initialZoom: 11,
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'http://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.happer64bit.wakemeup',
              ),
            ],
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40),
                Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}