// lib/screens/pomodoro_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/notify_service.dart';

class PomodoroScreen extends StatefulWidget {
  final VoidCallback onTimerComplete;
  const PomodoroScreen({super.key, required this.onTimerComplete});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int _workDuration = 25 * 60;
  int _secondsRemaining = _workDuration;
  Timer? _ticker;
  bool _isRunning = false;

  void _toggleTimer() {
    if (_isRunning) {
      _ticker?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _completeCycle();
        }
      });
    }
  }

  void _completeCycle() {
    _ticker?.cancel();
    widget.onTimerComplete();
    NotifyService.showInstantNotification(
      id: 99,
      title: 'Interval Complete!',
      body: 'Excellent focus block! Time to take a recovery break.',
    );
    setState(() {
      _secondsRemaining = _workDuration;
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _ticker?.cancel();
    setState(() {
      _secondsRemaining = _workDuration;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Engine')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$minutes:$seconds', style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w200, fontFamily: 'monospace')),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                iconSize: 32,
                icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                onPressed: _toggleTimer,
              ),
              const SizedBox(width: 20),
              IconButton.outlined(
                iconSize: 32,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _resetTimer,
              ),
            ],
          )
        ],
      ),
    );
  }
}