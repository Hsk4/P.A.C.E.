// routes/index.dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'status': 'healthy',
      'service': 'Personal Scheduler API Engine',
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    },
  );
}