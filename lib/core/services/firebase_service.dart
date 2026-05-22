// lib/core/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/task_model.dart';
import '../../models/alarm_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user ID (should be set after authentication)
  static String? _currentUserId;

  static void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  static String? getCurrentUserId() {
    return _currentUserId;
  }

  static void _logError(String message, Object? error) {
    if (kDebugMode) {
      debugPrint('$message: $error');
    }
    // In production, errors should be logged to Firebase Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, StackTrace.current);
  }

  // ========== TASK OPERATIONS ==========

  /// Fetch all tasks for the current user
  static Future<List<TaskModel>> getAllTasks() async {
    try {
      if (_currentUserId == null) {
        _logError('Error', 'User not authenticated');
        return [];
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('tasks')
          .orderBy('scheduledTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      _logError('Firebase Error fetching tasks', e);
      return [];
    }
  }

  /// Create a new task
  static Future<TaskModel?> saveTask(TaskModel task) async {
    try {
      if (_currentUserId == null) {
        _logError('Error', 'User not authenticated');
        return null;
      }

      final taskData = task.toJson();
      taskData['userId'] = _currentUserId;

      final docRef = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('tasks')
          .add(taskData);

      return TaskModel.fromJson({...taskData, 'id': docRef.id});
    } catch (e) {
      _logError('Firebase Error creating task', e);
      return null;
    }
  }

  /// Update an existing task
  static Future<bool> updateTask(TaskModel task) async {
    try {
      if (_currentUserId == null) {
        _logError('Error', 'User not authenticated');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('tasks')
          .doc(task.id)
          .set(task.toJson(), SetOptions(merge: true));

      return true;
    } catch (e) {
      _logError('Firebase Error updating task', e);
      return false;
    }
  }

  /// Delete a task
  static Future<bool> deleteTask(String taskId) async {
    try {
      if (_currentUserId == null) {
        _logError('Error', 'User not authenticated');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('tasks')
          .doc(taskId)
          .delete();

      return true;
    } catch (e) {
      _logError('Firebase Error deleting task', e);
      return false;
    }
  }

  /// Stream of tasks for real-time updates
  static Stream<List<TaskModel>> tasksStream() {
    if (_currentUserId == null) {
      _logError('Error', 'User not authenticated');
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('tasks')
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // ========== ALARM OPERATIONS ==========

  /// Fetch all alarms for the current user
  static Future<List<AlarmModel>> getAllAlarms() async {
    try {
      if (_currentUserId == null) {
        _logError('Error', 'User not authenticated');
        return [];
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('alarms')
          .orderBy('time')
          .get();

      return snapshot.docs
          .map((doc) => AlarmModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      _logError('Firebase Error fetching alarms', e);
      return [];
    }
  }

  /// Create a new alarm
  static Future<AlarmModel?> saveAlarm(AlarmModel alarm) async {
    try {
      if (_currentUserId == null) {
        _logError('Error', 'User not authenticated');
        return null;
      }

      final alarmData = alarm.toJson();
      alarmData['userId'] = _currentUserId;

      final docRef = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('alarms')
          .add(alarmData);

      return AlarmModel.fromJson({...alarmData, 'id': docRef.id});
    } catch (e) {
      _logError('Firebase Error creating alarm', e);
      return null;
    }
  }

  /// Update an existing alarm
  static Future<bool> updateAlarm(AlarmModel alarm) async {
    try {
      if (_currentUserId == null) {
        _logError('Error', 'User not authenticated');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('alarms')
          .doc(alarm.id)
          .set(alarm.toJson(), SetOptions(merge: true));

      return true;
    } catch (e) {
      _logError('Firebase Error updating alarm', e);
      return false;
    }
  }

  /// Delete an alarm
  static Future<bool> deleteAlarm(String alarmId) async {
    try {
      if (_currentUserId == null) {
        _logError('Error', 'User not authenticated');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('alarms')
          .doc(alarmId)
          .delete();

      return true;
    } catch (e) {
      _logError('Firebase Error deleting alarm', e);
      return false;
    }
  }

  /// Stream of alarms for real-time updates
  static Stream<List<AlarmModel>> alarmsStream() {
    if (_currentUserId == null) {
      _logError('Error', 'User not authenticated');
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('alarms')
        .orderBy('time')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlarmModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
