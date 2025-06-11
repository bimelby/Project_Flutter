import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foshmed/providers/reminder_provider.dart';
import 'package:foshmed/models/reminder.dart';
import 'package:foshmed/widgets/glass_container.dart';
import 'package:foshmed/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now().add(Duration(hours: 1));
  String _selectedType = 'custom';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _addReminder() async {
    if (_titleController.text.isEmpty) return;

    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      entryId: '',
      title: _titleController.text,
      description: _descriptionController.text,
      dateTime: _selectedDateTime,
      isActive: true,
      type: _selectedType,
    );

    final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
    await reminderProvider.addReminder(reminder);

    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDateTime = DateTime.now().add(Duration(hours: 1));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Reminders',
          style: TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/reminder_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Add Reminder Form
              GlassContainer(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Reminder',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    
                    SizedBox(height: 16),
                    
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      style: TextStyle(color: Colors.white),
                      maxLines: 2,
                    ),
                    
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: InputDecoration(
                              labelText: 'Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            dropdownColor: Colors.black87,
                            style: TextStyle(color: Colors.white),
                            items: [
                              DropdownMenuItem(value: 'custom', child: Text('Custom')),
                              DropdownMenuItem(value: 'entry', child: Text('Entry Deadline')),
                              DropdownMenuItem(value: 'break', child: Text('Break Reminder')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.access_time, color: Colors.white),
                            label: Text(
                              DateFormat('MMM d, HH:mm').format(_selectedDateTime),
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: _selectDateTime,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    CustomButton(
                      text: 'Add Reminder',
                      onPressed: _addReminder,
                    ),
                  ],
                ),
              ),
              
              // Reminders List
              Expanded(
                child: Consumer<ReminderProvider>(
                  builder: (context, reminderProvider, child) {
                    final reminders = reminderProvider.reminders;
                    
                    if (reminders.isEmpty) {
                      return Center(
                        child: GlassContainer(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.alarm_off,
                                size: 48,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No reminders yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminders[index];
                        final isOverdue = reminder.dateTime.isBefore(DateTime.now());
                        
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: GlassContainer(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: isOverdue ? Colors.red : Colors.orange,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reminder.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (reminder.description.isNotEmpty) ...[
                                        SizedBox(height: 4),
                                        Text(
                                          reminder.description,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                      SizedBox(height: 4),
                                      Text(
                                        DateFormat('MMM d, yyyy • HH:mm').format(reminder.dateTime),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await reminderProvider.deleteReminder(reminder.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
