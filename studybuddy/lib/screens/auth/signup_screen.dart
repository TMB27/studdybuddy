import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../utils/responsive.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  DateTime? birthDate;
  bool passwordVisible = false;
  bool isLoading = false;

  void _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF3B82F6),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        birthDate = picked;
      });
    }
  }

  void _register() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        birthDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => isLoading = true);
    try {
      final auth = FirebaseAuth.instance;
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name':
              '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'birthDate': DateFormat('dd/MM/yyyy').format(birthDate!),
          'uid': user.uid,
          'profileImageUrl': '',
          'createdAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup Successful')));
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup Failed: $e')));
    }
    setState(() => isLoading = false);
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
                              onPressed: () => Navigator.pushReplacementNamed(
                                context,
                                '/login',
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Center(
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: colorScheme.secondary
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.person_add_alt_1_rounded,
                                  color: colorScheme.secondary,
                                  size: 40,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            Center(
                              child: Text(
                                "Create Account",
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
                                "Sign up to get started with Study Buddy!",
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
                                  // First and Last Name
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Material(
                                          elevation: 2,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: TextField(
                                            controller: firstNameController,
                                            style: textTheme.bodyLarge,
                                            decoration: InputDecoration(
                                              hintText: "First Name",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: colorScheme.surface,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 18,
                                                    horizontal: 16,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width * 0.03),
                                      Expanded(
                                        child: Material(
                                          elevation: 2,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: TextField(
                                            controller: lastNameController,
                                            style: textTheme.bodyLarge,
                                            decoration: InputDecoration(
                                              hintText: "Last Name",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: colorScheme.surface,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 18,
                                                    horizontal: 16,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.02),
                                  // Email
                                  Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(12),
                                    child: TextField(
                                      controller: emailController,
                                      style: textTheme.bodyLarge,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: "Email",
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
                                  SizedBox(height: height * 0.02),
                                  // Birth date
                                  GestureDetector(
                                    onTap: _pickBirthDate,
                                    child: AbsorbPointer(
                                      child: Material(
                                        elevation: 2,
                                        borderRadius: BorderRadius.circular(12),
                                        child: TextField(
                                          style: textTheme.bodyLarge,
                                          decoration: InputDecoration(
                                            hintText: "Birth of date",
                                            suffixIcon: Icon(
                                              Icons.calendar_today,
                                              color: colorScheme.primary,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: colorScheme.surface,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 18,
                                                  horizontal: 16,
                                                ),
                                          ),
                                          controller: TextEditingController(
                                            text: birthDate == null
                                                ? ''
                                                : DateFormat(
                                                    'dd/MM/yyyy',
                                                  ).format(birthDate!),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.02),
                                  // Phone Number
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: width * 0.15,
                                        child: Material(
                                          elevation: 2,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: TextField(
                                            enabled: false,
                                            style: textTheme.bodyLarge,
                                            decoration: InputDecoration(
                                              hintText: "+91",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: colorScheme.surface,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 18,
                                                    horizontal: 16,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width * 0.03),
                                      Expanded(
                                        child: Material(
                                          elevation: 2,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: TextField(
                                            controller: phoneController,
                                            keyboardType: TextInputType.phone,
                                            style: textTheme.bodyLarge,
                                            decoration: InputDecoration(
                                              hintText: "Phone Number",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: colorScheme.surface,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 18,
                                                    horizontal: 16,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.02),
                                  // Password
                                  Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(12),
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText: !passwordVisible,
                                      style: textTheme.bodyLarge,
                                      decoration: InputDecoration(
                                        hintText: "Set Password",
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
                                  // Register Button
                                  SizedBox(
                                    height: height * 0.065,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _register,
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
                                              "Register",
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontSize:
                                                        Responsive.scaleText(
                                                          context,
                                                          20,
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
