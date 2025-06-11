class Reminder {
  final String id;
  final String entryId;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isActive;
  final String type; // 'entry', 'break', 'custom'

  Reminder({
    required this.id,
    required this.entryId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.isActive,
    required this.type,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'].toString(),
      entryId: json['entry_id']?.toString() ?? '',
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['date_time']),
      isActive: json['is_active'] == 1,
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entry_id': entryId,
      'title': title,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'type': type,
    };
  }
}
