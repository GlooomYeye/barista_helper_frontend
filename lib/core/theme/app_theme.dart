import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Базовые цвета
  static const primaryBlue = Color(0XFF4318D1);
  static const primaryGreen = Color(0xFF18D1B8);
  static const errorRed = Color(0xFFE53935);
  static const lightDivider = Color(0xFFE0E0E0);
  static const darkDivider = Color(0xFF444444);
  static const lightDropdownFill = Color(0xFFF5F5F5);
  static const darkDropdownFill = Color(0xFF2D2D2D);

  static const _baseTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 96,
      fontWeight: FontWeight.w300,
      overflow: TextOverflow.ellipsis,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 60,
      fontWeight: FontWeight.w300,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 48,
      fontWeight: FontWeight.normal,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 34,
      fontWeight: FontWeight.normal,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 24,
      fontWeight: FontWeight.normal,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      overflow: TextOverflow.clip,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );

  // Светлая тема
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light(useMaterial3: true);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: Colors.grey[100],
      primaryColor: primaryBlue,
      cardColor: Colors.white,
      shadowColor: Colors.black.withAlpha((0.05 * 255).round()),
      dividerColor: lightDivider,
      hintColor: Colors.grey[600],
      textTheme: _baseTextTheme.apply(
        displayColor: Colors.black,
        bodyColor: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.grey[300]!;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryBlue.withAlpha((0.5 * 255).round());
          }
          return Colors.grey[400]!;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryBlue;
          }
          return Colors.grey[400]!;
        }),
      ),
      dropdownMenuTheme: _buildDropdownMenuTheme(
        lightDivider,
        lightDropdownFill,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: _baseTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  // Темная тема
  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark(useMaterial3: true);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: primaryGreen,
      cardColor: const Color(0xFF242424),
      shadowColor: Colors.black.withAlpha((0.2 * 255).round()),
      dividerColor: darkDivider,
      hintColor: Colors.grey[400],
      textTheme: _baseTextTheme.apply(
        displayColor: Colors.white,
        bodyColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF242424),
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFF242424),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen;
          }
          return Colors.grey[500]!;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen.withAlpha((0.5 * 255).round());
          }
          return Colors.grey[600]!;
        }),
      ),
      dropdownMenuTheme: _buildDropdownMenuTheme(darkDivider, darkDropdownFill),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: _baseTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  static DropdownMenuThemeData _buildDropdownMenuTheme(
    Color dividerColor,
    Color fillColor,
  ) {
    return DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dividerColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(fillColor),
        elevation: WidgetStateProperty.all(4),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: dividerColor, width: 1),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 4),
        ),
      ),
    );
  }

  static const lightGradient = LinearGradient(
    colors: [primaryBlue, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [primaryBlue, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient getActiveGradient(bool isDark) {
    return isDark ? darkGradient : lightGradient;
  }

  static LinearGradient activeGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return getActiveGradient(isDark);
  }

  static BoxDecoration cardDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((0.05 * 255).round()),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration gradientButtonDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? primaryGreen : primaryBlue;
    return BoxDecoration(
      gradient: getActiveGradient(isDark),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: color.withAlpha((0.3 * 255).round()),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration iconDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: getActiveGradient(isDark),
      borderRadius: BorderRadius.circular(12),
    );
  }
}
