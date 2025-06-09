import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:barista_helper/core/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  //String _selectedLanguage = 'English';
  //String _selectedTemperatureUnit = 'Celsius';

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: Theme.of(context),
      duration: const Duration(milliseconds: 300),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Внешний вид',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Mode
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  final isDarkMode =
                      state is ThemeChanged
                          ? state.themeMode == ThemeMode.dark
                          : Theme.of(context).brightness == Brightness.dark;

                  return _SettingsTile(
                    title: 'Тёмная тема',
                    subtitle: 'Включить тёмную тему',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged:
                          (value) => _onThemeModeChanged(
                            context,
                            value ? ThemeMode.dark : ThemeMode.light,
                          ),
                      activeColor:
                          isDarkMode
                              ? AppTheme.primaryGreen
                              : AppTheme.primaryBlue,
                      activeTrackColor: (isDarkMode
                              ? AppTheme.primaryGreen
                              : AppTheme.primaryBlue)
                          .withAlpha((0.5 * 255).round()),
                      inactiveThumbColor: Colors.grey[400],
                      inactiveTrackColor: Colors.white,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Language
              /*             _SettingsTile(
              title: 'Язык',
              subtitle: 'Выберите язык приложения',
              trailing: IntrinsicWidth(
                child: DropdownMenu<String>(
                  initialSelection: _selectedLanguage,
                  onSelected: (value) {
                    if (value != null) {
                      setState(() => _selectedLanguage = value);
                    }
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'English', label: 'Английский'),
                    DropdownMenuEntry(value: 'Russian', label: 'Русский'),
                  ],
                  inputDecorationTheme:
                      Theme.of(context).dropdownMenuTheme.inputDecorationTheme,
                  menuStyle: Theme.of(context).dropdownMenuTheme.menuStyle,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Temperature Units
            _SettingsTile(
              title: 'Единицы температуры',
              subtitle: 'Выберите единицы',
              trailing: IntrinsicWidth(
                child: DropdownMenu<String>(
                  initialSelection: _selectedTemperatureUnit,
                  onSelected: (value) {
                    if (value != null) {
                      setState(() => _selectedTemperatureUnit = value);
                    }
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'Celsius', label: '°C Celsius'),
                    DropdownMenuEntry(
                      value: 'Fahrenheit',
                      label: '°F Fahrenheit',
                    ),
                    DropdownMenuEntry(value: 'Kelvin', label: 'K Kelvin'),
                  ],
                  inputDecorationTheme:
                      Theme.of(context).dropdownMenuTheme.inputDecorationTheme,
                  menuStyle: Theme.of(context).dropdownMenuTheme.menuStyle,
                ),
              ),
            ), */
            ],
          ),
        ),
      ),
    );
  }

  void _onThemeModeChanged(BuildContext context, ThemeMode mode) {
    context.read<ThemeBloc>().add(ChangeThemeEvent(mode));
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
          trailing,
        ],
      ),
    );
  }
}
