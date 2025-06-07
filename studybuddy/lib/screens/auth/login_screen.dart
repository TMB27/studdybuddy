import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  bool rememberMe = false;
  bool passwordVisible = false;
  bool _isLoading = false;

  void login() async {
    setState(() {
      _isLoading = true;
    });
    final user = await authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    if (user != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Successful')));
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Failed')));
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      // Check if user exists in Firestore, if not, create
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'name': user.displayName ?? '',
                'email': user.email ?? '',
                'profileImageUrl': user.photoURL ?? '',
                'uid': user.uid,
                'createdAt': Timestamp.now(),
              });
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Successful')));
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-In Failed: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width < 600 ? width * 0.98 : 500,
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: Responsive.scaleHeight(context, 60),
                          left: Responsive.scaleWidth(context, 20),
                          right: Responsive.scaleWidth(context, 20),
                          bottom: Responsive.scaleHeight(context, 32),
                        ),
                        color: colorScheme.primary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/logo_less.png',
                                  height: width * 0.12,
                                ),
                                SizedBox(width: width * 0.02),
                                Text(
                                  "Study Buddy",
                                  style: textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontSize: Responsive.scaleText(context, 20),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.04),
                            Text(
                              "Sign in to your\nAccount",
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontSize: Responsive.scaleText(context, 32),
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Row(
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onPrimary.withOpacity(
                                      0.8,
                                    ),
                                    fontSize: Responsive.scaleText(context, 15),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacementNamed(
                                    context,
                                    '/signup',
                                  ),
                                  child: Text(
                                    "Sign Up",
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: Responsive.scaleText(
                                        context,
                                        15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Form Card
                      Expanded(
                        child: Center(
                          child: Card(
                            color: theme.cardColor,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(32),
                              ),
                            ),
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.scaleWidth(context, 22),
                                vertical: Responsive.scaleHeight(context, 32),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Email
                                  TextField(
                                    controller: emailController,
                                    style: textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      labelText: "Email",
                                    ),
                                  ),
                                  SizedBox(height: height * 0.02),
                                  // Password
                                  TextField(
                                    controller: passwordController,
                                    obscureText: !passwordVisible,
                                    style: textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () => setState(
                                          () => passwordVisible =
                                              !passwordVisible,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.01),
                                  // Remember me and Forgot Password
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: rememberMe,
                                        onChanged: (val) => setState(
                                          () => rememberMe = val ?? false,
                                        ),
                                        activeColor: colorScheme.primary,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      Text(
                                        "Remember me",
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontSize: Responsive.scaleText(
                                            context,
                                            15,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          '/forgot-password',
                                        ),
                                        child: Text(
                                          "Forgot Password ?",
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.secondary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: Responsive.scaleText(
                                              context,
                                              15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.02),
                                  // Log In Button
                                  SizedBox(
                                    height: height * 0.065,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : login,
                                      child: Text(
                                        "Log In",
                                        style: textTheme.titleMedium?.copyWith(
                                          fontSize: Responsive.scaleText(
                                            context,
                                            15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.02),
                                  // Divider with Or login with
                                  Row(
                                    children: [
                                      const Expanded(child: Divider()),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: Responsive.scaleWidth(
                                            context,
                                            2,
                                          ),
                                        ),
                                        child: Text(
                                          "Or login with",
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.secondary,
                                            fontSize: Responsive.scaleText(
                                              context,
                                              15,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.02),
                                  // Google Button
                                  OutlinedButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : signInWithGoogle,
                                    icon: Image.asset(
                                      'assets/google_logo.png',
                                      height: width * 0.06,
                                    ),
                                    label: Text(
                                      "Google",
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontSize: Responsive.scaleText(
                                          context,
                                          15,
                                        ),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: Responsive.scaleHeight(
                                          context,
                                          15,
                                        ),
                                      ),
                                      side: BorderSide(
                                        color: colorScheme.secondary,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.03),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
