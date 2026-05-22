// lib/database.dart
import 'dart:io';
import 'package:firebase_admin/firebase_admin.dart' as admin;

class FirebaseDatabase {
  static FirebaseApp? _firebaseApp;
  static admin.Firestore? _firestore;

  static Future<admin.Firestore> get firestore async {
    if (_firestore != null) {
      return _firestore!;
    }

    // Initialize Firebase Admin SDK
    // The service account key should be provided as an environment variable or file path
    // FIREBASE_SERVICE_ACCOUNT_KEY: Path to the Firebase service account JSON file
    // GOOGLE_APPLICATION_CREDENTIALS: Alternative environment variable for the key file path
    final serviceAccountKey = Platform.environment['FIREBASE_SERVICE_ACCOUNT_KEY'] ??
        Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];

    if (serviceAccountKey == null) {
      throw Exception(
        'Firebase service account key not found. '
        'Set FIREBASE_SERVICE_ACCOUNT_KEY or GOOGLE_APPLICATION_CREDENTIALS environment variable '
        'to the path of your Firebase service account JSON file.',
      );
    }

    _firebaseApp = admin.initializeApp(
      admin.AppOptions(
        credential: admin.ServiceAccountCredential.fromFile(serviceAccountKey),
        databaseUrl: Platform.environment['FIREBASE_DATABASE_URL'],
      ),
    );

    _firestore = admin.firestore(_firebaseApp!);

    return _firestore!;
  }

  static Future<void> close() async {
    await _firebaseApp?.delete();
    _firebaseApp = null;
    _firestore = null;
  }
}