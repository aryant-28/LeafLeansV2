import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/plant_reminder.dart';
import '../services/scheduled_notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final List<PlantReminder> reminders = [];
  final ScheduledNotificationService _notifier = ScheduledNotificationService();

  @override
  void initState() {
    super.initState();
    _notifier.initialize();
  }

  void _addReminder() async {
    final newReminder = await _showReminderDialog();
    if (newReminder != null) {
      setState(() {
        reminders.add(newReminder);
      });
      if (newReminder.isEnabled) {
        await _notifier.scheduleReminder(newReminder);
      }
    }
  }

  void _toggleReminder(PlantReminder reminder) {
      setState(() {
      reminder.isEnabled = !reminder.isEnabled;
    });
    if (reminder.isEnabled) {
      _notifier.scheduleReminder(reminder);
    } else {
      _notifier.cancelReminder(reminder.id);
    }
  }

  void _deleteReminder(PlantReminder reminder) async {
    setState(() {
      reminders.remove(reminder);
    });
    await _notifier.cancelReminder(reminder.id);
  }

  Future<PlantReminder?> _showReminderDialog({PlantReminder? existing}) async {
    final plantController = TextEditingController(text: existing?.plantName);
    final notesController = TextEditingController(text: existing?.notes);
    TimeOfDay selectedTime = existing?.time ?? TimeOfDay.now();

    return await showDialog<PlantReminder>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Reminder' : 'Edit Reminder'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: plantController,
                  decoration: const InputDecoration(labelText: 'Plant Name'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                ),
                const SizedBox(height: 10),
                Text("Time: ${selectedTime.format(context)}"),
                TextButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: const Text("Pick Time"),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
    setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (plantController.text.trim().isEmpty) return;
                final reminder = PlantReminder(
                  id: existing?.id ?? const Uuid().v4(),
                  plantName: plantController.text.trim(),
                  time: selectedTime,
                  notes: notesController.text.trim(),
                  isEnabled: existing?.isEnabled ?? true,
                );
                Navigator.pop(context, reminder);
              },
              child: Text(existing == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plant Care Reminders')),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Icon(
                Icons.notifications,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(reminder.plantName),
              subtitle: Text(
                  'Time: ${reminder.time.format(context)}\nNotes: ${reminder.notes.isNotEmpty ? reminder.notes : 'None'}'),
              trailing: Switch(
                    value: reminder.isEnabled,
                onChanged: (value) => _toggleReminder(reminder),
              ),
              onTap: () => _editReminder(reminder),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editReminder(PlantReminder reminder) {
    // TODO: Implement reminder editing
  }
}
