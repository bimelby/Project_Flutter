import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:foshmed/providers/auth_provider.dart';
import 'package:foshmed/providers/entry_provider.dart';
import 'package:foshmed/models/entry.dart';
import 'package:foshmed/utils/constants.dart';
import 'package:foshmed/widgets/glass_container.dart';
import 'package:foshmed/widgets/custom_button.dart';
import 'package:foshmed/widgets/mood_selector.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EntryDetailScreen extends StatefulWidget {
  final Entry entry;

  const EntryDetailScreen({Key? key, required this.entry}) : super(key: key);

  @override
  _EntryDetailScreenState createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen>

    with TickerProviderStateMixin {
      
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _fabController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fabAnimation;

  bool _isEditing = false;
  bool _showDeleteConfirmation = false;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedMood;
  late String _selectedCategory;
  File? _newImageFile;
  XFile? _webImageFile;
  final _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

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
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animations
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.bounceOut,
    ));

    // Initialize form data
    _titleController = TextEditingController(text: widget.entry.title);
    _contentController = TextEditingController(text: widget.entry.content);
    _selectedMood = widget.entry.mood;
    _selectedCategory = widget.entry.category;

    // Start animations
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _fabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _webImageFile = pickedFile;
          _newImageFile = null;
        } else {
          _newImageFile = File(pickedFile.path);
          _webImageFile = null;
        }
        
      });
    }
  }

  Future<void> _updateEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);

    if (authProvider.user == null) return;

    final updatedEntry = Entry(
      id: widget.entry.id,
      userId: widget.entry.userId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      mood: _selectedMood,
      category: _selectedCategory,
      date: widget.entry.date,
      imageUrl: widget.entry.imageUrl,
    );

    final success = await entryProvider.updateEntry(
      updatedEntry,
      authProvider.user!.token,
      _newImageFile,
    );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Entry updated successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text(entryProvider.error ?? 'Failed to update entry'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _deleteEntry() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);

    if (authProvider.user == null) return;

    final success = await entryProvider.deleteEntry(
      widget.entry.id,
      authProvider.user!.token,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 8),
              Text('Entry deleted successfully'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _shareEntry() {
    final shareText = '''
${widget.entry.title}

${widget.entry.content}

Mood: ${widget.entry.mood}
Category: ${widget.entry.category}
Date: ${DateFormat('MMMM d, yyyy').format(widget.entry.date)}

Shared from Foshmed - Digital Diary
''';

    Share.share(shareText);
  }

  void _copyToClipboard() {
    final copyText = '${widget.entry.title}\n\n${widget.entry.content}';
    Clipboard.setData(ClipboardData(text: copyText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.copy, color: Colors.white),
            SizedBox(width: 8),
            Text('Entry copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildReadOnlyView() {
    final emoji = Constants.moodEmojis[widget.entry.mood] ?? '😊';
    final color = Constants.moodColors[widget.entry.mood] ?? Colors.blue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Header with mood and date
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Text(
                              emoji,
                              style: TextStyle( 
                                fontFamily: 'NotoColorEmoji',
                                fontSize: 24,
                              ),
                              
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.entry.mood,
                                style: TextStyle(
                                  fontFamily: 'NotoColorEmoji',
                                  height: 1.1,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy • HH:mm')
                                    .format(widget.entry.date),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.entry.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
            )),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.entry.title,
                  style: TextStyle(
                    fontFamily: 'NotoColorEmoji',
                    height: 1.1,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Image if exists
          if (widget.entry.imageUrl != null &&
              widget.entry.imageUrl!.isNotEmpty) ...[
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: Interval(0.4, 1.0, curve: Curves.easeOutCubic),
              )),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GlassContainer(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.entry.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: Colors.white.withOpacity(0.5),
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Content
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Interval(0.6, 1.0, curve: Curves.easeOutCubic),
            )),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.entry.content,
                  style: TextStyle(
                    fontFamily: 'NotoColorEmoji',
                    height: 1.1,
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildEditView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Mood selector
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling?',
                    style: TextStyle( 
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MoodSelector(
                    selectedMood: _selectedMood,
                    onMoodSelected: (mood) {
                      setState(() {
                        _selectedMood = mood;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Category selector
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontFamily: 'NotoColorEmoji',
                      height: 1.1,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
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
                    dropdownColor: Colors.black87,
                    style: TextStyle(color: Colors.white),
                    items: Constants.categoryOptions.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Title and content
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
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
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      labelText: 'Content',
                      alignLabelWithHint: true,
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
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some content';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Image section
                  if (_newImageFile != null ||
                      (widget.entry.imageUrl != null &&
                          widget.entry.imageUrl!.isNotEmpty)) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _newImageFile != null
                          ? Image.file(
                              _newImageFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              widget.entry.imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.photo, color: Colors.white),
                          label: Text(
                            _newImageFile != null ||
                                    (widget.entry.imageUrl != null &&
                                        widget.entry.imageUrl!.isNotEmpty)
                                ? 'Change Photo'
                                : 'Add Photo',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: _pickImage,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_newImageFile != null ||
                          (widget.entry.imageUrl != null &&
                              widget.entry.imageUrl!.isNotEmpty)) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _newImageFile = null;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _titleController.text = widget.entry.title;
                        _contentController.text = widget.entry.content;
                        _selectedMood = widget.entry.mood;
                        _selectedCategory = widget.entry.category;
                        _newImageFile = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Consumer<EntryProvider>(
                    builder: (context, entryProvider, child) {
                      return CustomButton(
                        text: 'Save Changes',
                        isLoading: entryProvider.isLoading,
                        onPressed: _updateEntry,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 100), // Space for FAB
          ],
        ),
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
          _isEditing ? 'Edit Entry' : 'Entry Details',
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
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: _shareEntry,
            ),
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: _copyToClipboard,
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              color: Colors.black87,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    setState(() {
                      _isEditing = true;
                    });
                    break;
                  case 'delete':
                    setState(() {
                      _showDeleteConfirmation = true;
                    });
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/entry_detail_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _isEditing ? _buildEditView() : _buildReadOnlyView(),

              // Delete confirmation dialog
              if (_showDeleteConfirmation)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: GlassContainer(
                        width: 300,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Delete Entry',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Are you sure you want to delete this entry? This action cannot be undone.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showDeleteConfirmation = false;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.white30),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showDeleteConfirmation = false;
                                      });
                                      _deleteEntry();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text('Delete'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: !_isEditing
          ? ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: Icon(Icons.edit),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            )
          : null,
    );
  }
}
