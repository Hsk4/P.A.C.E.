import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../core/services/firebase_service.dart';

class TaskScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  // Note: onStateChanged is maintained for backwards compatibility but task updates
  // are now handled directly via FirebaseService in task_screen.dart
  final VoidCallback onStateChanged;
  final ValueChanged<TaskModel> onAddTask;

  const TaskScreen({
	super.key,
	required this.tasks,
	required this.onStateChanged,
	required this.onAddTask,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
  return Scaffold(
	appBar: AppBar(title: const Text('Tasks')),
	body: widget.tasks.isEmpty
	  ? const Center(child: Text('No tasks yet'))
	  : ListView.builder(
	  itemCount: widget.tasks.length,
	  itemBuilder: (context, index) {
		final task = widget.tasks[index];
		return CheckboxListTile(
		value: task.isCompleted,
		title: Text(task.title),
		subtitle: Text('${task.scheduledTime.toLocal()}'),
		onChanged: (v) async {
		  task.isCompleted = v ?? false;
		  // Update the task in Firebase
		  await FirebaseService.updateTask(task);
		  setState(() {});
		},
		);
	  },
	),
	floatingActionButton: FloatingActionButton(
	child: const Icon(Icons.add),
	onPressed: () => _showAddTaskSheet(context),
	),
  );
  }

  void _showAddTaskSheet(BuildContext context) {
	String title = '';
	DateTime? scheduled;

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
				  const Text('Add Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
				  const SizedBox(height: 8),
				  TextField(
					decoration: const InputDecoration(labelText: 'Title'),
					onChanged: (v) => title = v,
				  ),
				  const SizedBox(height: 8),
				  Row(
					children: [
					  Expanded(
						child: Text(scheduled == null ? 'No time selected' : scheduled!.toLocal().toString()),
					  ),
					  TextButton(
						child: const Text('Pick Date & Time'),
						onPressed: () async {
						  final date = await showDatePicker(
							context: ctx,
							initialDate: DateTime.now(),
							firstDate: DateTime.now().subtract(const Duration(days: 365)),
							lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
						  );
						  if (date == null) return;
						  // ignore: use_build_context_synchronously
						  final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
						  if (time == null) return;
						  setState(() {
							scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
						  });
						},
					  ),
					],
				  ),
				  const SizedBox(height: 12),
				  ElevatedButton(
					child: const Text('Add Task'),
					onPressed: () {
					  if (title.trim().isEmpty) {
						ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
						return;
					  }
					  final task = TaskModel(
						id: DateTime.now().microsecondsSinceEpoch.toString(),
						userId: FirebaseService.getCurrentUserId() ?? '',
						title: title.trim(),
						scheduledTime: scheduled ?? DateTime.now(),
					  );
					  widget.onAddTask(task);
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

