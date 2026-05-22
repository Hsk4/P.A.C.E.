// routes/tasks/index.dart
import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  // Extract our pre-injected PostgreSQL connection
  final dbConnection = context.read<Connection>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGetTasks(dbConnection);
    case HttpMethod.post:
      return _handleCreateTask(context, dbConnection);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _handleGetTasks(Connection db) async {
  final Result result = await db.execute('SELECT id, title, is_completed, scheduled_time FROM tasks ORDER BY id DESC');

  final List<Map<String, dynamic>> tasksList = result.map((row) {
    return {
      'id': row[0],
      'title': row[1],
      'isCompleted': row[2],
      'scheduledTime': (row[3] as DateTime).toIso8601String(),
    };
  }).toList();

  return Response.json(body: tasksList);
}

Future<Response> _handleCreateTask(RequestContext context, Connection db) async {
  final body = await context.request.body();
  final Map<String, dynamic> json = jsonDecode(body);

  if (!json.containsKey('title') || json['title'].toString().trim().isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Task title context missing or structured incorrectly.'},
    );
  }

  final title = json['title'] as String;
  final isCompleted = json['isCompleted'] as bool? ?? false;
  final scheduledTime = json['scheduledTime'] != null
      ? DateTime.parse(json['scheduledTime'] as String)
      : DateTime.now();

  final Result result = await db.execute(
    Sql.named('INSERT INTO tasks (title, is_completed, scheduled_time) VALUES (@title, @isCompleted, @scheduledTime) RETURNING id'),
    parameters: {
      'title': title,
      'isCompleted': isCompleted,
      'scheduledTime': scheduledTime,
    },
  );

  final generatedId = result.first[0];

  return Response.json(
    statusCode: HttpStatus.created,
    body: {
      'id': generatedId,
      'title': title,
      'isCompleted': isCompleted,
      'scheduledTime': scheduledTime.toIso8601String(),
    },
  );
}