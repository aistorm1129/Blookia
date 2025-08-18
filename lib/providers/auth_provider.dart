import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/tenant.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  Tenant? _currentTenant;
  List<Tenant> _tenants = [];

  User? get currentUser => _currentUser;
  Tenant? get currentTenant => _currentTenant;
  List<Tenant> get tenants => _tenants;
  bool get isAuthenticated => _currentUser != null && _currentTenant != null;

  AuthProvider() {
    _loadAuth();
  }

  void _loadAuth() async {
    final settingsBox = Hive.box('settings');
    final userId = settingsBox.get('current_user_id');
    final tenantId = settingsBox.get('current_tenant_id');

    if (userId != null && tenantId != null) {
      final userBox = Hive.box('users');
      final tenantBox = Hive.box('tenants');

      final userData = userBox.get(userId);
      final tenantData = tenantBox.get(tenantId);

      if (userData != null && tenantData != null) {
        _currentUser = User.fromJson(Map<String, dynamic>.from(userData));
        _currentTenant = Tenant.fromJson(Map<String, dynamic>.from(tenantData));
      }
    }

    _loadTenants();
    notifyListeners();
  }

  void _loadTenants() async {
    final box = Hive.box('tenants');
    _tenants = box.values
        .map((data) => Tenant.fromJson(Map<String, dynamic>.from(data)))
        .toList();
    notifyListeners();
  }

  Future<void> setUserAndTenant(User user, Tenant tenant) async {
    _currentUser = user;
    _currentTenant = tenant;

    final settingsBox = Hive.box('settings');
    await settingsBox.put('current_user_id', user.id);
    await settingsBox.put('current_tenant_id', tenant.id);

    // Update last login
    user.lastLoginAt = DateTime.now();
    final userBox = Hive.box('users');
    await userBox.put(user.id, user.toJson());

    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _currentTenant = null;

    final settingsBox = Hive.box('settings');
    await settingsBox.delete('current_user_id');
    await settingsBox.delete('current_tenant_id');

    notifyListeners();
  }

  List<User> getUsersForTenant(String tenantId) {
    final box = Hive.box('users');
    return box.values
        .map((data) => User.fromJson(Map<String, dynamic>.from(data)))
        .where((user) => user.tenantId == tenantId && user.isActive)
        .toList();
  }

  String get currentUserRoleDisplay {
    if (_currentUser == null) return '';
    
    switch (_currentUser!.role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.professional:
        return 'Professional';
      case UserRole.reception:
        return 'Reception';
    }
  }
}