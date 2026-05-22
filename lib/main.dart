// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/notify_service.dart';
import 'core/services/firebase_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/alarm_screen.dart';
import 'screens/task_screen.dart';
import 'models/task_model.dart';
import 'models/alarm_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notification service
  await NotifyService.init();
  
  // Set a demo user ID for Firebase (in production, use actual authentication)
  FirebaseService.setCurrentUserId('demo_user_123');
  
  runApp(const PersonalSchedulerApp());
}

class PersonalSchedulerApp extends StatelessWidget {
  const PersonalSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Space',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
          surface: const Color(0xFF121214),
        ),
      ),
      home: const ShellNavigationLayout(),
    );
  }
}

class ShellNavigationLayout extends StatefulWidget {
  const ShellNavigationLayout({super.key});

  @override
  State<ShellNavigationLayout> createState() => _ShellNavigationLayoutState();
}

class _ShellNavigationLayoutState extends State<ShellNavigationLayout> {
  int _currentIndex = 0;
  int _completedPomodoros = 0;

  @override
  Widget build(BuildContext context) {
    // Build screens with Firebase streams for real-time updates
    final List<Widget> screens = [
      // Dashboard with task stream
      StreamBuilder<List<TaskModel>>(
        stream: FirebaseService.tasksStream(),
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? [];
          return DashboardScreen(
            tasks: tasks,
            completedPomodoros: _completedPomodoros,
          );
        },
      ),
      // Pomodoro screen
      PomodoroScreen(
        onTimerComplete: () {
          setState(() {
            _completedPomodoros++;
          });
          // Optional: Save pomodoro stats to Firebase
          // await FirebaseService.savePomodoroStat(_completedPomodoros);
        },
      ),
      // Alarms with stream
      StreamBuilder<List<AlarmModel>>(
        stream: FirebaseService.alarmsStream(),
        builder: (context, snapshot) {
          final alarms = snapshot.data ?? [];
          return AlarmScreen(
            alarms: alarms,
            onAddAlarm: (alarm) async {
              // Add userId to alarm before saving
              final alarmWithUser = AlarmModel(
                id: alarm.id,
                userId: FirebaseService.getCurrentUserId() ?? '',
                time: alarm.time,
                label: alarm.label,
                customAudioPath: alarm.customAudioPath,
                isActive: alarm.isActive,
                repeat: alarm.repeat,
                repeatDays: alarm.repeatDays,
                snoozeMinutes: alarm.snoozeMinutes,
                vibrate: alarm.vibrate,
              );
              final saved = await FirebaseService.saveAlarm(alarmWithUser);
              if (saved == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to save alarm')),
                  );
                }
              }
            },
            onToggleAlarm: (alarm) async {
              // Update alarm toggle state in Firebase
              await FirebaseService.updateAlarm(alarm);
            },
          );
        },
      ),
      // Tasks with stream
      StreamBuilder<List<TaskModel>>(
        stream: FirebaseService.tasksStream(),
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? [];
          return TaskScreen(
            tasks: tasks,
            onStateChanged: () async {
              // Find the modified task in the UI and update only that one
              // The tasks stream will automatically reflect changes
            },
            onAddTask: (task) async {
              // Add userId to task before saving
              final taskWithUser = TaskModel(
                id: task.id,
                userId: FirebaseService.getCurrentUserId() ?? '',
                title: task.title,
                isCompleted: task.isCompleted,
                scheduledTime: task.scheduledTime,
              );
              final saved = await FirebaseService.saveTask(taskWithUser);
              if (saved == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to save task')),
                  );
                }
              }
            },
          );
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Status'),
          NavigationDestination(icon: Icon(Icons.timer_10_rounded), label: 'Focus'),
          NavigationDestination(icon: Icon(Icons.alarm_rounded), label: 'Alarms'),
          NavigationDestination(icon: Icon(Icons.task_alt_rounded), label: 'Tasks'),
        ],
      ),
    );
  }
}