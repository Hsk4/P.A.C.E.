// routes/tasks/index.dart
import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:firebase_admin/firebase_admin.dart' as admin;
import '../../lib/database.dart';

Future<Response> onRequest(RequestContext context) async {
  // Get Firestore instance from the service
  final db = await FirebaseDatabase.firestore;

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGetTasks(db, context);
    case HttpMethod.post:
      return _handleCreateTask(context, db);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _handleGetTasks(admin.Firestore db, RequestContext context) async {
  try {
    // Extract userId from query parameter or header
    final userId = context.request.uri.queryParameters['userId'] ?? 'demo_user_123';

    final snapshot = await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('scheduledTime', descending: true)
        .get();

    final List<Map<String, dynamic>> tasksList = [];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      tasksList.add({
        'id': doc.id,
        'userId': data['userId'] ?? userId,
        'title': data['title'] ?? '',
        'isCompleted': data['isCompleted'] ?? false,
        'scheduledTime': data['scheduledTime'] != null
            ? (data['scheduledTime'] as DateTime).toIso8601String()
            : DateTime.now().toIso8601String(),
      });
    }

    return Response.json(body: tasksList);
  } catch (e) {
    print('Firebase Error fetching tasks: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch tasks', 'details': e.toString()},
    );
  }
}

Future<Response> _handleCreateTask(RequestContext context, admin.Firestore db) async {
  try {
    final body = await context.request.body();
    final Map<String, dynamic> json = jsonDecode(body);

    if (!json.containsKey('title') || json['title'].toString().trim().isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Task title is missing or structured incorrectly.'},
      );
    }

    final userId = json['userId'] as String? ?? 'demo_user_123';
    final title = json['title'] as String;
    final isCompleted = json['isCompleted'] as bool? ?? false;
    final scheduledTime = json['scheduledTime'] != null
        ? DateTime.parse(json['scheduledTime'] as String)
        : DateTime.now();

    // Create task document in Firestore
    final docRef = await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add({
          'userId': userId,
          'title': title,
          'isCompleted': isCompleted,
          'scheduledTime': admin.Timestamp.fromDateTime(scheduledTime),
          'createdAt': admin.FieldValue.serverTimestamp(),
        });

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'id': docRef.id,
        'userId': userId,
        'title': title,
        'isCompleted': isCompleted,
        'scheduledTime': scheduledTime.toIso8601String(),
      },
    );
  } catch (e) {
    print('Firebase Error creating task: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create task', 'details': e.toString()},
    );
  }
}