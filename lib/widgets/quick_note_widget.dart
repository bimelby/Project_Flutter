import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foshmed/providers/auth_provider.dart';
import 'package:foshmed/providers/entry_provider.dart';
import 'package:foshmed/models/entry.dart';
import 'package:foshmed/utils/constants.dart';
import 'package:foshmed/widgets/glass_container.dart';
import 'package:foshmed/widgets/custom_button.dart';

class QuickNoteWidget extends StatefulWidget {
  final VoidCallback onSaved;

  const QuickNoteWidget({Key? key, required this.onSaved}) : super(key: key);

  @override
  _QuickNoteWidgetState createState() => _QuickNoteWidgetState();
}

class _QuickNoteWidgetState extends State<QuickNoteWidget> {
  final _contentController = TextEditingController();
  String _selectedMood = Constants.moodOptions.first;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveQuickNote() async {
    if (_contentController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    
    if (authProvider.user == null) return;
    
    final newEntry = Entry(
      id: '',
      userId: authProvider.user!.id,
      title: 'Quick Note',
      content: _contentController.text.trim(),
      mood: _selectedMood,
      category: 'Personal',
      date: DateTime.now(),
    );
    
    final success = await entryProvider.addEntry(
      newEntry,
      authProvider.user!.token,
      null,
    );
    
    if (success) {
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quick note saved!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        width: 350,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.note_add, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Quick Note',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
              autofocus: true,
            ),
            
            SizedBox(height: 16),
            
            Row(
              children: [
                Text(
                  'Mood: ',
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedMood,
                    dropdownColor: Colors.black87,
                    style: TextStyle(color: Colors.white),
                    underline: Container(),
                    items: Constants.moodOptions.map((mood) {
                      final emoji = Constants.moodEmojis[mood] ?? '😊';
                      return DropdownMenuItem(
                        value: mood,
                        child: Text('$emoji $mood'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMood = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Consumer<EntryProvider>(
                    builder: (context, entryProvider, child) {
                      return CustomButton(
                        text: 'Save',
                        isLoading: entryProvider.isLoading,
                        onPressed: _saveQuickNote,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
