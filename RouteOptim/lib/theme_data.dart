// Flutter ThemeData for RouteOptim Mobile App
// Extracted from React/Tailwind design system
// Light Mode Theme Configuration

import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Extracted from globals.css
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color foregroundColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFF030213);
  static const Color secondaryColor = Color(0xFFF3F3F5);

  // Gray Scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF3F3F5);
  static const Color gray200 = Color(0xFFECECF0);
  static const Color gray300 = Color(0xFFE9EBEF);
  static const Color gray400 = Color(0xFFCBCED4);
  static const Color gray600 = Color(0xFF717182);
  static const Color gray700 = Color(0xFF4A4A58);
  static const Color gray900 = Color(0xFF1A1A1A);

  // Brand Colors
  static const Color blueColor = Color(0xFF2563EB); // blue-600
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);

  static const Color greenColor = Color(0xFF16A34A); // green-600
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green600 = Color(0xFF16A34A);

  // Semantic Colors
  static const Color destructiveColor = Color(0xFFD4183D);
  static const Color mutedColor = Color(0xFFECECF0);
  static const Color mutedForeground = Color(0xFF717182);
  static const Color accentColor = Color(0xFFE9EBEF);

  // Border & Input
  static const Color borderColor = Color(0x1A000000); // rgba(0,0,0,0.1)
  static const Color inputBackground = Color(0xFFF3F3F5);
  static const Color switchBackground = Color(0xFFCBCED4);

  // Border Radius
  static const double radiusBase = 10.0; // 0.625rem = 10px
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 10.0;
  static const double radiusXl = 14.0;
  static const double radius2xl = 16.0;
  static const double radius3xl = 24.0;

  // Spacing
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing7 = 28.0;
  static const double spacing8 = 32.0;

  // Typography Scale
  static const double fontSize2xl = 24.0;
  static const double fontSizeXl = 20.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeBase = 16.0;
  static const double fontSizeSm = 14.0;
  static const double fontSizeXs = 12.0;

  // Font Weights
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Get the light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Primary Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: backgroundColor,
        secondary: secondaryColor,
        onSecondary: primaryColor,
        error: destructiveColor,
        onError: backgroundColor,
        surface: backgroundColor,
        onSurface: foregroundColor,
        surfaceContainerHighest: gray100,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: gray50,

      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2xl),
          side: const BorderSide(color: gray200, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: gray900,
          fontSize: fontSize2xl,
          fontWeight: fontWeightMedium,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: gray700,
          size: 24,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        // H1 - Large headers
        displayLarge: TextStyle(
          fontSize: fontSize2xl,
          fontWeight: fontWeightMedium,
          height: 1.5,
          color: gray900,
          letterSpacing: -0.5,
        ),
        // H2 - Medium headers
        displayMedium: TextStyle(
          fontSize: fontSizeXl,
          fontWeight: fontWeightMedium,
          height: 1.5,
          color: gray900,
          letterSpacing: -0.3,
        ),
        // H3 - Small headers
        displaySmall: TextStyle(
          fontSize: fontSizeLg,
          fontWeight: fontWeightMedium,
          height: 1.5,
          color: gray900,
        ),
        // H4 - Section titles
        headlineMedium: TextStyle(
          fontSize: fontSizeBase,
          fontWeight: fontWeightMedium,
          height: 1.5,
          color: gray900,
        ),
        // Body text
        bodyLarge: TextStyle(
          fontSize: fontSizeBase,
          fontWeight: fontWeightNormal,
          height: 1.5,
          color: foregroundColor,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeBase,
          fontWeight: fontWeightNormal,
          height: 1.5,
          color: gray600,
        ),
        bodySmall: TextStyle(
          fontSize: fontSizeSm,
          fontWeight: fontWeightNormal,
          height: 1.5,
          color: gray600,
        ),
        // Labels
        labelLarge: TextStyle(
          fontSize: fontSizeBase,
          fontWeight: fontWeightMedium,
          height: 1.5,
          color: foregroundColor,
        ),
        labelMedium: TextStyle(
          fontSize: fontSizeSm,
          fontWeight: fontWeightMedium,
          height: 1.5,
          color: foregroundColor,
        ),
        labelSmall: TextStyle(
          fontSize: fontSizeXs,
          fontWeight: fontWeightMedium,
          height: 1.5,
          color: gray600,
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacing6, vertical: spacing4),
          textStyle: const TextStyle(
            fontSize: fontSizeBase,
            fontWeight: fontWeightMedium,
            height: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gray900,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacing6, vertical: spacing4),
          textStyle: const TextStyle(
            fontSize: fontSizeBase,
            fontWeight: fontWeightMedium,
            height: 1.5,
          ),
          side: const BorderSide(color: gray200, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl),
          ),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: fontSizeBase,
            fontWeight: fontWeightMedium,
            height: 1.5,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: destructiveColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: spacing4, vertical: spacing4),
        hintStyle: const TextStyle(
          color: gray600,
          fontSize: fontSizeBase,
          fontWeight: fontWeightNormal,
        ),
        labelStyle: const TextStyle(
          color: gray600,
          fontSize: fontSizeBase,
          fontWeight: fontWeightMedium,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: gray700,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: gray200,
        thickness: 1,
        space: 1,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return backgroundColor;
          }
          return gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return switchBackground;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(backgroundColor),
        side: const BorderSide(color: gray400, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return gray400;
        }),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: gray100,
        deleteIconColor: gray700,
        disabledColor: gray200,
        selectedColor: primaryColor,
        secondarySelectedColor: secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: spacing3, vertical: spacing2),
        labelStyle: const TextStyle(
          color: foregroundColor,
          fontSize: fontSizeSm,
          fontWeight: fontWeightMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide.none,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2xl),
        ),
        titleTextStyle: const TextStyle(
          fontSize: fontSizeXl,
          fontWeight: fontWeightMedium,
          color: gray900,
        ),
        contentTextStyle: const TextStyle(
          fontSize: fontSizeBase,
          fontWeight: fontWeightNormal,
          color: foregroundColor,
          height: 1.5,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: backgroundColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius3xl),
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: backgroundColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: gray200,
        circularTrackColor: gray200,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: gray900,
        contentTextStyle: const TextStyle(
          color: backgroundColor,
          fontSize: fontSizeBase,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Navigation Bar Theme (Bottom Nav)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: backgroundColor,
        elevation: 0,
        indicatorColor: blue50,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: fontSizeXs,
            fontWeight: fontWeightMedium,
          ),
        ),
      ),
    );
  }

  // Custom gradient definitions (for gradient containers)
  static const Gradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue600, blue700],
  );

  static const Gradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green600, Color(0xFF15803D)],
  );

  // Shadow definitions
  static List<BoxShadow> get cardShadow => [
    const BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    const BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // Custom button styles for specific use cases
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: backgroundColor,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: spacing6, vertical: spacing4),
    textStyle: const TextStyle(
      fontSize: fontSizeBase,
      fontWeight: fontWeightMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLg),
    ),
    minimumSize: const Size(double.infinity, 48),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: gray100,
    foregroundColor: gray900,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: spacing6, vertical: spacing4),
    textStyle: const TextStyle(
      fontSize: fontSizeBase,
      fontWeight: fontWeightMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLg),
    ),
    minimumSize: const Size(double.infinity, 48),
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(radius2xl),
    border: Border.all(color: gray200, width: 1),
  );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(radius2xl),
    boxShadow: cardShadow,
  );
}

// Helper extension for adding theme access
extension BuildContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
