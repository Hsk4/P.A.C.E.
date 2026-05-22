// lib/screens/alarm_screen.dart
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../core/services/firebase_service.dart';

class AlarmScreen extends StatefulWidget {
  final List<AlarmModel> alarms;
  final ValueChanged<AlarmModel> onAddAlarm;
  final ValueChanged<AlarmModel> onToggleAlarm;

  const AlarmScreen({
    super.key,
    required this.alarms,
    required this.onAddAlarm,
    required this.onToggleAlarm,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _repeatSummary(AlarmModel alarm) {
    switch (alarm.repeat) {
      case RepeatFrequency.none:
        return 'No repeat';
      case RepeatFrequency.daily:
        return 'Repeats daily';
      case RepeatFrequency.weekdays:
        return 'Mon–Fri';
      case RepeatFrequency.weekly:
      case RepeatFrequency.custom:
        if (alarm.repeatDays.isEmpty) return 'Repeats weekly';
        final names = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
        return alarm.repeatDays.map((d) => names[(d-1) % 7]).join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarms')),
      body: widget.alarms.isEmpty
          ? const Center(child: Text('No alarms set'))
          : ListView.builder(
              itemCount: widget.alarms.length,
              itemBuilder: (context, index) {
                final alarm = widget.alarms[index];
                return ListTile(
                  leading: Icon(alarm.isActive ? Icons.alarm_on_rounded : Icons.alarm_off_rounded),
                  title: Text(alarm.label),
                  subtitle: Text('${_formatTime(alarm.time)} • ${_repeatSummary(alarm)}'),
                  trailing: Switch(
                    value: alarm.isActive,
                    onChanged: (v) async {
                      alarm.isActive = v;
                      // Update alarm in Firebase
                      await FirebaseService.updateAlarm(alarm);
                      setState(() {});
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.alarm_add),
        onPressed: () => _showAddAlarmSheet(context),
      ),
    );
  }

  void _showAddAlarmSheet(BuildContext context) {
    TimeOfDay? pickedTime;
    String label = '';
    RepeatFrequency repeat = RepeatFrequency.none;
    List<int> repeatDays = [];
    int snooze = 5;
    bool vibrate = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Add Alarm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Label'),
                    onChanged: (v) => label = v,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(pickedTime == null ? 'No time selected' : pickedTime!.format(ctx)),
                      ),
                      TextButton(
                        child: const Text('Pick Time'),
                        onPressed: () async {
                          final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                          if (t == null) return;
                          setState(() => pickedTime = t);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Repeat options
                  Row(
                    children: [
                      const Text('Repeat:'),
                      const SizedBox(width: 12),
                      DropdownButton<RepeatFrequency>(
                        value: repeat,
                        items: const [
                          DropdownMenuItem(value: RepeatFrequency.none, child: Text('None')),
                          DropdownMenuItem(value: RepeatFrequency.daily, child: Text('Daily')),
                          DropdownMenuItem(value: RepeatFrequency.weekdays, child: Text('Weekdays')),
                          DropdownMenuItem(value: RepeatFrequency.weekly, child: Text('Weekly')),
                          DropdownMenuItem(value: RepeatFrequency.custom, child: Text('Custom')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            repeat = v;
                            if (v == RepeatFrequency.weekdays) {
                              repeatDays = [1,2,3,4,5];
                            } else if (v == RepeatFrequency.daily) {
                              repeatDays = [];
                            } else if (v == RepeatFrequency.weekly) {
                              // Default to the selected weekday
                              final today = DateTime.now().weekday;
                              repeatDays = [today];
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (repeat == RepeatFrequency.weekly || repeat == RepeatFrequency.custom || repeat == RepeatFrequency.weekdays)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Wrap(
                        spacing: 6,
                        children: List.generate(7, (i) {
                          final day = i + 1; // 1..7
                          final names = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
                          final selected = repeatDays.contains(day);
                          return ChoiceChip(
                            label: Text(names[i]),
                            selected: selected,
                            onSelected: (s) {
                              setState(() {
                                if (s) {
                                  if (!repeatDays.contains(day)) repeatDays.add(day);
                                } else {
                                  repeatDays.remove(day);
                                }
                              });
                            },
                          );
                        }),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Snooze and vibrate
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Snooze (minutes)'),
                          onChanged: (v) => snooze = int.tryParse(v) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          const Text('Vibrate'),
                          Switch(
                            value: vibrate,
                            onChanged: (v) => setState(() => vibrate = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    child: const Text('Add Alarm'),
                    onPressed: () {
                      if (pickedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a time')));
                        return;
                      }
                      final now = DateTime.now();
                      final alarmDateTime = DateTime(now.year, now.month, now.day, pickedTime!.hour, pickedTime!.minute);
                      final alarm = AlarmModel(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        userId: FirebaseService.getCurrentUserId() ?? '',
                        time: alarmDateTime,
                        label: label.trim().isEmpty ? 'Alarm' : label.trim(),
                        repeat: repeat,
                        repeatDays: repeatDays,
                        snoozeMinutes: snooze,
                        vibrate: vibrate,
                      );
                      widget.onAddAlarm(alarm);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}