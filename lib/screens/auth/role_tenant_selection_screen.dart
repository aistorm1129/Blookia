import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/user.dart';
import '../../models/tenant.dart';
import '../dashboard/dashboard_screen.dart';

class RoleTenantSelectionScreen extends StatefulWidget {
  const RoleTenantSelectionScreen({super.key});

  @override
  State<RoleTenantSelectionScreen> createState() => _RoleTenantSelectionScreenState();
}

class _RoleTenantSelectionScreenState extends State<RoleTenantSelectionScreen> {
  UserRole _selectedRole = UserRole.professional;
  Tenant? _selectedTenant;
  User? _selectedUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.tenants.isNotEmpty) {
        setState(() {
          _selectedTenant = authProvider.tenants.first;
          _updateSelectedUser();
        });
      }
    });
  }

  void _updateSelectedUser() {
    if (_selectedTenant == null) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final users = authProvider.getUsersForTenant(_selectedTenant!.id);
    final usersWithRole = users.where((u) => u.role == _selectedRole).toList();
    
    setState(() {
      _selectedUser = usersWithRole.isNotEmpty ? usersWithRole.first : null;
    });
  }

  void _onRoleChanged(UserRole? role) {
    if (role != null) {
      setState(() {
        _selectedRole = role;
        _updateSelectedUser();
      });
    }
  }

  void _onTenantChanged(Tenant? tenant) {
    if (tenant != null) {
      setState(() {
        _selectedTenant = tenant;
        _updateSelectedUser();
      });
    }
  }

  void _proceed() async {
    if (_selectedUser == null || _selectedTenant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both role and clinic'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.setUserAndTenant(_selectedUser!, _selectedTenant!);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to authenticate. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SettingsProvider>(
      builder: (context, auth, settings, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF3B82F6),
                  Color(0xFF10B981),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header
                    const SizedBox(height: 40),
                    const Icon(
                      Icons.medical_services,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      settings.translate('welcome'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your role and clinic to continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Selection Cards
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Role Selection
                            Text(
                              'Select Role',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            ...UserRole.values.map((role) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () => _onRoleChanged(role),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == role 
                                          ? const Color(0xFF2563EB).withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.05),
                                      border: Border.all(
                                        color: _selectedRole == role 
                                            ? const Color(0xFF2563EB)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getRoleIcon(role),
                                          color: _selectedRole == role 
                                              ? const Color(0xFF2563EB)
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _getRoleDisplayName(role),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: _selectedRole == role 
                                                ? FontWeight.w600 
                                                : FontWeight.w400,
                                            color: _selectedRole == role 
                                                ? const Color(0xFF2563EB)
                                                : const Color(0xFF374151),
                                          ),
                                        ),
                                        const Spacer(),
                                        if (_selectedRole == role)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF2563EB),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            
                            const SizedBox(height: 24),
                            
                            // Tenant Selection
                            Text(
                              'Select Clinic',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            if (auth.tenants.isNotEmpty)
                              ...auth.tenants.map((tenant) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: InkWell(
                                    onTap: () => _onTenantChanged(tenant),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: _selectedTenant?.id == tenant.id 
                                            ? const Color(0xFF10B981).withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.05),
                                        border: Border.all(
                                          color: _selectedTenant?.id == tenant.id 
                                              ? const Color(0xFF10B981)
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: _selectedTenant?.id == tenant.id 
                                                  ? const Color(0xFF10B981)
                                                  : Colors.grey,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                tenant.name[0].toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tenant.name,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: _selectedTenant?.id == tenant.id 
                                                        ? FontWeight.w600 
                                                        : FontWeight.w400,
                                                    color: _selectedTenant?.id == tenant.id 
                                                        ? const Color(0xFF10B981)
                                                        : const Color(0xFF374151),
                                                  ),
                                                ),
                                                Text(
                                                  tenant.country,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_selectedTenant?.id == tenant.id)
                                            const Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF10B981),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            
                            const Spacer(),
                            
                            // Continue Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _proceed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.professional:
        return Icons.medical_services;
      case UserRole.reception:
        return Icons.desk;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.professional:
        return 'Professional';
      case UserRole.reception:
        return 'Reception';
    }
  }
}

