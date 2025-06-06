import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:foshmed/models/template.dart';
import 'package:foshmed/utils/constants.dart';

class TemplateProvider with ChangeNotifier {
  List<NoteTemplate> _templates = [];
  bool _isLoading = false;
  String? _error;

  List<NoteTemplate> get templates => [..._templates];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTemplates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/templates.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _templates = responseData.map((data) => NoteTemplate.fromJson(data)).toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      } else {
        _error = 'Failed to load templates';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> useTemplate(String templateId, String mood, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/templates.php'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: {
          'template_id': templateId,
          'mood': mood,
        },
      );

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to use template';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<NoteTemplate> getTemplatesByCategory(String category) {
    return _templates.where((template) => template.category == category).toList();
  }

  List<String> getCategories() {
    return _templates.map((template) => template.category).toSet().toList();
  }
}
