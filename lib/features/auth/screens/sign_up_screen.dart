import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';
import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void setLoading(bool loading) {
    setState(() => _isLoading = loading);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final authScreenBloc = context.read<AuthBloc>();
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Введите ваше имя',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.errorRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Введите корректный email',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.errorRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Пароль должен быть не менее 6 символов',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.errorRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Пароли не совпадают',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.errorRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setLoading(true);
    authScreenBloc.add(
      RegisterEvent(
        username: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      ),
    );
  }

  Widget buildAuthButton({
    required String text,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return Container(
      decoration: AppTheme.gradientButtonDecoration(context),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget buildAuthField({
    required String label,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextEditingController? controller,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
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
            fillColor: Theme.of(context).cardColor,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Создание аккаунта',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      centerTitle: false,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget buildBody(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          setLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
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
        if (state is Authenticated) {
          Navigator.of(
            context,
            rootNavigator: false,
          ).pushReplacementNamed('/profile');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: buildAppBar(context),
        body: buildBody([
          const SizedBox(height: 24),
          buildAuthField(
            label: 'Имя',
            hintText: 'Введите ваше имя',
            controller: _nameController,
            context: context,
          ),
          const SizedBox(height: 24),
          buildAuthField(
            label: 'Почта',
            hintText: 'Введите email',
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            context: context,
          ),
          const SizedBox(height: 24),
          buildAuthField(
            label: 'Пароль',
            hintText: 'Создайте пароль',
            obscureText: true,
            controller: _passwordController,
            context: context,
          ),
          const SizedBox(height: 24),
          buildAuthField(
            label: 'Подтверждение пароля',
            hintText: 'Подтвердите пароль',
            obscureText: true,
            controller: _confirmPasswordController,
            context: context,
          ),
          const SizedBox(height: 32),
          buildAuthButton(
            text: 'Создать аккаунт',
            onPressed: _signUp,
            context: context,
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}
