// lib/main.dart
import 'package:flutter/material.dart';
import 'core/services/notify_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/alarm_screen.dart';
import 'screens/task_screen.dart';
import 'models/task_model.dart';
import 'models/alarm_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotifyService.init();
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

  // Shared application state pipelines
  final List<TaskModel> _globalTasks = [];
  final List<AlarmModel> _globalAlarms = [];
  int _completedPomodoros = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(tasks: _globalTasks, completedPomodoros: _completedPomodoros),
      PomodoroScreen(onTimerComplete: () {
        setState(() {
          _completedPomodoros++;
        });
      }),
      AlarmScreen(
        alarms: _globalAlarms,
        onAddAlarm: (alarm) => setState(() => _globalAlarms.add(alarm)),
        onToggleAlarm: (alarm) => setState(() {}),
      ),
      TaskScreen(
        tasks: _globalTasks,
        onStateChanged: () => setState(() {}),
        onAddTask: (task) => setState(() => _globalTasks.add(task)),
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