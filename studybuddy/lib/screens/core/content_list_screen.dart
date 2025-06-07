import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/app_card.dart';
import '../../services/firestore_helper.dart';
import 'pdf_viewer_screen.dart';
import 'upload_pdf_screen.dart';
import '../../utils/responsive.dart';

class ContentListScreen extends StatefulWidget {
  final String subject;
  final String featureType;
  final String year;

  const ContentListScreen({
    super.key,
    required this.subject,
    required this.featureType,
    required this.year,
  });

  @override
  State<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  bool isAdmin = false;
  bool loadingRole = true;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      setState(() {
        isAdmin = (doc.data()?['role'] ?? '') == 'admin';
        loadingRole = false;
      });
    } else {
      setState(() {
        isAdmin = false;
        loadingRole = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String collectionName = FirestoreHelper.collectionForFeatureType(widget.featureType);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                  Expanded(
                    child: Text(
                      "${widget.subject} ${widget.featureType} (${widget.year})",
                      style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: 24),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collectionName)
            .where('subject', isEqualTo: widget.subject)
            .where('year', isEqualTo: widget.year)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(
              "Firestore Stream Error for $collectionName: [38;5;9m${snapshot.error}[0m",
            );
            return Center(
              child: Text(
                "Error loading content. Check console for details.",
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            if (!snapshot.hasData) {
              print(
                "No data yet for $collectionName, but no error. Still loading or genuinely empty.",
              );
              return Center(
                child: Text(
                  "Loading...",
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                ),
              );
            }
            return Center(
              child: Text(
                "No files uploaded for this subject yet.",
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              ),
            );
          }

          final items = snapshot.data!.docs;

          return ListView.separated(
            padding: Responsive.scaledPadding(context, horizontal: 16, vertical: 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final data = items[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Untitled';
              final url = data['url'];

              return AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 150),
                child: AppCard(
                  onTap: url != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PdfViewerScreen(url: url, title: title),
                            ),
                          );
                        }
                      : null,
                  color: colorScheme.surface,
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.redAccent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (url != null)
                        Icon(Icons.open_in_new, color: colorScheme.onSurface.withOpacity(0.7)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: loadingRole
          ? null
          : isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UploadPdfScreen(
                      initialYear: widget.year,
                      initialFeatureType: widget.featureType,
                      initialSubject: widget.subject,
                    ),
                  ),
                );
              },
              backgroundColor: colorScheme.primary,
              elevation: 8,
              tooltip: 'Upload PDF',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.upload_file, color: colorScheme.onPrimary),
            )
          : null,
    );
  }
}
