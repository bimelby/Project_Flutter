class NoteTemplate {
  final String id;
  final String name;
  final String content;
  final String category;
  final String icon;
  final String description;
  final bool isDefault;

  NoteTemplate({
    required this.id,
    required this.name,
    required this.content,
    required this.category,
    required this.icon,
    required this.description,
    this.isDefault = true,
  });

  factory NoteTemplate.fromJson(Map<String, dynamic> json) {
    return NoteTemplate(
      id: json['id'].toString(),
      name: json['name'],
      content: json['content'],
      category: json['category'],
      icon: json['icon'],
      description: json['description'] ?? '',
      isDefault: json['is_default'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'category': category,
      'icon': icon,
      'description': description,
      'is_default': isDefault ? 1 : 0,
    };
  }

  static List<NoteTemplate> getDefaultTemplates() {
    return [
      NoteTemplate(
        id: '1',
        name: 'To-Do List',
        content: '📝 Today\'s Tasks:\n\n☐ \n☐ \n☐ \n\n✅ Completed:\n\n',
        category: 'Work',
        icon: '📝',
        description: 'A template for creating a to-do list.',
      ),
      NoteTemplate(
        id: '2',
        name: 'Meeting Notes',
        content: '📅 Meeting: \n🕐 Date: \n👥 Attendees: \n\n📋 Agenda:\n- \n- \n\n📝 Notes:\n\n\n✅ Action Items:\n- \n- \n',
        category: 'Work',
        icon: '📅',
        description: 'A template for taking notes during a meeting.',
      ),
      NoteTemplate(
        id: '3',
        name: 'Daily Journal',
        content: '🌅 Today\'s Date: \n\n😊 Mood: \n\n🌟 Highlights:\n- \n- \n\n💭 Thoughts:\n\n\n🙏 Grateful for:\n- \n- \n',
        category: 'Personal',
        icon: '📖',
        description: 'A template for keeping a daily journal.',
      ),
      NoteTemplate(
        id: '4',
        name: 'Gratitude Journal',
        content: '🙏 Gratitude Journal\n\n📅 Date: \n\n✨ Three things I\'m grateful for today:\n1. \n2. \n3. \n\n💝 Why I\'m grateful:\n\n\n🌟 Positive moment of the day:\n\n',
        category: 'Personal',
        icon: '🙏',
        description: 'A template for keeping a gratitude journal.',
      ),
      NoteTemplate(
        id: '5',
        name: 'Travel Log',
        content: '✈️ Travel Log\n\n📍 Location: \n📅 Date: \n🌤️ Weather: \n\n🏛️ Places Visited:\n- \n- \n\n📸 Memories:\n\n\n🍽️ Food Tried:\n- \n- \n\n💰 Expenses:\n\n',
        category: 'Travel',
        icon: '✈️',
        description: 'A template for keeping a travel log.',
      ),
    ];
  }
}
