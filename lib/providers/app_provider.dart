import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppProvider with ChangeNotifier {
  bool _isOfflineMode = false;
  List<Map<String, dynamic>> _offlineQueue = [];
  int _syncedOperations = 0;

  bool get isOfflineMode => _isOfflineMode;
  List<Map<String, dynamic>> get offlineQueue => _offlineQueue;
  int get syncedOperations => _syncedOperations;

  AppProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final box = Hive.box('settings');
    _isOfflineMode = box.get('offline_mode', defaultValue: false);
    _loadOfflineQueue();
    notifyListeners();
  }

  void _loadOfflineQueue() async {
    final box = Hive.box('offline_queue');
    _offlineQueue = List<Map<String, dynamic>>.from(
      box.get('queue', defaultValue: [])
    );
    notifyListeners();
  }

  void toggleOfflineMode() async {
    _isOfflineMode = !_isOfflineMode;
    
    final settingsBox = Hive.box('settings');
    await settingsBox.put('offline_mode', _isOfflineMode);

    if (!_isOfflineMode) {
      // Simulate sync when going back online
      await _syncOfflineOperations();
    }

    notifyListeners();
  }

  void addOfflineOperation(String operation, Map<String, dynamic> data) async {
    if (!_isOfflineMode) return;

    final operationData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _offlineQueue.add(operationData);
    
    final box = Hive.box('offline_queue');
    await box.put('queue', _offlineQueue);
    
    notifyListeners();
  }

  Future<void> _syncOfflineOperations() async {
    if (_offlineQueue.isEmpty) return;

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    _syncedOperations = _offlineQueue.length;
    _offlineQueue.clear();

    final box = Hive.box('offline_queue');
    await box.put('queue', _offlineQueue);

    notifyListeners();

    // Reset synced operations count after showing notification
    Future.delayed(const Duration(seconds: 5), () {
      _syncedOperations = 0;
      notifyListeners();
    });
  }

  void showSyncNotification(BuildContext context) {
    if (_syncedOperations > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $_syncedOperations updates synced successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}