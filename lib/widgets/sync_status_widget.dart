import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sync_service.dart';

class SyncStatusWidget extends StatefulWidget {
  final bool showDetails;
  final bool expandable;

  const SyncStatusWidget({
    super.key,
    this.showDetails = false,
    this.expandable = true,
  });

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncService>(
      builder: (context, syncService, child) {
        // Control animations based on sync state
        if (syncService.isSyncing) {
          _animationController.repeat();
        } else {
          _animationController.stop();
          _animationController.reset();
        }
        
        return widget.expandable ? _buildExpandableWidget(syncService) : _buildCompactWidget(syncService);
      },
    );
  }

  Widget _buildExpandableWidget(SyncService syncService) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        leading: _buildStatusIcon(syncService),
        title: Text(_getStatusText(syncService)),
        subtitle: _buildSubtitle(syncService),
        trailing: _buildTrailing(syncService),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: [
          if (_isExpanded) _buildExpandedContent(syncService),
        ],
      ),
    );
  }

  Widget _buildCompactWidget(SyncService syncService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(syncService).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(syncService).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(syncService, size: 16),
          const SizedBox(width: 8),
          Text(
            _getCompactStatusText(syncService),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getStatusColor(syncService),
            ),
          ),
          if (syncService.pendingOperations > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${syncService.pendingOperations}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(SyncService syncService, {double size = 24}) {
    if (syncService.isSyncing) {
      return AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Icon(
              Icons.sync,
              color: Colors.blue,
              size: size,
            ),
          );
        },
      );
    }
    
    IconData iconData;
    Color iconColor;
    
    if (!syncService.isOnline) {
      iconData = Icons.cloud_off;
      iconColor = Colors.red;
    } else if (syncService.conflicts.isNotEmpty) {
      iconData = Icons.warning;
      iconColor = Colors.orange;
    } else if (syncService.pendingOperations > 0) {
      iconData = Icons.cloud_upload;
      iconColor = Colors.orange;
    } else if (syncService.syncStatus == SyncStatus.failed) {
      iconData = Icons.error;
      iconColor = Colors.red;
    } else {
      iconData = Icons.cloud_done;
      iconColor = Colors.green;
    }
    
    return Icon(iconData, color: iconColor, size: size);
  }

  Widget _buildSubtitle(SyncService syncService) {
    if (syncService.isSyncing) {
      return const Text('Syncing data...');
    } else if (!syncService.isOnline) {
      return const Text('Offline mode');
    } else if (syncService.pendingOperations > 0) {
      return Text('${syncService.pendingOperations} operations pending');
    } else if (syncService.lastSyncTime != null) {
      return Text('Last sync: ${_formatLastSync(syncService.lastSyncTime!)}');
    }
    return const Text('Ready to sync');
  }

  Widget _buildTrailing(SyncService syncService) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(value, syncService),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'sync_now',
          child: Row(
            children: [
              Icon(Icons.sync),
              SizedBox(width: 8),
              Text('Sync Now'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_network',
          child: Row(
            children: [
              Icon(syncService.isOnline ? Icons.cloud_off : Icons.cloud),
              const SizedBox(width: 8),
              Text(syncService.isOnline ? 'Go Offline' : 'Go Online'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'simulate_issue',
          child: Row(
            children: [
              Icon(Icons.network_check),
              SizedBox(width: 8),
              Text('Simulate Network Issue'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'view_stats',
          child: Row(
            children: [
              Icon(Icons.analytics),
              SizedBox(width: 8),
              Text('View Stats'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(SyncService syncService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection Status
          _buildInfoRow(
            'Connection',
            syncService.isOnline ? 'Online' : 'Offline',
            syncService.isOnline ? Colors.green : Colors.red,
          ),
          
          // Sync Status
          _buildInfoRow(
            'Status',
            _getStatusDisplayName(syncService.syncStatus),
            _getStatusColor(syncService),
          ),
          
          // Pending Operations
          if (syncService.pendingOperations > 0)
            _buildInfoRow(
              'Pending',
              '${syncService.pendingOperations} operations',
              Colors.orange,
            ),
          
          // Conflicts
          if (syncService.conflicts.isNotEmpty)
            _buildInfoRow(
              'Conflicts',
              '${syncService.conflicts.length} conflicts need resolution',
              Colors.red,
            ),
          
          // Last Sync
          if (syncService.lastSyncTime != null)
            _buildInfoRow(
              'Last Sync',
              _formatDateTime(syncService.lastSyncTime!),
              Colors.grey,
            ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: syncService.isOnline && !syncService.isSyncing
                      ? () => syncService.syncNow()
                      : null,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Now'),
                ),
              ),
              
              if (syncService.conflicts.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showConflictsDialog(syncService),
                    icon: const Icon(Icons.warning),
                    label: const Text('Resolve Conflicts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SyncService syncService) {
    if (syncService.isSyncing) return Colors.blue;
    if (!syncService.isOnline) return Colors.red;
    if (syncService.conflicts.isNotEmpty) return Colors.orange;
    if (syncService.syncStatus == SyncStatus.failed) return Colors.red;
    if (syncService.pendingOperations > 0) return Colors.orange;
    return Colors.green;
  }

  String _getStatusText(SyncService syncService) {
    if (syncService.isSyncing) return 'Syncing Data';
    if (!syncService.isOnline) return 'Offline Mode';
    if (syncService.conflicts.isNotEmpty) return 'Sync Conflicts';
    if (syncService.pendingOperations > 0) return 'Pending Sync';
    return 'All Synced';
  }

  String _getCompactStatusText(SyncService syncService) {
    if (syncService.isSyncing) return 'Syncing';
    if (!syncService.isOnline) return 'Offline';
    if (syncService.conflicts.isNotEmpty) return 'Conflicts';
    if (syncService.pendingOperations > 0) return 'Pending';
    return 'Synced';
  }

  String _getStatusDisplayName(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Idle';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.completed:
        return 'Completed';
      case SyncStatus.failed:
        return 'Failed';
    }
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action, SyncService syncService) {
    switch (action) {
      case 'sync_now':
        if (syncService.isOnline && !syncService.isSyncing) {
          syncService.syncNow();
        }
        break;
      case 'toggle_network':
        syncService.setNetworkStatus(!syncService.isOnline);
        break;
      case 'simulate_issue':
        syncService.simulateNetworkIssue();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network reliability reduced for 10 seconds'),
            duration: Duration(seconds: 3),
          ),
        );
        break;
      case 'view_stats':
        _showStatsDialog(syncService);
        break;
    }
  }

  void _showConflictsDialog(SyncService syncService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Conflicts'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: syncService.conflicts.length,
            itemBuilder: (context, index) {
              final conflict = syncService.conflicts[index];
              return Card(
                child: ListTile(
                  title: Text('${conflict.entityType}: ${conflict.entityId.substring(0, 8)}'),
                  subtitle: Text(_getConflictTypeDisplay(conflict.conflictType)),
                  trailing: PopupMenuButton<ConflictResolutionChoice>(
                    onSelected: (choice) {
                      syncService.resolveConflict(conflict.id, choice);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: ConflictResolutionChoice.useLocal,
                        child: Text('Use Local'),
                      ),
                      const PopupMenuItem(
                        value: ConflictResolutionChoice.useServer,
                        child: Text('Use Server'),
                      ),
                      const PopupMenuItem(
                        value: ConflictResolutionChoice.merge,
                        child: Text('Merge'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(SyncService syncService) {
    final stats = syncService.getSyncStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Statistics'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...stats.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(entry.value.toString()),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getConflictTypeDisplay(ConflictType type) {
    switch (type) {
      case ConflictType.dataConflict:
        return 'Data was modified on server';
      case ConflictType.deleteConflict:
        return 'Item was deleted on server';
      case ConflictType.versionConflict:
        return 'Version mismatch';
    }
  }
}

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncService>(
      builder: (context, syncService, child) {
        if (syncService.isOnline && syncService.pendingOperations == 0) {
          return const SizedBox.shrink();
        }
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: syncService.isOnline ? Colors.orange : Colors.red,
          child: SafeArea(
            child: Row(
              children: [
                Icon(
                  syncService.isOnline ? Icons.cloud_upload : Icons.cloud_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    syncService.isOnline
                        ? '${syncService.pendingOperations} changes waiting to sync'
                        : 'Working offline - changes will sync when connected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (syncService.isOnline && !syncService.isSyncing)
                  TextButton(
                    onPressed: () => syncService.syncNow(),
                    child: const Text(
                      'SYNC NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}