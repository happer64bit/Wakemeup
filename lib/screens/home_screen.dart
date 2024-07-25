import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isConfirmed = false;
  String? selectedGeoLocation;
  int selectedMeter = 500;
  MapController mapController = MapController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<void> _locationInitialization;
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();

    bottomSheetModalAnimationController = AnimationController(vsync: this);
    audioPlayer = AudioPlayer();
    _requestLocationPermission();
    _locationInitialization = _initializeLocation();
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

  Future<void> _initializeLocation() async {
    final SharedPreferences prefs = await _prefs;
    
    setState(() {
      isConfirmed = prefs.getBool("isActive") ?? false;
    });

    Location location = Location();
    LocationData currentLocationData = await location.getLocation();
    setState(() {
      currentLocation = LatLng(currentLocationData.latitude!, currentLocationData.longitude!);
    });

    location.onLocationChanged.listen((LocationData current) {
      final latitude = current.latitude;
      final longitude = current.longitude;

      if (latitude != null && longitude != null) {
        setState(() {
          currentLocation = LatLng(latitude, longitude);
        });
        _checkIfUserInRange();
      }
    });
  }

  void _checkIfUserInRange() async {
    if (selectedLocation != null && currentLocation != null) {
      final distance = const Distance().as(
        LengthUnit.Meter,
        currentLocation!,
        selectedLocation!,
      );
      if (distance <= selectedMeter) {
        // Play alarm sound
        await audioPlayer.setAsset('assets/audio/digital-alarm-2-151919.mp3');
        await audioPlayer.play();
      }
    }
  }

  @override
  void dispose() {
    bottomSheetModalAnimationController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  void onSetAlarmButtonPressed(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: true,
      useRootNavigator: true,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return BottomSheet(
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
                        setModalState(() {
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
                  const SizedBox(height: 20),
                  DropdownButton<int>(
                    isExpanded: true,
                    value: selectedMeter,
                    onChanged: (newValue) {
                      setModalState(() {
                        selectedMeter = newValue!;
                      });
                    },
                    items: const <Map<String, dynamic>>[
                      {"label": "50 Meters", "value": 50},
                      {"label": "100 Meters", "value": 100},
                      {"label": "250 Meters", "value": 250},
                      {"label": "500 Meters", "value": 500},
                      {"label": "1000 Meters", "value": 1000},
                      {"label": "1 Mile", "value": 1609},   // 1 mile in meters
                      {"label": "2 Miles", "value": 3218},  // 2 miles in meters
                      {"label": "3 Miles", "value": 4827},  // 3 miles in meters
                      {"label": "4 Miles", "value": 6436},  // 4 miles in meters
                      {"label": "5 Miles", "value": 8045},  // 5 miles in meters
                    ].map<DropdownMenuItem<int>>((Map<String, dynamic> item) {
                      return DropdownMenuItem<int>(
                        value: item['value'] as int,
                        child: Text(item['label'] as String),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () async {
                      final SharedPreferences prefs = await _prefs;

                      await prefs.setDouble("lat", selectedLocation!.latitude);
                      await prefs.setDouble("long", selectedLocation!.longitude);
                      await prefs.setBool("isActive", true);

                      AudioPlayer player = AudioPlayer();

                      await player.setAsset(
                        "assets/audio/short-success-sound-glockenspiel-treasure-video-game-6346.mp3"
                      );
                      player.play();
                      context.pop();
                      setState(() {
                        isConfirmed = true;
                      });
                    },
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
                          "Set Alarm",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _locationInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
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
                    "Set Alarm",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          body: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation ?? const LatLng(16.824709, 96.124771),
              initialZoom: 11,
            ),
            children: [
              TileLayer(
                urlTemplate: 'http://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.happer64bit.wakemeup',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              if (currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 18,
                      height: 18,
                      point: currentLocation!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(40)
                        ),
                        width: 18,
                        height: 18,
                      )
                    ),
                  ],
                ),
              if (selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 22,
                      height: 22,
                      point: selectedLocation!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              if (isConfirmed && selectedLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: selectedLocation!,
                      radius: selectedMeter.toDouble(),
                      useRadiusInMeter: true,
                      color: Colors.pink.withOpacity(0.2),
                      borderColor: Colors.white,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
