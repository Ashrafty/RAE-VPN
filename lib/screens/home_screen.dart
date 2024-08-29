import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:rae_vpn/widgets/import_button.dart';
import 'package:rae_vpn/widgets/vpn_button.dart';
import 'package:rae_vpn/services/v2ray_service.dart';
import 'package:rae_vpn/screens/logs_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final V2RayService _v2rayService = V2RayService();
  bool _isConnected = false;
  String _vpnDuration = "00:00:00";

  @override
  void initState() {
    super.initState();
    _v2rayService.addListener(_updateState);
  }

  @override
  void dispose() {
    _v2rayService.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {
      _isConnected = _v2rayService.isConnected;
      _vpnDuration = _v2rayService.durationString;
    });
  }

  Future<void> _toggleConnection() async {
    if (_isConnected) {
      await _v2rayService.stopV2Ray();
    } else {
      String? config = await _v2rayService.getSavedConfig();
      if (config != null) {
        await _v2rayService.startV2Ray(config);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please import a configuration first')),
        );
      }
    }
  }

  Future<void> _importConfig() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String config = await file.readAsString();
      await _v2rayService.saveConfig(config);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration imported successfully')),
      );
    }
  }

  Future<void> _importUrl() async {
    String? url = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String inputUrl = '';
        return AlertDialog(
          title: const Text('Import from URL'),
          content: TextField(
            onChanged: (value) {
              inputUrl = value;
            },
            decoration: const InputDecoration(hintText: "Enter V2Ray URL"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Import'),
              onPressed: () {
                Navigator.of(context).pop(inputUrl);
              },
            ),
          ],
        );
      },
    );

    if (url != null && url.isNotEmpty) {
      try {
        V2RayURL parser = FlutterV2ray.parseFromURL(url);
        String config = parser.getFullConfiguration();
        await _v2rayService.saveConfig(config);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration imported successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid V2Ray URL: $e')),
        );
      }
    }
  }

  void _navigateToLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ImportButton(title: 'Import Config', onPressed: _importConfig),
                ImportButton(title: 'Import URL', onPressed: _importUrl),
              ],
            ),
            Expanded(
              child: Center(
                child: VpnButton(
                  isConnected: _isConnected,
                  onPressed: _toggleConnection,
                ),
              ),
            ),
            Text(
              _isConnected ? 'Connected' : 'Disconnected',
              style: TextStyle(
                color: _isConnected ? const Color(0xFF17692D) : const Color(0xFFB22438),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isConnected) ...[
              const SizedBox(height: 10),
              Text(
                'VPN Duration: $_vpnDuration',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToLogs,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF05363F),
                minimumSize: const Size(180, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Logs',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}