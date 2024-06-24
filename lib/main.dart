import 'package:flutter/material.dart';
import 'package:rae_vpn/home_screen.dart';
import 'package:rae_vpn/v2ray_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await V2RayService().initializeV2Ray();
  runApp(const RaeVpnApp());
}

class RaeVpnApp extends StatelessWidget {
  const RaeVpnApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rae VPN',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF05363F),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomeScreen(),
    );
  }
}