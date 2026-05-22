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
    // The service account key should be provided as an environment variable or file
    final serviceAccountKey = Platform.environment['FIREBASE_SERVICE_ACCOUNT_KEY'] ??
        Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];

    if (serviceAccountKey == null) {
      throw Exception(
        'Firebase service account key not found. '
        'Set FIREBASE_SERVICE_ACCOUNT_KEY or GOOGLE_APPLICATION_CREDENTIALS environment variable.',
      );
    }

    _firebaseApp = admin.initializeApp(
      admin.AppOptions(
        credential: admin.ServiceAccountCredential.fromFile(serviceAccountKey),
        databaseUrl: Platform.environment['FIREBASE_DATABASE_URL'],
      ),
    );

    _firestore = admin.firestore(_firebaseApp!);

    // Initialize Firestore collections if needed
    await _initializeCollections(_firestore!);

    return _firestore!;
  }

  static Future<void> _initializeCollections(admin.Firestore db) async {
    // Create a default document structure if needed
    // This ensures the collections exist
    try {
      final usersCollection = db.collection('users');
      final doc = usersCollection.doc('_init');
      
      // Check if initialization document exists
      final snapshot = await doc.get();
      if (!snapshot.exists) {
        await doc.set({
          'initialized': true,
          'timestamp': admin.FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error initializing Firestore collections: $e');
    }
  }

  static Future<void> close() async {
    await _firebaseApp?.delete();
    _firebaseApp = null;
    _firestore = null;
  }
}