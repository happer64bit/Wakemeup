import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakemeup/widget/location_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController bottomSheetModalAnimationController;
  late LatLng selectedLocation;

  @override
  void initState() {
    super.initState();

    bottomSheetModalAnimationController = AnimationController(
      vsync: this
    );
  }

  // PREVENT MEMORY LEAKS
  @override
  void dispose() {
    bottomSheetModalAnimationController.dispose();
    super.dispose();
  }


  void onSetAlarmButtonPressed(BuildContext context) {
    print('Set Alarm button pressed');
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
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Pick Location For Alarm",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              InkWell(
                onTap: () {
                  print('Pick Location tapped');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        // bottomSheet: ,
                        body: LocationPicker(
                          onPositionChanged: (p0) {
                            print('Position changed: $p0');
                            setState(() {
                              selectedLocation = p0;
                            });
                          },
                        )
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
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
                  child: const Row(
                    children: [
                      Text("Pick Location"),
                      Spacer(),
                      Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  print('Set Alarm tapped');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        body: LocationPicker(
                          onPositionChanged: (p0) {
                            print('Position changed: $p0');
                            setState(() {
                              selectedLocation = p0;
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
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
                      style: TextStyle(
                        color: Colors.white,
                      ),
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
            padding: const EdgeInsets.symmetric(
              vertical: 10
            ),
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
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            )
          ),
        ),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(16.824709, 96.124771),
          initialZoom: 11
        ),
        children: [
          TileLayer(
            urlTemplate: 'http://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
            userAgentPackageName: 'com.happer64bit.wakemeup',
          )
        ],
      )
    );
  }
}