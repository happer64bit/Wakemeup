import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPicker extends StatefulWidget {
  final Function(LatLng)? onPositionChanged;  // Add a callback property

  const LocationPicker({super.key, this.onPositionChanged});

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

    // Invoke the callback if it's provided
    if (widget.onPositionChanged != null) {
      widget.onPositionChanged!(_currentCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
              SizedBox(height: 40), // Adjust the height based on your icon size
            ],
          ),
        ),
      ],
    );
  }
}
