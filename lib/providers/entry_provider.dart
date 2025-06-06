import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:foshmed/models/entry.dart';
import 'package:foshmed/utils/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';



class EntryProvider with ChangeNotifier {
  List<Entry> _entries = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreData = true;

  List<Entry> get entries => [..._entries];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  Future<void> fetchEntries(String userId, String token,
      {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _entries.clear();
      _hasMoreData = true;
    }

    if (_isLoading || !_hasMoreData) return;

    print('Fetching entries for user: $userId, page: $_currentPage');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/entries.php?page=$_currentPage&limit=20'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        if (responseBody.isNotEmpty) {
          try {
            final Map<String, dynamic> responseData = json.decode(responseBody);
            final List<dynamic> entriesData = responseData['entries'] ?? [];
            final Map<String, dynamic> pagination =
                responseData['pagination'] ?? {};

            final newEntries =
                entriesData.map((data) => Entry.fromJson(data)).toList();

            if (refresh) {
              _entries = newEntries;
            } else {
              _entries.addAll(newEntries);
            }

            _currentPage = pagination['current_page'] ?? 1;
            _totalPages = pagination['total_pages'] ?? 1;
            _hasMoreData = _currentPage < _totalPages;

            print(
                'Loaded ${newEntries.length} entries, total: ${_entries.length}');
          } catch (e) {
            print('JSON decode error: $e');
            _error = 'Failed to parse entries data';
          }
        } else {
          if (refresh) _entries = [];
          _hasMoreData = false;
          print('Empty response body');
        }
        _isLoading = false;
        _error = null;
        notifyListeners();
      } else {
        _error = 'Failed to load entries: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        print('Error: $_error');
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      print('Network error: $e');
    }
  }

  Future<void> loadMoreEntries(String userId, String token) async {
    if (_hasMoreData && !_isLoading) {
      _currentPage++;
      await fetchEntries(userId, token);
    }
  }

  Future<bool> addEntry(
  Entry entry,
  String token,
  File? imageFile, {
  XFile? webImageFile, // Tambahkan parameter opsional untuk web
}) async {
  print('Adding new entry: ${entry.title}');
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Constants.apiUrl}/entries.php'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['title'] = entry.title;
    request.fields['content'] = entry.content;
    request.fields['mood'] = entry.mood;
    request.fields['category'] = entry.category;
    request.fields['is_quick_note'] = entry.title == 'Quick Note' ? '1' : '0';

    print('Request fields: ${request.fields}');

    // Handle image upload for web and mobile
    if (kIsWeb && webImageFile != null) {
      final bytes = await webImageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: webImageFile.name,
        contentType: MediaType('image', webImageFile.name.split('.').last),
      );
      request.files.add(multipartFile);
      print('Web image file added: ${webImageFile.name}');
    } else if (!kIsWeb && imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));
      print('Image file added: ${imageFile.path}');
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Add entry response status: ${response.statusCode}');
    print('Add entry response body: ${response.body}');

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final newEntry = Entry(
        id: responseData['entry_id'].toString(),
        userId: entry.userId,
        title: entry.title,
        content: entry.content,
        mood: entry.mood,
        category: entry.category,
        date: DateTime.now(),
        imageUrl: responseData['image_url'],
      );

      _entries.insert(0, newEntry); // Add to beginning of list
      _isLoading = false;
      _error = null;
      notifyListeners();
      print('Entry added successfully');
      return true;
    } else {
      final responseData = json.decode(response.body);
      _error = responseData['message'] ?? 'Failed to add entry';
      _isLoading = false;
      notifyListeners();
      print('Failed to add entry: $_error');
      return false;
    }
  } catch (e) {
    _error = 'Network error: $e';
    _isLoading = false;
    notifyListeners();
    print('Add entry error: $e');
    return false;
  }
}

  Future<bool> updateEntry(Entry entry, String token, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiUrl}/update_entry.php'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['entry_id'] = entry.id;
      request.fields['title'] = entry.title;
      request.fields['content'] = entry.content;
      request.fields['mood'] = entry.mood;
      request.fields['category'] = entry.category;

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final updatedEntry = Entry(
          id: entry.id,
          userId: entry.userId,
          title: entry.title,
          content: entry.content,
          mood: entry.mood,
          category: entry.category,
          date: entry.date,
          imageUrl: responseData['image_url'] ?? entry.imageUrl,
        );

        final index = _entries.indexWhere((e) => e.id == entry.id);
        if (index >= 0) {
          _entries[index] = updatedEntry;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update entry';
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

  Future<bool> deleteEntry(String entryId, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('${Constants.apiUrl}/entries.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'entry_id=$entryId',
      );

      if (response.statusCode == 200) {
        _entries.removeWhere((entry) => entry.id == entryId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete entry';
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

  List<Entry> filterEntries(
      {String? query,
      String? category,
      String? mood,
      DateTime? fromDate,
      DateTime? toDate}) {
    return _entries.where((entry) {
      bool matchesQuery = query == null ||
          query.isEmpty ||
          entry.title.toLowerCase().contains(query.toLowerCase()) ||
          entry.content.toLowerCase().contains(query.toLowerCase());

      bool matchesCategory =
          category == null || category.isEmpty || entry.category == category;

      bool matchesMood = mood == null || mood.isEmpty || entry.mood == mood;

      bool matchesDateRange = true;
      if (fromDate != null) {
        matchesDateRange = entry.date.isAfter(fromDate) ||
            entry.date.isAtSameMomentAs(fromDate);
      }
      if (toDate != null) {
        final endOfDay =
            DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
        matchesDateRange = matchesDateRange &&
            (entry.date.isBefore(endOfDay) ||
                entry.date.isAtSameMomentAs(endOfDay));
      }

      return matchesQuery && matchesCategory && matchesMood && matchesDateRange;
    }).toList();
  }

  Future<File> exportToPdf(String userName) async {
    final pdf = pw.Document();

    // Add title page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Foshmed',
                  style: pw.TextStyle(
                      fontSize: 40, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Catatan Harian Digital',
                  style: pw.TextStyle(fontSize: 24),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Diary of $userName',
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Generated on ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Add entries
    for (var entry in _entries) {
      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      entry.title,
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      entry.date.toString().split(' ')[0],
                      style:
                          pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Text(
                      'Mood: ${entry.mood}',
                      style: pw.TextStyle(
                          fontSize: 14, fontStyle: pw.FontStyle.italic),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Text(
                      'Category: ${entry.category}',
                      style: pw.TextStyle(
                          fontSize: 14, fontStyle: pw.FontStyle.italic),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.SizedBox(height: 16),
                pw.Text(
                  entry.content,
                  style: pw.TextStyle(fontSize: 14),
                ),
              ],
            );
          },
        ),
      );
    }

    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/foshmed_diary.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
