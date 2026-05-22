// lib/models/alarm_model.dart

enum RepeatFrequency { none, daily, weekdays, weekly, custom }

class AlarmModel {
  final String id;
  final String userId;
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
    required this.userId,
    required this.time,
    required this.label,
    this.customAudioPath,
    this.isActive = true,
    this.repeat = RepeatFrequency.none,
    this.repeatDays = const [],
    this.snoozeMinutes = 5,
    this.vibrate = true,
  });

  // Convert AlarmModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'time': time.toIso8601String(),
      'label': label,
      'customAudioPath': customAudioPath,
      'isActive': isActive,
      'repeat': repeat.toString(),
      'repeatDays': repeatDays,
      'snoozeMinutes': snoozeMinutes,
      'vibrate': vibrate,
    };
  }

  // Create AlarmModel from JSON (Firestore document)
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      time: json['time'] != null
          ? DateTime.parse(json['time'] as String)
          : DateTime.now(),
      label: json['label'] as String? ?? '',
      customAudioPath: json['customAudioPath'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      repeat: _parseRepeatFrequency(json['repeat']),
      repeatDays: (json['repeatDays'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      snoozeMinutes: (json['snoozeMinutes'] as num?)?.toInt() ?? 5,
      vibrate: json['vibrate'] as bool? ?? true,
    );
  }

  // Helper to parse RepeatFrequency from string
  static RepeatFrequency _parseRepeatFrequency(dynamic value) {
    if (value is String) {
      return RepeatFrequency.values.firstWhere(
        (e) => e.toString() == value,
        orElse: () => RepeatFrequency.none,
      );
    }
    return RepeatFrequency.none;
  }
}