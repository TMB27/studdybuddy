import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import '../../utils/responsive.dart';

class UploadPdfScreen extends StatefulWidget {
  final String? initialYear;
  final String? initialFeatureType;
  final String? initialSubject;
  const UploadPdfScreen({
    super.key,
    this.initialYear,
    this.initialFeatureType,
    this.initialSubject,
  });

  @override
  State<UploadPdfScreen> createState() => _UploadPdfScreenState();
}

class _UploadPdfScreenState extends State<UploadPdfScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  String? _selectedYear;
  String? _selectedFeatureType;
  String? _selectedSubject;
  String? _pdfFileName;
  PlatformFile? _pickedPdfFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedFeatureType = widget.initialFeatureType;
    _selectedSubject = widget.initialSubject;
  }

  void _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedPdfFile = result.files.first;
        _pdfFileName = _pickedPdfFile!.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _pickedPdfFile == null) {
      if (_pickedPdfFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick a PDF file.')),
        );
      }
      return;
    }
    setState(() => _isUploading = true);
    try {
      // 1. Upload PDF to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
        'pdfs/${DateTime.now().millisecondsSinceEpoch}_${_pickedPdfFile!.name}',
      );
      final uploadTask = await storageRef.putData(_pickedPdfFile!.bytes!);
      final downloadUrl = await storageRef.getDownloadURL();

      // 2. Save metadata to Firestore
      final collectionName = FirestoreHelper.collectionForFeatureType(_selectedFeatureType);
      await FirebaseFirestore.instance.collection(collectionName).add({
        'title': _titleController.text.trim(),
        'url': downloadUrl,
        'year': _selectedYear,
        'subject': _selectedSubject,
        'featureType': _selectedFeatureType,
        'uploadedAt': FieldValue.serverTimestamp(),
      });
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _downloadPdf(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Storage permission denied.')),
        );
        return;
      }
      final downloadsDir = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      final dir = downloadsDir?.first;
      if (dir == null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Cannot access downloads directory.')),
        );
        return;
      }
      final filePath = '${dir.path}/${_titleController.text.replaceAll(' ', '_')}.pdf';
      await Dio().download(_pdfFileName!, filePath);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Downloaded to $filePath')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final subjects = _selectedYear != null && _selectedFeatureType != null
        ? FirestoreHelper.subjectsFor(_selectedYear!, _selectedFeatureType!)
        : <String>[];
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: theme.appBarTheme.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Upload PDF',
                    style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: 24),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 32, bottom: 32),
            child: Center(
              child: Card(
                color: colorScheme.surface,
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: Responsive.scaledPadding(context, horizontal: 20, vertical: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: textTheme.bodyMedium,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter a title' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedYear,
                          decoration: InputDecoration(
                            labelText: 'Year',
                            labelStyle: textTheme.bodyMedium,
                          ),
                          items: FirestoreHelper.years
                              .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _selectedYear = v;
                            _selectedSubject = null;
                          }),
                          validator: (v) => v == null ? 'Select a year' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedFeatureType,
                          decoration: InputDecoration(
                            labelText: 'Feature Type',
                            labelStyle: textTheme.bodyMedium,
                          ),
                          items: FirestoreHelper.featureTypes
                              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _selectedFeatureType = v;
                          }),
                          validator: (v) =>
                              v == null ? 'Select a feature type' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            labelStyle: textTheme.bodyMedium,
                          ),
                          items: subjects
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _selectedSubject = v;
                          }),
                          validator: (v) => v == null ? 'Select a subject' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isUploading ? null : _pickPdf,
                              icon: const Icon(Icons.attach_file),
                              label: const Text('Pick PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _pdfFileName ?? 'No file selected',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: _pdfFileName != null
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurface.withOpacity(0.5),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isUploading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                              child: _isUploading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Upload'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
