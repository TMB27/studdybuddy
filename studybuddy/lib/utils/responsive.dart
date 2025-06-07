import 'package:flutter/material.dart';

class Responsive {
  static double scaleWidth(BuildContext context, double value) {
    final width = MediaQuery.of(context).size.width;
    // 375 is a common base width for mobile
    return value * (width / 375.0);
  }

  static double scaleHeight(BuildContext context, double value) {
    final height = MediaQuery.of(context).size.height;
    // 812 is a common base height for mobile
    return value * (height / 812.0);
  }

  static double scaleText(BuildContext context, double value) {
    final width = MediaQuery.of(context).size.width;
    // Use width as a base for text scaling
    return value * (width / 375.0);
  }

  static EdgeInsets scaledPadding(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: scaleWidth(context, horizontal),
      vertical: scaleHeight(context, vertical),
    );
  }
}
