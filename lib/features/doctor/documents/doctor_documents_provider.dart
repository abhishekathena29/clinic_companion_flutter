import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../shared/appointments_repository.dart';

class DoctorDocumentsProvider extends ChangeNotifier {
  DoctorDocumentsProvider(this._repository) {
    _repository.addListener(_onRepoChanged);
  }

  final AppointmentsRepository _repository;

  String _searchQuery = '';
  String? _selectedPatientId;
  bool _isUploading = false;
  String? _error;

  String get searchQuery => _searchQuery;
  String? get selectedPatientId => _selectedPatientId;
  bool get isUploading => _isUploading;
  String? get error => _error;

  List<HealthDocument> get documents {
    if (_selectedPatientId != null && _selectedPatientId!.isNotEmpty) {
      return _repository.documentsForPatient(_selectedPatientId!);
    }
    return _repository.documents;
  }

  List<HealthDocument> filteredDocuments(String doctorId) {
    var docs = documents;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      docs = docs
          .where(
            (doc) =>
                doc.fileName.toLowerCase().contains(query) ||
                doc.patientName.toLowerCase().contains(query) ||
                doc.category.toLowerCase().contains(query),
          )
          .toList();
    }
    return docs;
  }

  List<Patient> get patients => _repository.patients;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedPatient(String? patientId) {
    _selectedPatientId = patientId;
    notifyListeners();
  }

  Future<void> pickAndUpload({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String category,
    String notes = '',
  }) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.uploadDocument(
        patientId: patientId,
        patientName: patientName,
        uploadedById: doctorId,
        uploadedByName: doctorName,
        uploadedByRole: 'doctor',
        fileName: file.name,
        fileBytes: file.bytes!,
        category: category,
        notes: notes,
      );
    } catch (e) {
      _error = 'Upload failed: ${e.toString()}';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> uploadBytes({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String fileName,
    required Uint8List fileBytes,
    required String category,
    String notes = '',
  }) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.uploadDocument(
        patientId: patientId,
        patientName: patientName,
        uploadedById: doctorId,
        uploadedByName: doctorName,
        uploadedByRole: 'doctor',
        fileName: fileName,
        fileBytes: fileBytes,
        category: category,
        notes: notes,
      );
    } catch (e) {
      _error = 'Upload failed: ${e.toString()}';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDocument(String documentId, String fileUrl) async {
    try {
      await _repository.deleteDocument(documentId, fileUrl);
    } catch (e) {
      _error = 'Delete failed: ${e.toString()}';
      notifyListeners();
    }
  }

  void _onRepoChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.removeListener(_onRepoChanged);
    super.dispose();
  }
}
