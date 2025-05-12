import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:barista_helper/domain/models/brewing_step.dart';
import 'package:barista_helper/domain/models/recipe_details.dart';
import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InteractiveBrewScreen extends StatefulWidget {
  final RecipeDetails recipe;

  const InteractiveBrewScreen({super.key, required this.recipe});

  @override
  State<InteractiveBrewScreen> createState() => _InteractiveBrewScreenState();
}

class _InteractiveBrewScreenState extends State<InteractiveBrewScreen> {
  int currentStepIndex = 0;
  bool isBrewing = false;
  int remainingSeconds = 0;
  int elapsedTime = 0;
  late int totalBrewTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeBrewing();
  }

  void _initializeBrewing() {
    if (widget.recipe.brewingSteps.isNotEmpty) {
      remainingSeconds = widget.recipe.brewingSteps[currentStepIndex].duration;
      totalBrewTime = widget.recipe.brewingSteps.fold(
        0,
        (sum, step) => sum + (step.duration),
      );
    }
    elapsedTime = 0;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isBrewing) return;

      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
          elapsedTime++;
        } else {
          _goToNextStep();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.recipe.brewingSteps.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.recipe.title),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        ),
        body: Center(
          child: Text(
            'Нет доступных шагов приготовления',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final currentStep = widget.recipe.brewingSteps[currentStepIndex];
    final nextSteps = widget.recipe.brewingSteps.sublist(currentStepIndex + 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe.title,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildTimerSection(context),
          _buildControlButtons(context, isDark),
          _buildProgressBar(context),
          _buildCurrentStepCard(context, currentStep, isDark),
          _buildNextStepsSection(context, nextSteps, isDark),
        ],
      ),
    );
  }

  Widget _buildTimerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(
            _formatTime(remainingSeconds),
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Прошло: ${_formatTime(elapsedTime)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: AppTheme.gradientButtonDecoration(),
            child: ElevatedButton(
              onPressed: _toggleBrewing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isBrewing ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBrewing ? 'Пауза' : 'Старт',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: _goToNextStep,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: Row(
              children: [
                Text(
                  'Следующий шаг',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color:
                        isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: LinearProgressIndicator(
        value: totalBrewTime > 0 ? elapsedTime / totalBrewTime : 0,
        backgroundColor: Theme.of(context).dividerColor,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        minHeight: 4,
      ),
    );
  }

  Widget _buildCurrentStepCard(
    BuildContext context,
    BrewingStep step,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.grey[800]
                : Colors.white, // Более светлый серый фон для светлой темы
        borderRadius: BorderRadius.circular(12),
        // Убрана обводка
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.grey[850]
                      : Colors.grey[300], // Обновленный фон иконки
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              step.type.iconPath,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : Colors.black, // Обновленный цвет иконки
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (step.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsSection(
    BuildContext context,
    List<BrewingStep> nextSteps,
    bool isDark,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Следующие шаги',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: nextSteps.length,
              itemBuilder: (context, index) {
                final step = nextSteps[index];
                return _buildNextStepItem(context, step, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepItem(
    BuildContext context,
    BrewingStep step,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppTheme.cardDecoration(color: Theme.of(context).cardColor),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.grey[800]
                    : Colors.grey[300], // Обновленный фон иконки
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset(
            step.type.iconPath,
            colorFilter: ColorFilter.mode(
              isDark ? Colors.white : Colors.black, // Обновленный цвет иконки
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(step.title, style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(
          step.description,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
        ),
        trailing: Text(
          _formatTime(step.duration),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white : AppTheme.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _toggleBrewing() {
    setState(() {
      isBrewing = !isBrewing;
    });
    _startTimer();
  }

  void _goToNextStep() {
    if (currentStepIndex < widget.recipe.brewingSteps.length - 1) {
      setState(() {
        elapsedTime += remainingSeconds;
        currentStepIndex++;
        remainingSeconds =
            widget.recipe.brewingSteps[currentStepIndex].duration;
      });
    } else {
      Navigator.of(context, rootNavigator: false).pushReplacementNamed(
        '/brewComplete',
        arguments: {
          'recipe': widget.recipe,
          'totalTime': _formatTime(totalBrewTime),
        },
      );
    }
  }
}
