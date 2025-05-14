import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:barista_helper/features/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ProfileBloc>(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Безопасность',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          centerTitle: false,
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdateSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      'Пароль успешно обновлен',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              _clearPasswordFields();
            }
            if (state is ProfileDeleteSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      'Аккаунт успешно удален',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/signin', (route) => false);
            }
            if (state is ProfileError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Change Password
                  _PasswordChangeForm(
                    currentPasswordController: _currentPasswordController,
                    newPasswordController: _newPasswordController,
                    confirmPasswordController: _confirmPasswordController,
                    isLoading: state is ProfileLoading,
                    onUpdatePressed: () => _updatePassword(context),
                  ),
                  const SizedBox(height: 24),

                  // Delete Account
                  _DeleteAccountSection(
                    onDeletePressed: () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _updatePassword(BuildContext context) {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Пароли не совпадают',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 2),
          ),
        );
      return;
    }

    context.read<ProfileBloc>().add(
      UpdateProfileEvent(
        username: '',
        email: '',
        oldPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      ),
    );
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Удалить аккаунт',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Text(
              'Вы уверены, что хотите удалить аккаунт? Это действие нельзя отменить.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Отмена',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(DeleteProfileEvent());
                  Navigator.pop(context);
                },
                child: Text(
                  'Удалить',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppTheme.errorRed),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class _PasswordChangeForm extends StatelessWidget {
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onUpdatePressed;

  const _PasswordChangeForm({
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onUpdatePressed,
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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Изменить пароль',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _PasswordField(
            controller: currentPasswordController,
            label: 'Текущий пароль',
            hint: 'Введите текущий пароль',
          ),
          const SizedBox(height: 16),
          _PasswordField(
            controller: newPasswordController,
            label: 'Новый пароль',
            hint: 'Введите новый пароль',
          ),
          const SizedBox(height: 16),
          _PasswordField(
            controller: confirmPasswordController,
            label: 'Подтвердите пароль',
            hint: 'Подтвердите новый пароль',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.activeGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : onUpdatePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          'Обновить пароль',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountSection extends StatelessWidget {
  final VoidCallback onDeletePressed;

  const _DeleteAccountSection({required this.onDeletePressed});

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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Удалить аккаунт',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Навсегда удалить ваш аккаунт и все данные',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onDeletePressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppTheme.errorRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Удалить аккаунт',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
