import 'package:flutter/material.dart';
import '../../widgets/app_card.dart';
import 'subject_list_screen.dart';

class FeatureListScreen extends StatelessWidget {
  final String year;
  const FeatureListScreen({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final features = [
      {'title': 'Notes', 'icon': Icons.menu_book},
      {'title': 'PYQs', 'icon': Icons.assignment},
      {'title': 'Solved PYQs', 'icon': Icons.check_circle_outline},
      {'title': 'Shot Notes', 'icon': Icons.flash_on},
    ];

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
                    '${year.split(' ')[0]} Year',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: AppCard(
                  color: colorScheme.surface,
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubjectListScreen(
                          year: year,
                          featureType: feature['title'] as String,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Text(
                          feature['title'] as String,
                          style: textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
