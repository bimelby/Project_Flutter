import 'package:flutter/material.dart';
import 'package:foshmed/models/entry.dart';
import 'package:foshmed/utils/constants.dart';
import 'package:foshmed/widgets/glass_container.dart';

class MoodChart extends StatefulWidget {
  final List<Entry> entries;
  final int daysToShow;

  const MoodChart({
    Key? key,
    required this.entries,
    this.daysToShow = 7,
  }) : super(key: key);

  @override
  _MoodChartState createState() => _MoodChartState();
}

class _MoodChartState extends State<MoodChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, int> _getMoodCounts() {
    final moodCounts = <String, int>{};
    
    for (var entry in widget.entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }
    
    return moodCounts;
  }

  @override
  Widget build(BuildContext context) {
    final moodCounts = _getMoodCounts();
    final totalEntries = widget.entries.length;
    
    if (totalEntries == 0) {
      return GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.mood,
              size: 48,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No mood data yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start writing entries to see your mood patterns',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                children: moodCounts.entries.map((entry) {
                  final mood = entry.key;
                  final count = entry.value;
                  final percentage = count / totalEntries;
                  final emoji = Constants.moodEmojis[mood] ?? '😊';
                  final color = Constants.moodColors[mood] ?? Colors.blue;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              emoji,
                              style: TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mood,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(percentage * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percentage * _animation.value,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
