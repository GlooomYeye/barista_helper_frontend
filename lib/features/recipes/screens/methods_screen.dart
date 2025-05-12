import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:barista_helper/domain/models/brewing_method.dart';
import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';

class MethodsScreen extends StatefulWidget {
  const MethodsScreen({super.key});

  @override
  MethodsScreenState createState() => MethodsScreenState();
}

class MethodsScreenState extends State<MethodsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Методы заваривания',
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: _buildGrid(BrewingMethod.values),
    );
  }

  Widget _buildGrid(List<BrewingMethod> methods) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = 2;
        final isLastItemCentered = methods.length % crossAxisCount == 1;
        final cardWidth = (constraints.maxWidth - 48) / 2;

        if (!isLastItemCentered) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: methods.length,
            itemBuilder: (context, index) {
              return _BrewingMethodCard(method: methods[index]);
            },
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: methods.length - 1,
                itemBuilder: (context, index) {
                  return _BrewingMethodCard(method: methods[index]);
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: cardWidth,
                  height: cardWidth,
                  child: _BrewingMethodCard(method: methods.last),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrewingMethodCard extends StatelessWidget {
  final BrewingMethod method;

  const _BrewingMethodCard({required this.method});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).shadowColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.all(
          Theme.of(context).highlightColor.withAlpha((0.1 * 255).round()),
        ),
        highlightColor: Theme.of(
          context,
        ).highlightColor.withAlpha((0.05 * 255).round()),
        onTap: () {
          final authBloc = GetIt.I<AuthBloc>();

          if ((method == BrewingMethod.favorites ||
                  method == BrewingMethod.created) &&
              authBloc.state is! Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Войдите, чтобы просмотреть ${method == BrewingMethod.favorites ? 'избранные' : 'созданные'} рецепты',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                backgroundColor: AppTheme.errorRed,
                duration: const Duration(seconds: 1),
              ),
            );
          } else {
            Navigator.of(
              context,
              rootNavigator: false,
            ).pushNamed('/recipes', arguments: method);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SvgPicture.asset(
                  method.getIconPath(isDark),
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                method.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
