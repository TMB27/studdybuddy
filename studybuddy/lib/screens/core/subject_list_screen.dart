import 'package:flutter/material.dart';
import '../../widgets/app_card.dart';
import '../../services/firestore_helper.dart';
import '../../utils/responsive.dart';

class SubjectListScreen extends StatelessWidget {
  final String year;
  final String featureType; // notes, pyqs, micros

  const SubjectListScreen({
    super.key,
    required this.year,
    required this.featureType,
  });

  @override
  Widget build(BuildContext context) {
    final subjects = FirestoreHelper.subjectsFor(year, featureType);
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
                  Text(
                    '$featureType Subjects',
                    style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: 28),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: Responsive.scaledPadding(context, horizontal: 16, vertical: 24),
        child: ListView.separated(
          itemCount: subjects.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 150),
              child: AppCard(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/content/${Uri.encodeComponent(subject)}',
                    arguments: {
                      'subject': subject,
                      'featureType': featureType,
                      'year': year,
                    },
                  );
                },
                color: colorScheme.surface,
                elevation: 6,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.menu_book, color: colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        subject,
                        style: textTheme.titleLarge?.copyWith(fontSize: 20),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: colorScheme.onSurface.withOpacity(0.7)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
