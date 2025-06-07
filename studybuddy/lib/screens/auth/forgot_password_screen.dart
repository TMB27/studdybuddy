import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final authService = AuthService();
  bool isLoading = false;

  void reset() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter your email')));
      return;
    }
    setState(() => isLoading = true);
    await authService.resetPassword(emailController.text.trim());
    setState(() => isLoading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reset link sent to your email')));
    Navigator.pop(context);
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
                      // Header with Icon/Illustration
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: Responsive.scaleHeight(context, 32),
                          left: Responsive.scaleWidth(context, 15),
                          right: Responsive.scaleWidth(context, 15),
                          bottom: Responsive.scaleHeight(context, 24),
                        ),
                        color: colorScheme.primary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: colorScheme.onPrimary,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            SizedBox(height: height * 0.01),
                            Center(
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: colorScheme.secondary
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.lock_reset_rounded,
                                  color: colorScheme.secondary,
                                  size: 40,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            Center(
                              child: Text(
                                "Forgot Password?",
                                style: textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontSize: Responsive.scaleText(context, 28),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Center(
                              child: Text(
                                "Don't worry! Enter your email and we'll send you a reset link.",
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimary.withOpacity(
                                    0.85,
                                  ),
                                  fontSize: Responsive.scaleText(context, 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Form Card
                      Expanded(
                        child: Center(
                          child: Card(
                            color: theme.cardColor,
                            elevation: 10,
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
                                  Text(
                                    "Email Address",
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: Responsive.scaleText(
                                        context,
                                        16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.01),
                                  Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(12),
                                    child: TextField(
                                      controller: emailController,
                                      style: textTheme.bodyLarge,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: "Enter your email",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: colorScheme.surface,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 18,
                                          horizontal: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.03),
                                  // Send to Email Button
                                  SizedBox(
                                    height: height * 0.065,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : reset,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: isLoading
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: colorScheme.onPrimary,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : Text(
                                              "Send Reset Link",
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontSize:
                                                        Responsive.scaleText(
                                                          context,
                                                          16,
                                                        ),
                                                    color:
                                                        colorScheme.onPrimary,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.04),
                                  // Back to Login Link
                                  Center(
                                    child: GestureDetector(
                                      onTap: () =>
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/login',
                                          ),
                                      child: Text(
                                        "Back to Login",
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
                                  ),
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
