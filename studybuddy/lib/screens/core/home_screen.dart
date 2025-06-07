import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/app_card.dart';
import 'feature_list_screen.dart';
import 'upload_pdf_screen.dart';
import '../auth/profile_screen.dart';
import 'package:animations/animations.dart';
import '../../utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAdmin = false;
  bool loadingRole = true;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _checkAdmin();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  void _onNavBarTap(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  final List<Widget> _pages = [
    // Home Tab
    _HomeTabWidget(),
    // Cart Tab
    /// CartTabWidget(),
    // Favourite Tab
    FavouriteTabWidget(),
    // Profile Tab
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
              padding: Responsive.scaledPadding(context, horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Image.asset('assets/logo_less.png', height: 60),
                  const SizedBox(width: 12),
                  Text('Study Buddy', style: theme.appBarTheme.titleTextStyle),
                  const Spacer(),
                  // Optionally, add a settings or theme toggle icon here
                ],
              ),
            ),
          ),
        ),
      ),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 500),
        reverse: false,
        transitionBuilder: (child, animation, secondaryAnimation) =>
            SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        ),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Stack(
        children: [
          BottomNavigationBar(
            backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
            selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
              //   icon: Icon(Icons.shopping_cart_outlined),
              //   label: 'Cart',
              // ),
              // BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                label: 'Favourite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onNavBarTap,
            type: BottomNavigationBarType.fixed,
          ),
          // Pill indicator
          Positioned(
            left: MediaQuery.of(context).size.width / 3 * _selectedIndex + MediaQuery.of(context).size.width / 6 - 16,
            bottom: 8,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
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
                      initialYear: null,
                      initialFeatureType: null,
                      initialSubject: null,
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

// Extracted Home tab content as a separate widget
class _HomeTabWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final years = [
      'First Year Engineering',
      'Second Year Engineering',
      'Third Year Engineering',
      'Fourth Year Engineering',
    ];
    final yearIcons = [
      Icons.looks_one,
      Icons.looks_two,
      Icons.looks_3,
      Icons.looks_4,
    ];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: years.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  return AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: AppCard(
                      color: colorScheme.surface,
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FeatureListScreen(year: years[index]),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colorScheme.primary.withOpacity(0.12),
                            child: Icon(yearIcons[index], color: colorScheme.primary, size: 28),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              years[index],
                              style: textTheme.titleLarge?.copyWith(fontSize: 22),
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
          ],
        ),
      ),
    );
  }
}

class FavouriteTabWidget extends StatelessWidget {
  const FavouriteTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Favourite screen coming soon!'));
  }
}
