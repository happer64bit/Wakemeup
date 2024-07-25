import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wakemeup/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter router = GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) => SafeArea(
          child: child,
        ),
        routes: [
          GoRoute(
            path: "/",
            builder: (context, state) => const HomeScreen()
          ),
        ]
      ),
    ]
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.black.withOpacity(0)
        ),
      ),
      routerConfig: router,
    );
  }
}
