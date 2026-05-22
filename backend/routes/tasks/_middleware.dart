// routes/tasks/_middleware.dart
// import 'dart:convert' as Response;

import 'package:dart_frog/dart_frog.dart';
import 'package:scheduler_backend/database.dart';
import 'package:postgres/postgres.dart';

Handler middleware(Handler handler) {
  return (context) async {
    try {
      final conn = await DatabaseClient.connection;

      // Inject the connection instance provider into the request routing context
      final updatedContext = context.provide<Connection>(() => conn);

      return await handler(updatedContext);
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Failed to establish cloud database handshake: $e'},
      );
    }
  };
}