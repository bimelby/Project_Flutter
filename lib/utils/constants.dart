import 'package:flutter/material.dart';

class Constants {

  static const String apiUrl = 'http://172.16.203.5/foshmed/api';
  
  static const List<String> moodOptions = [
    'Happy',
    'Sad',
    'Angry',
    'Excited',
    'Tired',
    'Calm',
    'Anxious',
    'Grateful',
    'Confused',
    'Motivated',
    'Peaceful',
    'Stressed',
  ];
  
  static const List<String> categoryOptions = [
    'Personal',
    'Work',
    'Family',
    'Travel',
    'Health',
    'Education',
    'Finance',
    'Relationships',
    'Hobbies',
    'Goals',
    'Reflection',
    'Other',
  ];
  
  static const Map<String, String> moodEmojis = {
    'Happy': '😊',
    'Sad': '😢',
    'Angry': '😠',
    'Excited': '😃',
    'Tired': '😴',
    'Calm': '😌',
    'Anxious': '😰',
    'Grateful': '🙏',
    'Confused': '😕',
    'Motivated': '💪',
    'Peaceful': '☮️',
    'Stressed': '😫',
  };
  
  static const Map<String, Color> moodColors = {
    'Happy': Color(0xFF4CAF50),
    'Sad': Color(0xFF2196F3),
    'Angry': Color(0xFFF44336),
    'Excited': Color(0xFFFF9800),
    'Tired': Color(0xFF9E9E9E),
    'Calm': Color(0xFF3F51B5),
    'Anxious': Color(0xFFFF5722),
    'Grateful': Color(0xFF9C27B0),
    'Confused': Color(0xFF795548),
    'Motivated': Color(0xFF00BCD4),
    'Peaceful': Color(0xFF8BC34A),
    'Stressed': Color(0xFFE91E63),
  };
}
