import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';

import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:barista_helper/features/profile/bloc/profile_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    final profileScreenBloc = context.read<ProfileBloc>();
    profileScreenBloc.add(LoadProfileEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Профиль',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileDeleteSuccess) {
            context.read<AuthBloc>().add(LogoutEvent());
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/signin',
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
              ),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Text(
                "Что-то пошло не так",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          if (state is ProfileLoaded || state is ProfileUpdateSuccess) {
            final user =
                state is ProfileLoaded
                    ? state.user
                    : (state as ProfileUpdateSuccess).user;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.activeGradient(context),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.account_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.username,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _ProfileTile(
                    title: 'Настройки аккаунта',
                    subtitle: 'Личная информация',
                    icon: Icons.account_circle,
                    onTap:
                        () => Navigator.of(
                          context,
                          rootNavigator: false,
                        ).pushNamed('/accountSettings'),
                  ),
                  const SizedBox(height: 12),
                  _ProfileTile(
                    title: 'Внешний вид',
                    subtitle: 'Тёмная тема, оформление',
                    icon: Icons.color_lens,
                    onTap:
                        () => Navigator.of(
                          context,
                          rootNavigator: false,
                        ).pushNamed('/appearance'),
                  ),
                  const SizedBox(height: 12),
                  _ProfileTile(
                    title: 'Безопасность',
                    subtitle: 'Пароль, защита',
                    icon: Icons.lock,
                    onTap:
                        () => Navigator.of(
                          context,
                          rootNavigator: false,
                        ).pushNamed('/privacy'),
                  ),
                  /*                   const SizedBox(height: 12),
                  _ProfileTile(
                    title: 'Помощь',
                    subtitle: 'Вопросы и ответы',
                    icon: Icons.help_center,
                    onTap:
                        () => Navigator.of(
                          context,
                          rootNavigator: false,
                        ).pushNamed('/help'),
                  ), */
                  const SizedBox(height: 24),
                  _LogoutTile(),
                ],
              ),
            );
          }

          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.activeGradient(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Сохраняем ссылку на BuildContext перед асинхронным вызовом
        final currentContext = context;
        final shouldLogout = await _showLogoutDialog(currentContext);
        // Проверяем, смонтирован ли виджет, перед использованием BuildContext
        if (shouldLogout == true && currentContext.mounted) {
          currentContext.read<AuthBloc>().add(LogoutEvent());
          Navigator.of(
            currentContext,
            rootNavigator: false,
          ).pushReplacementNamed('/signin');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.exit_to_app,
                color: AppTheme.errorRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Выйти',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppTheme.errorRed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выйти',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Вы уверены, что хотите выйти?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Отмена',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.activeGradient(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Выйти',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
