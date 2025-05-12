import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';
import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void setLoading(bool loading) {
    setState(() => _isLoading = loading);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final authScreenBloc = context.read<AuthBloc>();

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Введите корректный email',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Пароль должен быть не менее 4 символов',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }
    setLoading(true);
    authScreenBloc.add(
      LoginEvent(
        login: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  Widget buildAuthButton({
    required String text,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return Container(
      decoration: AppTheme.gradientButtonDecoration(),
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
                ? SizedBox(
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
          'Профиль',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      centerTitle: false,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          setLoading(false);

          String snackBarMessage = state.message;
          if (state.message == "Exception: Authentication failed") {
            snackBarMessage = "Неверная почта или пароль";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                snackBarMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
              backgroundColor: AppTheme.errorRed,
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
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: AppTheme.iconDecoration(),
              child: Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          buildAuthField(
            label: 'Email',
            hintText: 'Введите email',
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            context: context,
          ),
          const SizedBox(height: 24),
          buildAuthField(
            label: 'Пароль',
            hintText: 'Введите пароль',
            obscureText: true,
            controller: _passwordController,
            context: context,
          ),
          const SizedBox(height: 32),
          buildAuthButton(text: 'Войти', onPressed: _signIn, context: context),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Нет аккаунта? ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              GestureDetector(
                onTap:
                    () => Navigator.of(
                      context,
                      rootNavigator: false,
                    ).pushNamed('/signup'),
                child: Text(
                  'Зарегистрироваться',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
