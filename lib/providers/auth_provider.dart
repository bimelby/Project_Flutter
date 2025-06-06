import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foshmed/models/user.dart';
import 'package:foshmed/utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  final SharedPreferences prefs;

  AuthProvider(this.prefs) {
    _loadUserFromPrefs();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> _loadUserFromPrefs() async {
    final userData = prefs.getString('userData');
    if (userData != null) {
      _user = User.fromJson(json.decode(userData));
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/register.php'),
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 201) {
        _user = User(
          id: responseData['user_id'],
          name: name,
          email: email,
          token: responseData['token'],
        );
        
        await prefs.setString('userData', json.encode(_user!.toJson()));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = responseData['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/login.php'),
        body: {
          'email': email,
          'password': password,
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        _user = User(
          id: responseData['user_id'],
          name: responseData['name'],
          email: email,
          token: responseData['token'],
        );
        
        await prefs.setString('userData', json.encode(_user!.toJson()));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = responseData['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    await prefs.remove('userData');
    notifyListeners();
  }

  Future<void> updateProfile(String name, String? newPassword) async {
    if (_user == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, String> data = {
        'user_id': _user!.id,
        'name': name,
      };
      
      if (newPassword != null && newPassword.isNotEmpty) {
        data['password'] = newPassword;
      }

      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/update_profile.php'),
        headers: {'Authorization': 'Bearer ${_user!.token}'},
        body: data,
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        _user = User(
          id: _user!.id,
          name: name,
          email: _user!.email,
          token: _user!.token,
        );
        
        await prefs.setString('userData', json.encode(_user!.toJson()));
        _isLoading = false;
        notifyListeners();
      } else {
        _error = responseData['message'] ?? 'Update failed';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
