import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foshmed/providers/template_provider.dart';
import 'package:foshmed/providers/auth_provider.dart';
import 'package:foshmed/providers/entry_provider.dart';
import 'package:foshmed/widgets/glass_container.dart';
import 'package:foshmed/utils/constants.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({Key? key}) : super(key: key);

  @override
  _TemplateScreenState createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  String _selectedCategory = 'All';
  String _selectedMood = Constants.moodOptions.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TemplateProvider>(context, listen: false).fetchTemplates();
    });
  }

  Future<void> _useTemplate(String templateId) async {
    final templateProvider = Provider.of<TemplateProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    
    if (authProvider.user == null) return;
    
    final success = await templateProvider.useTemplate(
      templateId,
      _selectedMood,
      authProvider.user!.token,
    );
    
    if (success && mounted) {
      // Refresh entries
      await entryProvider.fetchEntries(
        authProvider.user!.id,
        authProvider.user!.token,
        refresh: true,
      );
      
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Template applied successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text(templateProvider.error ?? 'Failed to apply template'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showTemplatePreview(template) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    template.icon,
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      template.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  template.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                template.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              
              SizedBox(height: 20),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      template.content,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
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
              
              SizedBox(height: 20),
              
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
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Consumer<TemplateProvider>(
                      builder: (context, templateProvider, child) {
                        return ElevatedButton(
                          onPressed: templateProvider.isLoading 
                              ? null 
                              : () {
                                  Navigator.pop(context);
                                  _useTemplate(template.id);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: templateProvider.isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Use Template',
                                  style: TextStyle(color: Colors.white),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          'Note Templates',
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
            image: AssetImage('assets/images/template_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Consumer<TemplateProvider>(
            builder: (context, templateProvider, child) {
              if (templateProvider.isLoading && templateProvider.templates.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (templateProvider.error != null && templateProvider.templates.isEmpty) {
                return Center(
                  child: GlassContainer(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error,
                          size: 48,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error loading templates',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          templateProvider.error!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => templateProvider.fetchTemplates(),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final categories = ['All', ...templateProvider.getCategories()];
              final filteredTemplates = _selectedCategory == 'All'
                  ? templateProvider.templates
                  : templateProvider.getTemplatesByCategory(_selectedCategory);

              return Column(
                children: [
                  // Category filter
                  Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == _selectedCategory;
                        
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                category,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Templates list
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredTemplates.length,
                      itemBuilder: (context, index) {
                        final template = filteredTemplates[index];
                        
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () => _showTemplatePreview(template),
                            child: GlassContainer(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        template.icon,
                                        style: TextStyle(fontSize: 32),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              template.name,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                template.category,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    template.description,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      template.content,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
