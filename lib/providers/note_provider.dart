import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../core/services/storage_service.dart';

class NoteProvider with ChangeNotifier {
  final StorageService _storageService;
  List<NoteModel> _notes = [];
  String _searchQuery = '';
  String? _selectedCourseFilter;

  NoteProvider(this._storageService) {
    _loadNotes();
  }

  List<NoteModel> get notes => _notes;
  String get searchQuery => _searchQuery;
  String? get selectedCourseFilter => _selectedCourseFilter;

  void _loadNotes() {
    _notes = _storageService.loadNotes();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCourseFilter(String? courseId) {
    _selectedCourseFilter = courseId;
    notifyListeners();
  }

  List<NoteModel> get filteredNotes {
    var list = _notes.where((n) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = n.title.toLowerCase().contains(query);
        final matchContent = n.content.toLowerCase().contains(query);
        if (!matchTitle && !matchContent) return false;
      }
      if (_selectedCourseFilter != null && _selectedCourseFilter!.isNotEmpty) {
        if (n.courseId != _selectedCourseFilter) return false;
      }
      return true;
    }).toList();

    // Pinned notes first, then latest updated
    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return list;
  }

  Future<void> addNote(NoteModel note) async {
    _notes.add(note);
    await _save();
  }

  Future<void> updateNote(NoteModel updatedNote) async {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      await _save();
    }
  }

  Future<void> togglePin(String noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      final note = _notes[index];
      _notes[index] = note.copyWith(isPinned: !note.isPinned);
      await _save();
    }
  }

  Future<void> deleteNote(String noteId) async {
    _notes.removeWhere((n) => n.id == noteId);
    await _save();
  }

  Future<void> _save() async {
    await _storageService.saveNotes(_notes);
    notifyListeners();
  }

  void refresh() {
    _loadNotes();
  }
}

