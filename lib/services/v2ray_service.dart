import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class V2RayService extends ChangeNotifier {
  static final V2RayService _instance = V2RayService._internal();
  factory V2RayService() => _instance;
  V2RayService._internal();

  late FlutterV2ray _flutterV2ray;
  bool _isConnected = false;
  String _currentConfig = '';
  Timer? _durationTimer;
  int _durationInSeconds = 0;
  List<String> _logs = [];
  final _logsController = StreamController<List<String>>.broadcast();

  bool get isConnected => _isConnected;

  Stream<List<String>> get logsStream => _logsController.stream;

  String get durationString {
    int hours = _durationInSeconds ~/ 3600;
    int minutes = (_durationInSeconds % 3600) ~/ 60;
    int seconds = _durationInSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> initializeV2Ray() async {
    _addLog('Initializing V2Ray...');
    _flutterV2ray = FlutterV2ray(
      onStatusChanged: (status) {
        var statusString = status.toString().split('.').last;
        var FlutterV2rayStatus;
        _isConnected = status == FlutterV2rayStatus.started;
        _addLog('V2Ray status changed: $statusString');
        notifyListeners();
      },
    );
    await _flutterV2ray.initializeV2Ray();
    _addLog('V2Ray initialized');
  }

  Future<bool> requestPermission() async {
    _addLog('Requesting VPN permission...');
    bool permission = await _flutterV2ray.requestPermission();
    _addLog('VPN permission ${permission ? 'granted' : 'denied'}');
    return permission;
  }

  Future<void> startV2Ray(String config) async {
    _addLog('Attempting to start V2Ray...');
    if (await requestPermission()) {
      try {
        await _flutterV2ray.startV2Ray(
          remark: 'Rae VPN',
          config: config,
          blockedApps: null,
          bypassSubnets: _getBypassSubnets(),
          proxyOnly: false,
        );
        _isConnected = true;
        _currentConfig = config;
        _startDurationTimer();
        _addLog('V2Ray started successfully');
      } catch (e) {
        _addLog('Error starting V2Ray: $e');
      }
    } else {
      _addLog('Failed to start V2Ray: Permission denied');
    }
    notifyListeners();
  }

  Future<void> stopV2Ray() async {
    _addLog('Stopping V2Ray...');
    try {
      await _flutterV2ray.stopV2Ray();
      _isConnected = false;
      _stopDurationTimer();
      _addLog('V2Ray stopped successfully');
    } catch (e) {
      _addLog('Error stopping V2Ray: $e');
    }
    notifyListeners();
  }

  Future<String?> getSavedConfig() async {
    _addLog('Retrieving saved configuration...');
    final prefs = await SharedPreferences.getInstance();
    String? config = prefs.getString('v2ray_config');
    _addLog(config != null ? 'Configuration retrieved' : 'No saved configuration found');
    return config;
  }

  Future<void> saveConfig(String config) async {
    _addLog('Saving configuration...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('v2ray_config', config);
    _addLog('Configuration saved successfully');
  }

  void _startDurationTimer() {
    _addLog('Starting duration timer');
    _durationInSeconds = 0;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _durationInSeconds++;
      notifyListeners();
    });
  }

  void _stopDurationTimer() {
    _addLog('Stopping duration timer');
    _durationTimer?.cancel();
    _durationInSeconds = 0;
  }

  List<String> _getBypassSubnets() {
    return [
      "0.0.0.0/5", "8.0.0.0/7", "11.0.0.0/8", "12.0.0.0/6", "16.0.0.0/4",
      "32.0.0.0/3", "64.0.0.0/2", "128.0.0.0/3", "160.0.0.0/5", "168.0.0.0/6",
      "172.0.0.0/12", "172.32.0.0/11", "172.64.0.0/10", "172.128.0.0/9",
      "173.0.0.0/8", "174.0.0.0/7", "176.0.0.0/4", "192.0.0.0/9",
      "192.128.0.0/11", "192.160.0.0/13", "192.169.0.0/16", "192.170.0.0/15",
      "192.172.0.0/14", "192.176.0.0/12", "192.192.0.0/10", "193.0.0.0/8",
      "194.0.0.0/7", "196.0.0.0/6", "200.0.0.0/5", "208.0.0.0/4", "240.0.0.0/4"
    ];
  }

  void _addLog(String log) {
    String timestamp = DateTime.now().toString().split('.').first;
    String formattedLog = '[$timestamp] $log';
    _logs.add(formattedLog);
    _logsController.add(_logs);
    print(formattedLog); // Add this line for debugging
  }

  @override
  void dispose() {
    _logsController.close();
    super.dispose();
  }
}