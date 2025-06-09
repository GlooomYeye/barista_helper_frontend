import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';

import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:barista_helper/features/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    final profileBloc = context.read<AuthBloc>();
    final user = (profileBloc.state as Authenticated).user;
    _nameController = TextEditingController(text: user.username);
    _emailController = TextEditingController(text: user.email);
    super.initState();
  }

  void _saveChanges() {
    final currentState = context.read<ProfileBloc>().state;
    if (currentState is! ProfileLoaded) return;
    context.read<ProfileBloc>().add(
      UpdateProfileEvent(
        username: _nameController.text,
        email: _emailController.text,
        oldPassword: '',
        newPassword: '',
        newPasswordConfirmation: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
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
                duration: const Duration(seconds: 2),
              ),
            );
        }
        if (state is ProfileUpdateSuccess) {
          context.read<AuthBloc>().add(
            UpdateUserEvent(
              username: _nameController.text,
              email: _emailController.text,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Профиль успешно обновлен',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Редактировать профиль',
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
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
              const SizedBox(height: 32),

              Container(
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
                  children: [
                    _SettingsInputField(
                      controller: _nameController,
                      label: 'Полное имя',
                      hintText: 'Введите ваше имя',
                    ),
                    const SizedBox(height: 24),
                    _SettingsInputField(
                      controller: _emailController,
                      label: 'Эл. почта',
                      hintText: 'Введите вашу почту',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<ProfileBloc, ProfileState>(
                        bloc: context.read<ProfileBloc>(),
                        builder: (context, state) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.activeGradient(context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  state is ProfileLoading ? null : _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                disabledBackgroundColor: Colors.grey[400],
                              ),
                              child:
                                  state is ProfileLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Text(
                                        'Сохранить изменения',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

class _SettingsInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;

  const _SettingsInputField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
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
