import 'package:flutter/material.dart';
import '../models/task_model.dart';
class DashboardScreen extends StatelessWidget {
  final List<TaskModel> tasks;
  final int completedPomodoros;
  const DashboardScreen({super.key, required this.tasks, required this.completedPomodoros});

  @override
  Widget build(BuildContext context) {
    final int totalTasks = tasks.length;
    final int completedTasks = tasks.where((task) => task.isCompleted).length;
    final double completionRate = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Overview'), centerTitle: true,),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Column(

                  children: [
                    const Text ('Daily Performance'),
                    const SizedBox(height: 15),
                    LinearProgressIndicator(
                      value: completionRate,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 10),
                    Text(' $completedTasks of $totalTasks tasks cleared (${(completionRate * 100).toStringAsFixed(1)}%)'),

                  ],
                ),
              ),

              const SizedBox(width: 15,),

              Row(
                children: [
                  Expanded(child: _MetricCard(title: 'Completed Pomodoros', value: completedPomodoros.toString())),

                  const SizedBox(width: 15,),

                  Expanded(child: _MetricCard(title: 'Pending Tasks', value: (totalTasks - completedTasks).toString())),

                ],
              )
            ],
          )
      ),
    );
  }

}


class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon ;
  final Color color;

  const _MetricCard({super.key, required this.title, required this.value, this.icon = Icons.check_circle_outline, this.color = Colors.green});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          )


      ),
    );
  }
}
