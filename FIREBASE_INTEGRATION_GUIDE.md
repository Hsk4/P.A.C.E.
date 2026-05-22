// FIREBASE_INTEGRATION_GUIDE.md
# Firebase Integration Implementation Guide

This guide explains how the P.A.C.E application has been integrated with Firebase and how to complete the setup.

## What Has Been Done

### 1. Frontend Dependencies Added
- `firebase_core`: Core Firebase SDK
- `cloud_firestore`: Firestore database
- `firebase_auth`: User authentication (optional)
- `firebase_messaging`: Cloud messaging for notifications
- `firebase_analytics`: App analytics
- `firebase_crashlytics`: Crash reporting

### 2. Created Firebase Service Layer
**File**: `lib/core/services/firebase_service.dart`

This service provides all Firebase operations:
- `getAllTasks()` - Fetch all tasks from Firestore
- `saveTask()` - Create a new task
- `updateTask()` - Update an existing task
- `deleteTask()` - Delete a task
- `tasksStream()` - Real-time task updates
- `getAllAlarms()` - Fetch all alarms
- `saveAlarm()` - Create a new alarm
- `updateAlarm()` - Update an existing alarm
- `deleteAlarm()` - Delete an alarm
- `alarmsStream()` - Real-time alarm updates
- `setCurrentUserId()` - Set the current user for data operations
- `getCurrentUserId()` - Get the current user ID

### 3. Updated Data Models
**Files**: `lib/models/task_model.dart`, `lib/models/alarm_model.dart`

Added to both models:
- `userId` field for multi-user support
- `toJson()` method for Firestore serialization
- `fromJson()` factory constructor for deserialization

### 4. Updated Main Application File
**File**: `lib/main.dart`

Changes:
- Initialized Firebase in `main()` function
- Replaced global state lists with `StreamBuilder` for real-time updates
- Connected screens to Firebase streams
- Integrated Firebase save/update operations with user actions

### 5. Backend Migration
**Files**: 
- `backend/pubspec.yaml`
- `backend/lib/database.dart`
- `backend/routes/tasks/index.dart`
- `backend/routes/tasks/_middleware.dart`

Changes:
- Replaced PostgreSQL with Firebase Admin SDK
- Updated database client to use Firestore instead of SQL
- Modified task endpoints to use Firestore operations
- Updated middleware for Firebase connection injection

### 6. Configuration Files Created
- `lib/firebase_options.dart` - Firebase platform configuration (needs actual credentials)
- `FIREBASE_SETUP.md` - Complete Firebase setup instructions

## What Still Needs To Be Done

### Step 1: Set Up Firebase Project
1. Go to [Firebase Console](https://firebase.google.com/console)
2. Create a new project or select an existing one
3. Enable Firestore Database
4. Enable Authentication (if using user login)
5. Configure security rules

### Step 2: Get Firebase Credentials

For Flutter App:
```bash
cd /tmp/workspace/Hsk4/P.A.C.E
flutterfire configure
```

This will automatically update `lib/firebase_options.dart` with your credentials.

For Backend:
1. In Firebase Console, go to Project Settings > Service Accounts
2. Generate a new private key
3. Save it as `serviceAccountKey.json`

### Step 3: Configure Firebase Options

Update `lib/firebase_options.dart` with your actual Firebase credentials from the Firebase console. The file contains placeholders that look like:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_WEB_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
);
```

### Step 4: Set Up Firestore Security Rules

In Firebase Console, update Firestore security rules to:
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to access their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      match /tasks/{taskId} {
        allow read, write: if request.auth.uid == userId;
      }
      
      match /alarms/{alarmId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

### Step 5: Install Frontend Dependencies

```bash
cd /tmp/workspace/Hsk4/P.A.C.E
flutter pub get
```

### Step 6: Configure Backend

```bash
cd backend

# Set environment variables
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json
export FIREBASE_DATABASE_URL=https://your-project-id.firebaseio.com

# Install dependencies
dart pub get
```

### Step 7: Update User Authentication

Currently, the app uses a hardcoded user ID (`demo_user_123`). To implement real user authentication:

```dart
// In main.dart, replace:
FirebaseService.setCurrentUserId('demo_user_123');

// With:
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user != null) {
    FirebaseService.setCurrentUserId(user.uid);
  }
});
```

### Step 8: Run and Test

**Frontend:**
```bash
flutter run
```

**Backend:**
```bash
cd backend
dart_frog dev
```

## Architecture Overview

### Data Flow

```
Flutter App
    ↓
Firebase Service (lib/core/services/firebase_service.dart)
    ↓
Cloud Firestore
```

### Real-Time Updates

The app uses Firestore streams for real-time synchronization:
- When data changes in Firestore, all connected clients are automatically notified
- `StreamBuilder` widgets automatically update the UI when streams emit new data
- No manual polling needed

### Backend Integration

The backend can optionally be used for:
- Advanced queries and aggregations
- Server-side business logic
- Scheduled tasks and cron jobs
- Data validation and security checks

Current backend API endpoints:
- `GET /tasks?userId={userId}` - Fetch tasks
- `POST /tasks` - Create task

## File Structure

```
lib/
├── core/
│   └── services/
│       ├── firebase_service.dart (NEW - Firebase operations)
│       ├── network_service.dart (legacy - can be removed)
│       ├── notify_service.dart
│       └── audio_service.dart
├── models/
│   ├── task_model.dart (updated with Firebase support)
│   └── alarm_model.dart (updated with Firebase support)
├── screens/
│   ├── dashboard_screen.dart
│   ├── task_screen.dart
│   ├── alarm_screen.dart
│   └── pomodoro_screen.dart
├── firebase_options.dart (NEW - Firebase config)
└── main.dart (updated with Firebase initialization)

backend/
├── lib/
│   └── database.dart (updated to use Firebase)
├── routes/
│   └── tasks/
│       ├── _middleware.dart (updated for Firebase)
│       └── index.dart (updated for Firebase)
└── pubspec.yaml (updated with Firebase dependencies)
```

## Troubleshooting

### Firebase Initialization Errors
- Ensure `firebase_options.dart` has correct credentials
- Check that `Firebase.initializeApp()` is called before building the app
- Verify platform-specific configurations (google-services.json for Android, GoogleService-Info.plist for iOS)

### Firestore Permission Denied
- Check Firestore security rules
- Verify `setCurrentUserId()` is called with correct user ID
- Ensure user ID matches the authenticated user (if using auth)

### Backend Connection Issues
- Verify service account key file exists at path specified in `GOOGLE_APPLICATION_CREDENTIALS`
- Check `FIREBASE_DATABASE_URL` matches your project
- Ensure backend has internet connectivity

### Real-Time Updates Not Working
- Check that Firestore listeners are active
- Verify Firestore collection paths match code
- Check browser/device network connection

## Next Steps

1. ✅ Dependencies added
2. ✅ Firebase service created
3. ✅ Models updated with serialization
4. ✅ Main app integrated with Firebase streams
5. ✅ Backend migrated to Firebase
6. ⏳ **Configure Firebase credentials** (see FIREBASE_SETUP.md)
7. ⏳ **Set up security rules**
8. ⏳ **Test all functionality**
9. ⏳ **(Optional) Add user authentication**
10. ⏳ **(Optional) Deploy to Firebase Hosting**

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Dart Frog Documentation](https://dartfrog.vvv.dev)

## Questions or Issues?

Refer to the FIREBASE_SETUP.md file for detailed setup instructions or the official Firebase documentation for more information.
