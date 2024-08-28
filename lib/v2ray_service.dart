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
    bool permission = await _flutterV2ray.requestPermission();
    _addLog('VPN permission ${permission ? 'granted' : 'denied'}');
    return permission;
  }

  Future<void> startV2Ray(String config) async {
    if (await requestPermission()) {
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
      _addLog('V2Ray started');
      notifyListeners();
    } else {
      _addLog('Failed to start V2Ray: Permission denied');
    }
  }

  Future<void> stopV2Ray() async {
    await _flutterV2ray.stopV2Ray();
    _isConnected = false;
    _stopDurationTimer();
    _addLog('V2Ray stopped');
    notifyListeners();
  }

  Future<String?> getSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('v2ray_config');
  }

  Future<void> saveConfig(String config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('v2ray_config', config);
    _addLog('Configuration saved');
  }

  void _startDurationTimer() {
    _durationInSeconds = 0;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _durationInSeconds++;
      notifyListeners();
    });
  }

  void _stopDurationTimer() {
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
  }

  @override
  void dispose() {
    _logsController.close();
    super.dispose();
  }
}