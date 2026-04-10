import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/appointments_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_decorations.dart';
import '../../../widgets/mobile_header.dart';
import '../../auth/auth_provider.dart';
import 'doctor_documents_provider.dart';

class DoctorDocumentsScreen extends StatelessWidget {
  const DoctorDocumentsScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<DoctorDocumentsProvider>();
    final doctorId = auth.user?.uid ?? '';
    final docs = provider.filteredDocuments(doctorId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDesktop)
          const MobileHeader(title: 'Documents', showSearch: false),
        if (isDesktop)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Health Documents',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Upload and manage patient reports & health documents',
                style: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),

        // Stats row
        LayoutBuilder(
          builder: (context, constraints) {
            final allDocs = provider.documents;
            final cardWidth = isDesktop && constraints.maxWidth >= 700
                ? (constraints.maxWidth - 32) / 3
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _StatCard(
                    title: 'Total Documents',
                    value: '${allDocs.length}',
                    icon: Icons.folder_rounded,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _StatCard(
                    title: 'Patients with Docs',
                    value: '${allDocs.map((d) => d.patientId).toSet().length}',
                    icon: Icons.people_rounded,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _StatCard(
                    title: 'Uploaded by You',
                    value:
                        '${allDocs.where((d) => d.uploadedById == doctorId).length}',
                    icon: Icons.cloud_upload_rounded,
                    color: AppColors.success,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Search + Filter + Upload button
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: isDesktop ? 300 : double.infinity,
              child: TextField(
                onChanged: provider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search by file, patient, category...',
                  hintStyle: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.mutedForeground,
                  ),
                  filled: true,
                  fillColor: AppColors.muted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppColors.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            SizedBox(
              width: isDesktop ? 220 : double.infinity,
              child: _PatientDropdown(
                patients: provider.patients,
                selectedPatientId: provider.selectedPatientId,
                onChanged: provider.setSelectedPatient,
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: provider.isUploading
                    ? null
                    : () => _showUploadDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppColors.borderRadius),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                icon: provider.isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_file_rounded),
                label: Text(
                  provider.isUploading ? 'Uploading...' : 'Upload Document',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (provider.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.destructiveLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.destructive),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: TextStyle(color: AppColors.destructive),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Documents list
        Container(
          decoration: AppDecorations.card(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Documents',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open_rounded,
                          size: 56,
                          color: AppColors.mutedForeground.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No documents found',
                          style: TextStyle(
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Upload a report or health document to get started',
                          style: TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: docs
                      .map(
                        (doc) => _DocumentTile(
                          document: doc,
                          onDelete: () =>
                              provider.deleteDocument(doc.id, doc.fileUrl),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUploadDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final provider = context.read<DoctorDocumentsProvider>();
    final patients = provider.patients;

    String? selectedPatientId;
    String? selectedPatientName;
    String category = 'Lab Report';
    String notes = '';
    PlatformFile? pickedFile;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Upload Document',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient selection
                      Text(
                        'Select Patient',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedPatientId,
                        decoration: InputDecoration(
                          hintText: 'Choose a patient',
                          filled: true,
                          fillColor: AppColors.muted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: patients.map((p) {
                          return DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPatientId = value;
                            selectedPatientName = patients
                                .firstWhere((p) => p.id == value)
                                .name;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.muted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Lab Report',
                            child: Text('Lab Report'),
                          ),
                          DropdownMenuItem(
                            value: 'Prescription',
                            child: Text('Prescription'),
                          ),
                          DropdownMenuItem(
                            value: 'Scan / Imaging',
                            child: Text('Scan / Imaging'),
                          ),
                          DropdownMenuItem(
                            value: 'Discharge Summary',
                            child: Text('Discharge Summary'),
                          ),
                          DropdownMenuItem(
                            value: 'General',
                            child: Text('General'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => category = value ?? 'General');
                        },
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      Text(
                        'Notes (optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        maxLines: 2,
                        onChanged: (v) => notes = v,
                        decoration: InputDecoration(
                          hintText: 'Add any notes about this document...',
                          filled: true,
                          fillColor: AppColors.muted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // File picker
                      Text(
                        'File',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: [
                              'pdf',
                              'png',
                              'jpg',
                              'jpeg',
                              'doc',
                              'docx',
                            ],
                            withData: true,
                          );
                          if (result != null && result.files.isNotEmpty) {
                            setState(() => pickedFile = result.files.first);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.muted,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                pickedFile != null
                                    ? Icons.check_circle_rounded
                                    : Icons.cloud_upload_outlined,
                                size: 36,
                                color: pickedFile != null
                                    ? AppColors.success
                                    : AppColors.mutedForeground,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                pickedFile != null
                                    ? pickedFile!.name
                                    : 'Tap to select a file',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: pickedFile != null
                                      ? AppColors.foreground
                                      : AppColors.mutedForeground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (pickedFile != null)
                                Text(
                                  '${(pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.mutedForeground),
                  ),
                ),
                ElevatedButton(
                  onPressed: (selectedPatientId == null || pickedFile == null)
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await provider.uploadBytes(
                            patientId: selectedPatientId!,
                            patientName: selectedPatientName ?? '',
                            doctorId: auth.user?.uid ?? '',
                            doctorName: auth.profileName,
                            fileName: pickedFile!.name,
                            fileBytes: pickedFile!.bytes!,
                            category: category,
                            notes: notes,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Upload'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _PatientDropdown extends StatelessWidget {
  const _PatientDropdown({
    required this.patients,
    required this.selectedPatientId,
    required this.onChanged,
  });

  final List<Patient> patients;
  final String? selectedPatientId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedPatientId,
      decoration: InputDecoration(
        hintText: 'All Patients',
        hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
        filled: true,
        fillColor: AppColors.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.borderRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Patients')),
        ...patients.map(
          (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document, required this.onDelete});

  final HealthDocument document;
  final VoidCallback onDelete;

  IconData _fileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _fileColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return AppColors.destructive;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return AppColors.info;
      case 'doc':
      case 'docx':
        return AppColors.primary;
      default:
        return AppColors.mutedForeground;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Lab Report':
        return AppColors.info;
      case 'Prescription':
        return AppColors.success;
      case 'Scan / Imaging':
        return AppColors.accent;
      case 'Discharge Summary':
        return AppColors.warning;
      default:
        return AppColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadDate = DateFormat(
      'd MMM yyyy, hh:mm a',
    ).format(document.uploadedAt);
    final catColor = _categoryColor(document.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.muted.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _fileColor(document.fileType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              _fileIcon(document.fileType),
              color: _fileColor(document.fileType),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        document.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: catColor,
                        ),
                      ),
                    ),
                    Text(
                      document.patientName,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Uploaded $uploadDate by ${document.uploadedByName} (${document.uploadedByRole})',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
                if (document.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    document.notes,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.foreground.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.destructive,
            ),
            tooltip: 'Delete document',
          ),
        ],
      ),
    );
  }
}
