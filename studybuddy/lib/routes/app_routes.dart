import 'package:flutter/material.dart';

// Import your screen widgets
import '../screens/startup_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/core/subject_list_screen.dart';
import '../screens/core/home_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
// Add other screens like forgotPasswordScreen, editProfileScreen, notesScreen, etc.

class AppRoutes {
  static const String startup = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String forgotPassword = '/forgot-password';
  static const String editProfile = '/edit-profile';
  static const String notes = '/notes';
  static const String pyqs = '/pyqs';
  static const String profile = '/profile';
}

// Define the routes
final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.startup: (context) => const StartupScreen(),
  AppRoutes.login: (context) => const LoginScreen(),
  AppRoutes.signup: (context) => const SignupScreen(),
  AppRoutes.home: (context) => const HomeScreen(),
  AppRoutes.notes: (context) => const SubjectListScreen(
    year: 'First Year Engineering',
    featureType: 'notes',
  ),
  AppRoutes.pyqs: (context) => const SubjectListScreen(
    year: 'First Year Engineering',
    featureType: 'pyqs',
  ),
  AppRoutes.profile: (context) => const ProfileScreen(),
  AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
  // Add other routes like these:
  // AppRoutes.editProfile: (context) => const EditProfileScreen(),
  // AppRoutes.notes: (context) => const NotesScreen(),
};
