import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfViewerScreen extends StatelessWidget {
  final String url;
  final String title;

  const PdfViewerScreen({super.key, required this.url, required this.title});

  Future<bool> _isAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return (doc.data()?['role'] ?? '') == 'admin';
  }

  void _showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ],
          ),
        ),
      ),
    );
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
      final filePath = '${dir.path}/${title.replaceAll(' ', '_')}.pdf';
      _showLoadingDialog(context, message: 'Downloading...');
      await Dio().download(url, filePath);
      Navigator.of(context, rootNavigator: true).pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Downloaded to $filePath')),
      );
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FutureBuilder<bool>(
                  future: _isAdmin(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(width: 48, height: 48); // Placeholder
                    }
                    if (snapshot.data == true) {
                      return IconButton(
                        icon: Icon(Icons.download, color: colorScheme.primary),
                        onPressed: () => _downloadPdf(context),
                        tooltip: 'Download',
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SfPdfViewer.network(url),
    );
  }
}
