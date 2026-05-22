// lib/models/alarm_model.dart

enum RepeatFrequency { none, daily, weekdays, weekly, custom }

class AlarmModel {
  final String id;
  final DateTime time;
  final String label;
  final String? customAudioPath;
  bool isActive;

  // Repeat configuration: which days (1 = Monday .. 7 = Sunday) when repeating weekly/custom
  final RepeatFrequency repeat;
  final List<int> repeatDays;

  // Snooze in minutes (0 = disabled)
  final int snoozeMinutes;

  // Whether to vibrate when firing
  final bool vibrate;

  AlarmModel({
    required this.id,
    required this.time,
    required this.label,
    this.customAudioPath,
    this.isActive = true,
    this.repeat = RepeatFrequency.none,
    this.repeatDays = const [],
    this.snoozeMinutes = 5,
    this.vibrate = true,
  });
}