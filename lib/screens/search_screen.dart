import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foshmed/providers/entry_provider.dart';
import 'package:foshmed/models/entry.dart';
import 'package:foshmed/utils/constants.dart';
import 'package:foshmed/widgets/glass_container.dart';
import 'package:foshmed/widgets/entry_card.dart';
import 'package:foshmed/screens/entry/entry_detail_screen.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _filterController;
  late AnimationController _resultsController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _filterAnimation;
  late Animation<double> _resultsAnimation;

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedMood = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _showFilters = false;
  List<Entry> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _resultsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize animations
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _filterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterController,
      curve: Curves.easeOutBack,
    ));

    _resultsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultsController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();

    // Initialize search results with all entries
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _filterController.dispose();
    _resultsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      _isSearching = true;
    });

    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    
    // Simulate search delay for better UX
    Future.delayed(const Duration(milliseconds: 300), () {
      final results = entryProvider.filterEntries(
        query: _searchQuery.isEmpty ? null : _searchQuery,
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
        mood: _selectedMood.isEmpty ? null : _selectedMood,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      _resultsController.reset();
      _resultsController.forward();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = '';
      _selectedMood = '';
      _fromDate = null;
      _toDate = null;
    });
    _performSearch();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
    
    if (_showFilters) {
      _filterController.forward();
    } else {
      _filterController.reverse();
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.black87,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _performSearch();
    }
  }

  Widget _buildSearchBar() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search your diary...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.white70),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                  _performSearch();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        // Debounce search
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_searchQuery == value) {
                            _performSearch();
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      icon: Icon(
                        Icons.tune,
                        color: _showFilters ? Theme.of(context).primaryColor : Colors.white,
                      ),
                      onPressed: _toggleFilters,
                      style: IconButton.styleFrom(
                        backgroundColor: _showFilters 
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Active filters indicator
              if (_selectedCategory.isNotEmpty || 
                  _selectedMood.isNotEmpty || 
                  _fromDate != null || 
                  _toDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (_selectedCategory.isNotEmpty)
                            _buildFilterChip('Category: $_selectedCategory'),
                          if (_selectedMood.isNotEmpty)
                            _buildFilterChip('Mood: $_selectedMood'),
                          if (_fromDate != null && _toDate != null)
                            _buildFilterChip(
                              '${DateFormat('MMM d').format(_fromDate!)} - ${DateFormat('MMM d').format(_toDate!)}',
                            ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: _showFilters ? null : 0,
      child: _showFilters
          ? SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(_filterController),
              child: FadeTransition(
                opacity: _filterAnimation,
                child: GlassContainer(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Category filter
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterOption(
                            'All Categories',
                            _selectedCategory.isEmpty,
                            () {
                              setState(() {
                                _selectedCategory = '';
                              });
                              _performSearch();
                            },
                          ),
                          ...Constants.categoryOptions.map((category) {
                            return _buildFilterOption(
                              category,
                              _selectedCategory == category,
                              () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                _performSearch();
                              },
                            );
                          }).toList(),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Mood filter
                      Text(
                        'Mood',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterOption(
                            'All Moods',
                            _selectedMood.isEmpty,
                            () {
                              setState(() {
                                _selectedMood = '';
                              });
                              _performSearch();
                            },
                          ),
                          ...Constants.moodOptions.map((mood) {
                            final emoji = Constants.moodEmojis[mood] ?? '😊';
                            return _buildFilterOption(
                              '$emoji $mood',
                              _selectedMood == mood,
                              () {
                                setState(() {
                                  _selectedMood = mood;
                                });
                                _performSearch();
                              },
                            );
                          }).toList(),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Date range filter
                      Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.date_range, color: Colors.white),
                              label: Text(
                                _fromDate != null && _toDate != null
                                    ? '${DateFormat('MMM d').format(_fromDate!)} - ${DateFormat('MMM d').format(_toDate!)}'
                                    : 'Select Date Range',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: _selectDateRange,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_fromDate != null && _toDate != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _fromDate = null;
                                  _toDate = null;
                                });
                                _performSearch();
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: _resultsAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Results header
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isSearching 
                        ? 'Searching...'
                        : '${_searchResults.length} ${_searchResults.length == 1 ? 'entry' : 'entries'} found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (_isSearching) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results list
            if (_isSearching)
              _buildLoadingResults()
            else if (_searchResults.isEmpty)
              _buildEmptyResults()
            else
              _buildResultsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingResults() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyResults() {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No entries found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search terms or filters'
                : 'Start writing your first diary entry',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_selectedCategory.isNotEmpty || 
              _selectedMood.isNotEmpty || 
              _fromDate != null || 
              _toDate != null)
            OutlinedButton(
              onPressed: _clearFilters,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Clear Filters',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      children: _searchResults.asMap().entries.map((entry) {
        final index = entry.key;
        final entryData = entry.value;
        
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 100)),
          curve: Curves.easeOutCubic,
          child: EntryCard(
            entry: entryData,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EntryDetailScreen(entry: entryData),
                ),
              );
            },
          ),
        );
      }).toList(),
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
          'Search',
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
            image: AssetImage('assets/images/search_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search bar and filters
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    _buildFilters(),
                  ],
                ),
              ),
              
              // Search results
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSearchResults(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
