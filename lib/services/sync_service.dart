import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../models/payment.dart';
import '../models/chat_message.dart';

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _uuid = const Uuid();
  Timer? _syncTimer;
  Timer? _heartbeatTimer;
  
  // Sync state
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _pendingOperations = 0;
  SyncStatus _syncStatus = SyncStatus.idle;
  String? _lastError;
  
  // Sync queues
  final List<SyncOperation> _syncQueue = [];
  final List<ConflictResolution> _conflicts = [];
  
  // Connection simulation
  double _networkLatency = 0.5; // seconds
  double _networkReliability = 0.95; // 95% success rate
  
  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingOperations => _pendingOperations;
  SyncStatus get syncStatus => _syncStatus;
  String? get lastError => _lastError;
  List<ConflictResolution> get conflicts => _conflicts;
  int get queueSize => _syncQueue.length;

  void initialize() {
    _startPeriodicSync();
    _startNetworkHeartbeat();
    _loadPendingOperations();
  }

  void dispose() {
    _syncTimer?.cancel();
    _heartbeatTimer?.cancel();
  }

  // Network simulation
  void _startNetworkHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _simulateNetworkCheck();
    });
  }

  void _simulateNetworkCheck() {
    // Simulate network connectivity changes
    final random = Random();
    final wasOnline = _isOnline;
    
    // 98% uptime simulation
    _isOnline = random.nextDouble() > 0.02;
    
    // Simulate varying network conditions
    if (_isOnline) {
      _networkLatency = 0.2 + (random.nextDouble() * 2.0); // 0.2-2.2s
      _networkReliability = 0.85 + (random.nextDouble() * 0.14); // 85-99%
    }
    
    if (wasOnline != _isOnline) {
      notifyListeners();
      
      if (_isOnline && _syncQueue.isNotEmpty) {
        // Auto-sync when coming back online
        syncNow();
      }
    }
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_isOnline && _syncQueue.isNotEmpty) {
        syncNow();
      }
    });
  }

  // Public sync methods
  Future<void> syncNow() async {
    if (_isSyncing || !_isOnline) return;
    
    _setSyncStatus(SyncStatus.syncing);
    
    try {
      await _processSyncQueue();
      _setSyncStatus(SyncStatus.completed);
      _lastSyncTime = DateTime.now();
      _saveSyncMetadata();
    } catch (e) {
      _lastError = e.toString();
      _setSyncStatus(SyncStatus.failed);
      debugPrint('Sync failed: $e');
    }
    
    notifyListeners();
  }

  // Queue operations for sync
  void queueOperation(SyncOperation operation) {
    _syncQueue.add(operation);
    _pendingOperations = _syncQueue.length;
    _savePendingOperations();
    notifyListeners();
    
    // Auto-sync if online and not currently syncing
    if (_isOnline && !_isSyncing) {
      Timer(const Duration(seconds: 1), () => syncNow());
    }
  }

  // Specific sync operations
  void syncCreatePatient(Patient patient) {
    queueOperation(SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.create,
      entityType: 'patient',
      entityId: patient.id,
      data: patient.toJson(),
      timestamp: DateTime.now(),
      priority: SyncPriority.normal,
    ));
  }

  void syncUpdatePatient(Patient patient) {
    queueOperation(SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.update,
      entityType: 'patient',
      entityId: patient.id,
      data: patient.toJson(),
      timestamp: DateTime.now(),
      priority: SyncPriority.normal,
    ));
  }

  void syncDeletePatient(String patientId) {
    queueOperation(SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.delete,
      entityType: 'patient',
      entityId: patientId,
      data: {'id': patientId},
      timestamp: DateTime.now(),
      priority: SyncPriority.normal,
    ));
  }

  void syncCreateAppointment(Appointment appointment) {
    queueOperation(SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.create,
      entityType: 'appointment',
      entityId: appointment.id,
      data: appointment.toJson(),
      timestamp: DateTime.now(),
      priority: SyncPriority.high, // Appointments are high priority
    ));
  }

  void syncUpdateAppointment(Appointment appointment) {
    queueOperation(SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.update,
      entityType: 'appointment',
      entityId: appointment.id,
      data: appointment.toJson(),
      timestamp: DateTime.now(),
      priority: SyncPriority.high,
    ));
  }

  void syncPayment(Payment payment) {
    queueOperation(SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.create,
      entityType: 'payment',
      entityId: payment.id,
      data: payment.toJson(),
      timestamp: DateTime.now(),
      priority: SyncPriority.critical, // Payments are critical
    ));
  }

  void syncChatMessage(ChatMessage message) {
    queueOperation(SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.create,
      entityType: 'chat_message',
      entityId: message.id,
      data: message.toJson(),
      timestamp: DateTime.now(),
      priority: SyncPriority.low, // Chat messages are low priority
    ));
  }

  // Process sync queue
  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty) return;

    // Sort by priority and timestamp
    _syncQueue.sort((a, b) {
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;
      return a.timestamp.compareTo(b.timestamp);
    });

    final failedOperations = <SyncOperation>[];
    
    for (final operation in List<SyncOperation>.from(_syncQueue)) {
      try {
        final success = await _executeOperation(operation);
        if (success) {
          _syncQueue.remove(operation);
        } else {
          failedOperations.add(operation);
        }
        
        // Add small delay between operations
        await Future.delayed(Duration(milliseconds: 100));
        
      } catch (e) {
        debugPrint('Failed to execute operation ${operation.id}: $e');
        failedOperations.add(operation);
      }
    }

    // Update pending operations count
    _pendingOperations = _syncQueue.length;
    
    if (failedOperations.isNotEmpty) {
      _handleFailedOperations(failedOperations);
    }
    
    _savePendingOperations();
  }

  Future<bool> _executeOperation(SyncOperation operation) async {
    // Simulate network latency
    await Future.delayed(Duration(milliseconds: (_networkLatency * 1000).round()));
    
    // Simulate network reliability
    if (Random().nextDouble() > _networkReliability) {
      throw Exception('Network request failed');
    }
    
    // Simulate server response based on operation
    switch (operation.entityType) {
      case 'patient':
        return await _syncPatientOperation(operation);
      case 'appointment':
        return await _syncAppointmentOperation(operation);
      case 'payment':
        return await _syncPaymentOperation(operation);
      case 'chat_message':
        return await _syncChatMessageOperation(operation);
      default:
        debugPrint('Unknown entity type: ${operation.entityType}');
        return false;
    }
  }

  Future<bool> _syncPatientOperation(SyncOperation operation) async {
    // Simulate server processing
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Check for conflicts (simulate server-side changes)
    if (operation.type == SyncOperationType.update && Random().nextDouble() < 0.05) {
      // 5% chance of conflict
      _handleSyncConflict(operation);
      return false;
    }
    
    debugPrint('Synced patient operation: ${operation.type} for ${operation.entityId}');
    return true;
  }

  Future<bool> _syncAppointmentOperation(SyncOperation operation) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Appointments have higher chance of conflicts due to scheduling
    if (operation.type != SyncOperationType.create && Random().nextDouble() < 0.1) {
      _handleSyncConflict(operation);
      return false;
    }
    
    debugPrint('Synced appointment operation: ${operation.type} for ${operation.entityId}');
    return true;
  }

  Future<bool> _syncPaymentOperation(SyncOperation operation) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Payments are critical and rarely fail
    if (Random().nextDouble() < 0.01) {
      throw Exception('Payment processing failed - will retry');
    }
    
    debugPrint('Synced payment operation: ${operation.type} for ${operation.entityId}');
    return true;
  }

  Future<bool> _syncChatMessageOperation(SyncOperation operation) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Chat messages are simple and rarely fail
    debugPrint('Synced chat message: ${operation.entityId}');
    return true;
  }

  void _handleSyncConflict(SyncOperation operation) {
    final conflict = ConflictResolution(
      id: _uuid.v4(),
      operationId: operation.id,
      entityType: operation.entityType,
      entityId: operation.entityId,
      localData: operation.data,
      serverData: _generateMockServerData(operation),
      conflictType: _determineConflictType(operation),
      timestamp: DateTime.now(),
    );
    
    _conflicts.add(conflict);
    notifyListeners();
  }

  Map<String, dynamic> _generateMockServerData(SyncOperation operation) {
    // Generate mock conflicting server data
    final serverData = Map<String, dynamic>.from(operation.data);
    
    if (operation.entityType == 'patient') {
      serverData['name'] = '${serverData['name']} (Server Version)';
      serverData['updatedAt'] = DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String();
    } else if (operation.entityType == 'appointment') {
      serverData['notes'] = 'Updated by another user';
      serverData['updatedAt'] = DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String();
    }
    
    return serverData;
  }

  ConflictType _determineConflictType(SyncOperation operation) {
    switch (operation.type) {
      case SyncOperationType.update:
        return ConflictType.dataConflict;
      case SyncOperationType.delete:
        return ConflictType.deleteConflict;
      default:
        return ConflictType.dataConflict;
    }
  }

  void _handleFailedOperations(List<SyncOperation> failedOperations) {
    for (final operation in failedOperations) {
      operation.retryCount++;
      operation.lastRetry = DateTime.now();
      
      // Exponential backoff for retries
      final backoffMinutes = pow(2, operation.retryCount).toInt();
      operation.nextRetry = DateTime.now().add(Duration(minutes: backoffMinutes));
      
      // Remove operation after max retries
      if (operation.retryCount >= 5) {
        debugPrint('Operation ${operation.id} failed permanently after ${operation.retryCount} retries');
        _syncQueue.remove(operation);
      }
    }
  }

  // Conflict resolution
  void resolveConflict(String conflictId, ConflictResolutionChoice choice) {
    final conflict = _conflicts.firstWhere((c) => c.id == conflictId);
    
    switch (choice) {
      case ConflictResolutionChoice.useLocal:
        // Re-queue the original operation with higher priority
        final originalOperation = _syncQueue.firstWhere(
          (op) => op.id == conflict.operationId,
          orElse: () => SyncOperation(
            id: conflict.operationId,
            type: SyncOperationType.update,
            entityType: conflict.entityType,
            entityId: conflict.entityId,
            data: conflict.localData,
            timestamp: DateTime.now(),
            priority: SyncPriority.high,
            forceOverwrite: true,
          ),
        );
        
        if (!_syncQueue.contains(originalOperation)) {
          queueOperation(originalOperation);
        }
        break;
        
      case ConflictResolutionChoice.useServer:
        // Update local data with server version
        _applyServerData(conflict);
        break;
        
      case ConflictResolutionChoice.merge:
        // Create merged data
        final mergedData = _mergeData(conflict.localData, conflict.serverData);
        queueOperation(SyncOperation(
          id: _uuid.v4(),
          type: SyncOperationType.update,
          entityType: conflict.entityType,
          entityId: conflict.entityId,
          data: mergedData,
          timestamp: DateTime.now(),
          priority: SyncPriority.high,
        ));
        break;
    }
    
    _conflicts.remove(conflict);
    notifyListeners();
  }

  void _applyServerData(ConflictResolution conflict) {
    // In a real app, this would update the local database
    debugPrint('Applied server data for ${conflict.entityType}:${conflict.entityId}');
  }

  Map<String, dynamic> _mergeData(Map<String, dynamic> local, Map<String, dynamic> server) {
    // Simple merge strategy - in real app this would be more sophisticated
    final merged = Map<String, dynamic>.from(server);
    
    // Keep local changes for specific fields
    if (local.containsKey('notes')) {
      merged['notes'] = '${local['notes']}\n\n[Server note: ${server['notes'] ?? ''}]';
    }
    
    merged['mergedAt'] = DateTime.now().toIso8601String();
    return merged;
  }

  // Persistence
  void _loadPendingOperations() async {
    try {
      final box = await Hive.openBox('sync_operations');
      final operations = box.get('pending_operations', defaultValue: <String>[]) as List<String>;
      
      _syncQueue.clear();
      for (final operationJson in operations) {
        final operation = SyncOperation.fromJson(jsonDecode(operationJson));
        _syncQueue.add(operation);
      }
      
      _pendingOperations = _syncQueue.length;
      
      final metadata = box.get('sync_metadata', defaultValue: <String, dynamic>{}) as Map<String, dynamic>;
      if (metadata.containsKey('lastSyncTime')) {
        _lastSyncTime = DateTime.parse(metadata['lastSyncTime']);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load pending operations: $e');
    }
  }

  void _savePendingOperations() async {
    try {
      final box = await Hive.openBox('sync_operations');
      final operations = _syncQueue.map((op) => jsonEncode(op.toJson())).toList();
      await box.put('pending_operations', operations);
    } catch (e) {
      debugPrint('Failed to save pending operations: $e');
    }
  }

  void _saveSyncMetadata() async {
    try {
      final box = await Hive.openBox('sync_operations');
      await box.put('sync_metadata', {
        'lastSyncTime': _lastSyncTime?.toIso8601String(),
        'syncStatus': _syncStatus.index,
      });
    } catch (e) {
      debugPrint('Failed to save sync metadata: $e');
    }
  }

  void _setSyncStatus(SyncStatus status) {
    _syncStatus = status;
    _isSyncing = status == SyncStatus.syncing;
    
    if (status != SyncStatus.syncing) {
      _lastError = null;
    }
  }

  // Manual network control (for testing)
  void setNetworkStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  void simulateNetworkIssue() {
    _networkReliability = 0.3; // 30% success rate
    Timer(const Duration(seconds: 10), () {
      _networkReliability = 0.95; // Restore to 95%
    });
  }

  // Stats and monitoring
  Map<String, dynamic> getSyncStats() {
    return {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'pendingOperations': _pendingOperations,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'conflicts': _conflicts.length,
      'networkLatency': _networkLatency,
      'networkReliability': _networkReliability,
      'syncStatus': _syncStatus.toString(),
      'queueSize': _syncQueue.length,
    };
  }
}

// Data classes
class SyncOperation {
  final String id;
  final SyncOperationType type;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final SyncPriority priority;
  final bool forceOverwrite;
  
  int retryCount;
  DateTime? lastRetry;
  DateTime? nextRetry;

  SyncOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.timestamp,
    required this.priority,
    this.forceOverwrite = false,
    this.retryCount = 0,
    this.lastRetry,
    this.nextRetry,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'entityType': entityType,
      'entityId': entityId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority.index,
      'forceOverwrite': forceOverwrite,
      'retryCount': retryCount,
      'lastRetry': lastRetry?.toIso8601String(),
      'nextRetry': nextRetry?.toIso8601String(),
    };
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'],
      type: SyncOperationType.values[json['type']],
      entityType: json['entityType'],
      entityId: json['entityId'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
      priority: SyncPriority.values[json['priority']],
      forceOverwrite: json['forceOverwrite'] ?? false,
      retryCount: json['retryCount'] ?? 0,
      lastRetry: json['lastRetry'] != null ? DateTime.parse(json['lastRetry']) : null,
      nextRetry: json['nextRetry'] != null ? DateTime.parse(json['nextRetry']) : null,
    );
  }
}

class ConflictResolution {
  final String id;
  final String operationId;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final ConflictType conflictType;
  final DateTime timestamp;

  ConflictResolution({
    required this.id,
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.serverData,
    required this.conflictType,
    required this.timestamp,
  });
}

// Enums
enum SyncOperationType { create, update, delete }
enum SyncPriority { low, normal, high, critical }
enum SyncStatus { idle, syncing, completed, failed }
enum ConflictType { dataConflict, deleteConflict, versionConflict }
enum ConflictResolutionChoice { useLocal, useServer, merge }