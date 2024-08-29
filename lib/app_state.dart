import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  bool _isConnected = false;
  String _selectedConfigPath = '';
  String _lastLogUpdate = '';

  bool get isConnected => _isConnected;
  String get selectedConfigPath => _selectedConfigPath;
  String get lastLogUpdate => _lastLogUpdate;

  void setConnectionStatus(bool status) {
    _isConnected = status;
    notifyListeners();
  }

  void setSelectedConfigPath(String path) {
    _selectedConfigPath = path;
    notifyListeners();
    _saveSelectedConfigPath();
  }

  void updateLastLog(String log) {
    _lastLogUpdate = log;
    notifyListeners();
  }

  Future<void> loadSelectedConfigPath() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedConfigPath = prefs.getString('selectedConfigPath') ?? '';
    notifyListeners();
  }

  Future<void> _saveSelectedConfigPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedConfigPath', _selectedConfigPath);
  }
}