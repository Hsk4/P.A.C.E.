// routes/tasks/_middleware.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:scheduler_backend/database.dart';
import 'package:firebase_admin/firebase_admin.dart' as admin;

Handler middleware(Handler handler) {
  return (context) async {
    try {
      final firestore = await FirebaseDatabase.firestore;

      // Inject the Firestore instance into the request routing context
      final updatedContext = context.provide<admin.Firestore>(() => firestore);

      return await handler(updatedContext);
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Failed to establish Firebase connection: $e'},
      );
    }
  };
}