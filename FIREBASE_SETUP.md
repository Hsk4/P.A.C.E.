// FIREBASE_SETUP.md
# Firebase Integration Guide

This document explains how to set up and configure Firebase for the P.A.C.E (Personal Achiever's Coding Environment) project.

## Prerequisites

1. A Firebase project (create one at https://firebase.google.com)
2. Flutter installed on your system
3. For backend: Dart SDK >= 3.4.0

## Frontend Setup (Flutter App)

### Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### Step 2: Add Firebase to Flutter Project

```bash
cd /path/to/P.A.C.E
flutterfire configure
```

This command will:
- Create `lib/firebase_options.dart` with your Firebase credentials
- Add Firebase dependencies to `pubspec.yaml`
- Configure iOS/Android/Web platform-specific settings

### Step 3: Update Firebase Options

The `lib/firebase_options.dart` file was generated with placeholder values. Ensure it contains your actual Firebase project credentials for all platforms:

**Web:**
- API Key
- App ID
- Messaging Sender ID
- Project ID

**Android:**
- API Key
- App ID
- Messaging Sender ID
- Project ID

**iOS/macOS:**
- API Key
- App ID
- Messaging Sender ID
- Project ID
- iOS Bundle ID

### Step 4: Configure Firestore Security Rules

In Firebase Console, set up Firestore Rules:

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

### Step 5: Install Dependencies

```bash
flutter pub get
```

## Backend Setup (Dart Frog)

### Step 1: Download Firebase Service Account Key

1. Go to Firebase Console > Project Settings > Service Accounts
2. Click "Generate New Private Key"
3. Save the JSON file securely

### Step 2: Set Environment Variables

Set the following environment variables for your backend:

```bash
# For local development
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json
export FIREBASE_DATABASE_URL=https://your-project-id.firebaseio.com

# For production (e.g., on Railway, Render, etc.)
# Set via your platform's environment variable configuration
```

### Step 3: Update Backend Dependencies

```bash
cd backend
dart pub get
```

### Step 4: Configure Firestore Collections

The backend will automatically initialize Firestore collections when first run. The structure is:

```
users/
  {userId}/
    tasks/
      {taskId}/
        - id: string
        - userId: string
        - title: string
        - isCompleted: boolean
        - scheduledTime: timestamp
        - createdAt: timestamp
    alarms/
      {alarmId}/
        - id: string
        - userId: string
        - time: timestamp
        - label: string
        - customAudioPath: string (optional)
        - isActive: boolean
        - repeat: string
        - repeatDays: array<int>
        - snoozeMinutes: int
        - vibrate: boolean
        - createdAt: timestamp
```

## Running the Application

### Frontend (Flutter)

```bash
# Development
flutter run

# Web
flutter run -d chrome

# Release build
flutter build apk  # Android
flutter build ipa  # iOS
flutter build web  # Web
```

### Backend (Dart Frog)

```bash
cd backend
dart_frog dev
```

The backend will start on `http://localhost:8080` by default.

## API Endpoints

### Tasks

**GET /tasks**
- Fetch all tasks for a user
- Query parameters: `userId` (optional, defaults to 'demo_user_123')
- Response: Array of task objects

**POST /tasks**
- Create a new task
- Body:
  ```json
  {
    "userId": "user_id",
    "title": "Task title",
    "isCompleted": false,
    "scheduledTime": "2024-05-22T10:00:00Z"
  }
  ```

## Frontend Usage

### Initialization

The app initializes Firebase in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set current user
  FirebaseService.setCurrentUserId('user_id_here');
  
  runApp(const PersonalSchedulerApp());
}
```

### Using FirebaseService

```dart
import 'core/services/firebase_service.dart';

// Get all tasks
final tasks = await FirebaseService.getAllTasks();

// Create a task
final newTask = TaskModel(
  id: 'unique_id',
  userId: 'user_id',
  title: 'My Task',
  scheduledTime: DateTime.now(),
);
final savedTask = await FirebaseService.saveTask(newTask);

// Update a task
newTask.isCompleted = true;
await FirebaseService.updateTask(newTask);

// Delete a task
await FirebaseService.deleteTask(taskId);

// Real-time updates
FirebaseService.tasksStream().listen((tasks) {
  // Update UI with new tasks
});
```

## Authentication (Optional)

To add user authentication, uncomment Firebase Auth usage in `main.dart` and add:

```dart
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup authentication listener
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      FirebaseService.setCurrentUserId(user.uid);
    }
  });
  
  runApp(const PersonalSchedulerApp());
}
```

## Deployment

### Frontend

- **Android**: Build and upload to Google Play Store
- **iOS**: Build and upload to Apple App Store
- **Web**: Deploy to Firebase Hosting or your preferred host

```bash
# Deploy web to Firebase Hosting
firebase deploy --only hosting
```

### Backend

Deploy to your preferred platform (Railway, Render, Google Cloud Run, etc.):

1. Ensure service account credentials are set as environment variables
2. Set `FIREBASE_DATABASE_URL` environment variable
3. Deploy the backend service

## Troubleshooting

### Firebase not initializing
- Verify `firebase_options.dart` has correct credentials
- Check that the Flutter app has internet permissions
- Ensure platform-specific configurations (Android: `google-services.json`, iOS: `GoogleService-Info.plist`)

### Firestore permission denied errors
- Check Firestore security rules
- Verify user is authenticated if authentication is required
- Ensure `userId` matches the authenticated user

### Backend connection errors
- Verify service account key file path
- Check environment variables are set correctly
- Ensure Firebase project ID matches configuration
- Check network connectivity to Firebase servers

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Dart Frog Documentation](https://dartfrog.vvv.dev)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
