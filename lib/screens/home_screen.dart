import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foshmed/providers/auth_provider.dart';
import 'package:foshmed/providers/entry_provider.dart';
import 'package:foshmed/providers/theme_provider.dart';
import 'package:foshmed/providers/reminder_provider.dart';
import 'package:foshmed/screens/entry/add_entry_screen.dart';
import 'package:foshmed/screens/entry/entry_detail_screen.dart';
import 'package:foshmed/screens/profile_screen.dart';
import 'package:foshmed/screens/search_screen.dart';
import 'package:foshmed/screens/calendar_screen.dart';
import 'package:foshmed/screens/reminder_screen.dart';
import 'package:foshmed/screens/template_screen.dart';
import 'package:foshmed/widgets/entry_card.dart';
import 'package:foshmed/widgets/glass_container.dart';
import 'package:foshmed/widgets/quick_note_widget.dart';
import 'package:foshmed/utils/constants.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = '';
  bool _isLoading = true;
  bool _showQuickNote = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: Constants.categoryOptions.length + 1, vsync: this);
    _loadEntries();
    /*_initializeReminders();*/
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);

    if (authProvider.user != null) {
      await entryProvider.fetchEntries(
        authProvider.user!.id,
        authProvider.user!.token,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  /*Future<void> _initializeReminders() async {
    final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
    await reminderProvider.initialize();
    
    // Schedule break reminder
    await reminderProvider.scheduleBreakReminder();
  }*/

  Future<void> _refreshEntries() async {
    await _loadEntries();
  }

  void _showQuickNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => QuickNoteWidget(
        onSaved: () {
          Navigator.pop(context);
          _refreshEntries();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final entryProvider = Provider.of<EntryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final filteredEntries = _selectedCategory.isEmpty
        ? entryProvider.entries
        : entryProvider.entries
            .where((entry) => entry.category == _selectedCategory)
            .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Foshmed',
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReminderScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            height: 50,
            child: GlassContainer(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                tabs: [
                  Tab(text: 'All'),
                  ...Constants.categoryOptions
                      .map((category) => Tab(text: category)),
                ],
                onTap: (index) {
                  setState(() {
                    _selectedCategory =
                        index == 0 ? '' : Constants.categoryOptions[index - 1];
                  });
                },
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              themeProvider.isDarkMode
                  ? 'assets/images/dark_background.jpg'
                  : 'assets/images/light_background.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshEntries,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : filteredEntries.isEmpty
                  ? Center(
                      child: GlassContainer(
                        width: 300,
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.book,
                              size: 60,
                              color: Colors.white,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No entries yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start writing your first diary entry',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: Icon(Icons.add),
                                    label: Text('Add Entry'),
                                    onPressed: () async {
                                      final result =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => AddEntryScreen(),
                                        ),
                                      );
                                      if (result == true) {
                                        _refreshEntries();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: Icon(Icons.description),
                                    label: Text('Templates'),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => TemplateScreen()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(
                          top: 130, bottom: 100, left: 16, right: 16),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];

                        // Group entries by date
                        final bool showDateHeader = index == 0 ||
                            DateFormat('yyyy-MM-dd')
                                    .format(filteredEntries[index].date) !=
                                DateFormat('yyyy-MM-dd')
                                    .format(filteredEntries[index - 1].date);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateHeader) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, bottom: 8, left: 8),
                                child: Text(
                                  DateFormat('EEEE, MMMM d, yyyy')
                                      .format(entry.date),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
                              ),
                            ],
                            EntryCard(
                              entry: entry,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EntryDetailScreen(entry: entry),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "quick_note",
            mini: true,
            onPressed: _showQuickNoteDialog,
            backgroundColor: Colors.purple,
            child: Icon(Icons.note_add),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "add_entry",
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddEntryScreen()),
              );
              if (result == true) {
                _refreshEntries();
              }
            },
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
