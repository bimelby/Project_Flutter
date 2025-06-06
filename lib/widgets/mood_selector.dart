import 'package:flutter/material.dart';
import 'package:foshmed/utils/constants.dart';

class MoodSelector extends StatelessWidget {
  final String selectedMood;
  final Function(String) onMoodSelected;

  const MoodSelector({
    Key? key,
    required this.selectedMood,
    required this.onMoodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: Constants.moodOptions.map((mood) {
        final isSelected = mood == selectedMood;
        final emoji = Constants.moodEmojis[mood] ?? '😊';
        final color = Constants.moodColors[mood] ?? Colors.blue;
        
        return GestureDetector(
          onTap: () => onMoodSelected(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.3) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? color : Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  mood,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
