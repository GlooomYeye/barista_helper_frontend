import 'dart:convert';
import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:barista_helper/domain/models/brewing_method.dart';
import 'package:barista_helper/domain/models/brewing_step.dart';
import 'package:barista_helper/domain/models/grind_size.dart';
import 'package:barista_helper/domain/models/recipe_details.dart';
import 'package:barista_helper/domain/models/step_type.dart';
import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';

import 'package:barista_helper/features/recipes/bloc/recipe_create_bloc.dart';
import 'package:barista_helper/features/recipes/bloc/recipe_details_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateRecipeScreen extends StatefulWidget {
  final bool isEditing;
  final RecipeDetails? initialRecipe;

  const CreateRecipeScreen({
    super.key,
    this.isEditing = false,
    this.initialRecipe,
  });

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxStepDescriptionLength = 300;
  static const String draftKey = 'recipe_draft';

  bool _isSubmitting = false;
  bool _isDeleting = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coffeeAmountController = TextEditingController();
  final _waterAmountController = TextEditingController();
  final _waterTempController = TextEditingController();

  BrewingMethod _selectedBrewMethod = BrewingMethod.espresso;
  GrindSizeType _selectedGrindSize = GrindSizeType.MEDIUM;
  String _difficulty = 'Легко';
  List<BrewingStep> _steps = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.initialRecipe != null) {
      _nameController.text = widget.initialRecipe!.title;
      _descriptionController.text = widget.initialRecipe!.description;
      _coffeeAmountController.text =
          widget.initialRecipe!.coffeeAmount.toString();
      _waterAmountController.text =
          widget.initialRecipe!.waterAmount.toString();
      _waterTempController.text = widget.initialRecipe!.waterTemp.toString();
      _selectedGrindSize = widget.initialRecipe!.coffeeGrind;
      _difficulty = widget.initialRecipe!.difficulty;
      _steps = List.from(widget.initialRecipe!.brewingSteps);
    } else {
      _loadDraft();
    }
    _addFieldListeners();
  }

  void _addFieldListeners() {
    void saveDraftListener() {
      _saveDraft();
    }

    _nameController.addListener(saveDraftListener);
    _descriptionController.addListener(saveDraftListener);
    _coffeeAmountController.addListener(saveDraftListener);
    _waterAmountController.addListener(saveDraftListener);
    _waterTempController.addListener(saveDraftListener);
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftJson = prefs.getString(draftKey);
    if (draftJson != null) {
      final draft = jsonDecode(draftJson) as Map<String, dynamic>;
      setState(() {
        _nameController.text = draft['name'] ?? '';
        _descriptionController.text = draft['description'] ?? '';
        _coffeeAmountController.text = draft['coffeeAmount'] ?? '';
        _waterAmountController.text = draft['waterAmount'] ?? '';
        _waterTempController.text = draft['waterTemp'] ?? '';
        _selectedBrewMethod = BrewingMethod.values[draft['brewMethod'] ?? 0];
        _selectedGrindSize = GrindSizeType.values[draft['grindSize'] ?? 0];
        _difficulty = draft['difficulty'] ?? 'Легко';
      });
    }
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'coffeeAmount': _coffeeAmountController.text,
      'waterAmount': _waterAmountController.text,
      'waterTemp': _waterTempController.text,
      'brewMethod': _selectedBrewMethod.index,
      'grindSize': _selectedGrindSize.index,
      'difficulty': _difficulty,
    };
    await prefs.setString(draftKey, jsonEncode(draft));
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(draftKey);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _coffeeAmountController.dispose();
    _waterAmountController.dispose();
    _waterTempController.dispose();
    super.dispose();
  }

  Future<void> _showStepDialog({BrewingStep? initialStep, int? index}) async {
    final result = await showDialog<BrewingStep>(
      context: context,
      builder: (BuildContext context) {
        return _BrewingStepDialog(
          initialStep: initialStep,
          isDark: Theme.of(context).brightness == Brightness.dark,
        );
      },
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          _steps[index] = result;
        } else {
          _steps.add(result);
        }
      });
    }
  }

  void _removeBrewingStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coffeeAmount = double.tryParse(_coffeeAmountController.text) ?? 0;
    final waterAmount = double.tryParse(_waterAmountController.text) ?? 1;
    final ratio =
        coffeeAmount <= 0 ? 0.0 : (waterAmount / coffeeAmount).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Сохранить изменения' : 'Создать рецепт',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfoSection(ratio, isDark),
                  const SizedBox(height: 16),
                  _buildBrewingStepsSection(isDark),
                ],
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Удаление рецепта'),
            content: const Text('Вы действительно хотите удалить рецепт?'),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  setState(() => _isDeleting = true);
                  Navigator.of(context).pop();
                  GetIt.I.get<CreateRecipeBloc>().add(
                    DeleteRecipeEvent(widget.initialRecipe!.id),
                  );
                },
              ),
            ],
          ),
    );
  }

  Widget _buildBasicInfoSection(double ratio, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(color: Theme.of(context).cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Название рецепта',
                  _nameController,
                  maxLength: maxNameLength,
                  isDark: isDark,
                ),
              ),
              if (widget.isEditing &&
                  widget.initialRecipe != null &&
                  widget.initialRecipe!.authorId ==
                      (GetIt.I<AuthBloc>().state as Authenticated).user.id) ...[
                const SizedBox(width: 28),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  padding: const EdgeInsets.fromLTRB(8, 28, 8, 8),
                  constraints: const BoxConstraints(),
                  iconSize: 28,
                  onPressed: _showDeleteDialog,
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Описание',
            _descriptionController,
            maxLines: 3,
            maxLength: maxDescriptionLength,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          _buildBrewMethodAndDifficultyRow(isDark),
          const SizedBox(height: 16),
          _buildCoffeeAmountAndGrindSizeRow(isDark),
          const SizedBox(height: 16),
          _buildWaterAmountAndTempRow(),
          const SizedBox(height: 16),
          _buildRatioDisplay(ratio, isDark),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int? maxLines,
    int? maxLength,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Обязательно';
            }
            if (maxLength != null && value.length > maxLength) {
              return 'Не более $maxLength символов';
            }
            return null;
          },
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            errorStyle: const TextStyle(fontSize: 12),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildBrewMethodAndDifficultyRow(bool isDark) {
    return Row(
      children: [
        _buildBrewMethodDropdown(isDark),
        const SizedBox(width: 16),
        _buildDifficultySelector(isDark),
      ],
    );
  }

  Widget _buildBrewMethodDropdown(bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Способ приготовления',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 8),
          DropdownMenu<BrewingMethod>(
            width: MediaQuery.of(context).size.width * 0.43,
            initialSelection: _selectedBrewMethod,
            onSelected: (value) {
              if (value != null) {
                setState(() => _selectedBrewMethod = value);
                _saveDraft();
              }
            },
            dropdownMenuEntries:
                BrewingMethod.values
                    .where(
                      (method) =>
                          method != BrewingMethod.values[0] &&
                          method != BrewingMethod.values[1],
                    )
                    .map(
                      (method) =>
                          DropdownMenuEntry(value: method, label: method.title),
                    )
                    .toList(),
            inputDecorationTheme: Theme.of(
              context,
            ).dropdownMenuTheme.inputDecorationTheme?.copyWith(
              fillColor: Theme.of(
                context,
              ).scaffoldBackgroundColor.withAlpha((0.5 * 255).round()),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
                  width: 1.5,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            menuStyle: Theme.of(context).dropdownMenuTheme.menuStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Сложность',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  ['Легко', 'Средне', 'Сложно'].map((level) {
                    final isSelected = _difficulty == level;
                    return GestureDetector(
                      onTap:
                          () => setState(() {
                            _difficulty = level;
                            _saveDraft();
                          }),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? RecipeDetails.getDifficultyColor(level)
                                  : RecipeDetails.getDifficultyColor(
                                    level,
                                  ).withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.bar_chart,
                          color:
                              isSelected
                                  ? Colors.white
                                  : RecipeDetails.getDifficultyColor(level),
                          size: 20,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoffeeAmountAndGrindSizeRow(bool isDark) {
    return Row(
      children: [
        _buildNumberInputField(
          'Количество кофе',
          _coffeeAmountController,
          'г',
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _buildGrindSizeDropdown(isDark),
      ],
    );
  }

  Widget _buildNumberInputField(
    String label,
    TextEditingController controller,
    String suffix, {
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Обязательно';
              }
              final num = int.tryParse(value);
              if (num == null || num <= 0) {
                return 'Неверное значение';
              }
              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.dividerColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.dividerColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
                  width: 1.5,
                ),
              ),
              suffixText: suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              errorStyle: const TextStyle(fontSize: 12),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            style: Theme.of(context).textTheme.bodyMedium,
            onChanged:
                (_) => setState(() {
                  _saveDraft();
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildGrindSizeDropdown(bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Помол',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 8),
          DropdownMenu<GrindSizeType>(
            width: MediaQuery.of(context).size.width * 0.43,
            initialSelection: _selectedGrindSize,
            onSelected: (value) {
              if (value != null) {
                setState(() => _selectedGrindSize = value);
                _saveDraft();
              }
            },
            dropdownMenuEntries:
                GrindSizeType.values
                    .map(
                      (size) =>
                          DropdownMenuEntry(value: size, label: size.title),
                    )
                    .toList(),
            inputDecorationTheme: Theme.of(
              context,
            ).dropdownMenuTheme.inputDecorationTheme?.copyWith(
              fillColor: Theme.of(
                context,
              ).scaffoldBackgroundColor.withAlpha((0.5 * 255).round()),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
                  width: 1.5,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            menuStyle: Theme.of(context).dropdownMenuTheme.menuStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildWaterAmountAndTempRow() {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark; // Определяем isDark здесь
    return Row(
      children: [
        _buildNumberInputField(
          'Количество воды',
          _waterAmountController,
          'мл',
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _buildNumberInputField(
          'Температура воды',
          _waterTempController,
          '°C',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildRatioDisplay(double ratio, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Соотношение кофе к воде',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          const SizedBox(width: 8), // Добавим небольшой отступ между текстами
          Expanded(
            child: Text(
              ratio <= 0
                  ? 'Неверное соотношение'
                  : '1:${ratio.toStringAsFixed(1)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end, // Выравнивание по правому краю
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrewingStepsSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(color: Theme.of(context).cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Шаги приготовления',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_steps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'Добавьте шаги приготовления',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                return _buildBrewingStepListItem(step, index, isDark);
              },
            ),
          const SizedBox(height: 16),
          Center(child: _buildAddStepButton()),
        ],
      ),
    );
  }

  Widget _buildBrewingStepListItem(BrewingStep step, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            isDark ? Theme.of(context).cardColor.withAlpha(200) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha((0.5 * 255).round()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).shadowColor.withAlpha((isDark ? 0.15 * 255 : 0.08 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showStepDialog(initialStep: step, index: index),
          borderRadius: BorderRadius.circular(12),
          splashColor: (isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue)
              .withAlpha((0.1 * 255).round()),
          highlightColor: (isDark
                  ? AppTheme.primaryGreen
                  : AppTheme.primaryBlue)
              .withAlpha((0.05 * 255).round()),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Шаг ${index + 1}: ${step.title}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent[100],
                        size: 22,
                      ),
                      onPressed: () => _removeBrewingStep(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Удалить шаг',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40, // Applied width from details screen
                      height: 40, // Applied height from details screen
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.grey[800]
                                : Colors
                                    .grey[200], // Applied background color from details screen
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(
                        step.type.iconPath,
                        colorFilter: ColorFilter.mode(
                          isDark
                              ? Colors.white
                              : Colors
                                  .black, // Applied icon color from details screen
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.description.isEmpty
                            ? 'Нет описания'
                            : step.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).hintColor.withAlpha((0.8 * 255).round()),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Длительность: ${step.duration} сек',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddStepButton() {
    return Container(
      decoration: AppTheme.gradientButtonDecoration(context),
      child: ElevatedButton.icon(
        onPressed: () => _showStepDialog(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            Colors.white.withAlpha((0.2 * 255).round()),
          ),
        ),
        icon: const Icon(
          Icons.add_circle_outline,
          color: Colors.white,
          size: 22,
        ),
        label: Text(
          'Добавить шаг',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final authBloc = GetIt.I<AuthBloc>();
    final createBloc = GetIt.I<CreateRecipeBloc>();

    return BlocConsumer<CreateRecipeBloc, CreateRecipeState>(
      bloc: createBloc,
      listener: (context, state) {
        if (state is CreateRecipeSuccess) {
          _clearDraft();
          String message;
          if (_isDeleting) {
            message = 'Рецепт успешно удален';
            _isDeleting = false;

            Navigator.of(context)
              ..pop()
              ..pop();
          } else {
            Navigator.of(context).pop();
            if (widget.isEditing) {
              message = 'Рецепт успешно обновлен';
              GetIt.I<RecipeDetailsBloc>().add(
                LoadRecipeDetails(widget.initialRecipe!.id),
              );
            } else {
              message = 'Рецепт успешно создан';
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.greenAccent[700],
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
            ),
          );
        } else if (state is CreateRecipeError) {
          setState(() {
            _isSubmitting = false;
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppTheme.errorRed,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
            ),
          );
        }
      },
      builder: (context, state) {
        return Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            decoration: AppTheme.gradientButtonDecoration(context),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isSubmitting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                if (!_isSubmitting)
                  ElevatedButton(
                    onPressed: () {
                      if (authBloc.state is Authenticated) {
                        setState(() => _isSubmitting = true);
                        _submitForm();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Пожалуйста, войдите в систему для создания рецептов',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: AppTheme.errorRed,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(10),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.isEditing
                              ? 'Редактировать рецепт'
                              : 'Создать рецепт',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _validateBasicInfo() {
    if (_nameController.text.isEmpty) {
      return 'Введите название рецепта';
    }
    if (_nameController.text.length > maxNameLength) {
      return 'Название рецепта не может превышать $maxNameLength символов';
    }
    if (_descriptionController.text.isEmpty) {
      return 'Введите описание рецепта';
    }
    if (_descriptionController.text.length > maxDescriptionLength) {
      return 'Описание не может превышать $maxDescriptionLength символов';
    }
    return null;
  }

  String? _validateAmounts() {
    final coffeeAmount = int.tryParse(_coffeeAmountController.text);
    if (coffeeAmount == null || coffeeAmount <= 0) {
      return 'Введите корректное количество кофе (положительное число)';
    }

    final waterAmount = int.tryParse(_waterAmountController.text);
    if (waterAmount == null || waterAmount <= 0) {
      return 'Введите корректное количество воды (положительное число)';
    }

    final waterTemp = int.tryParse(_waterTempController.text);
    if (waterTemp == null || waterTemp < 70 || waterTemp > 100) {
      return 'Введите корректную температуру воды (70-100°C)';
    }

    return null;
  }

  String? _validateSteps() {
    if (_steps.isEmpty) {
      return 'Добавьте хотя бы один шаг приготовления';
    }

    for (var i = 0; i < _steps.length; i++) {
      final step = _steps[i];
      if (step.description.isEmpty) {
        // Added check for empty description
        return 'Описание для шага ${i + 1} обязательно';
      }
      if (step.description.length > maxStepDescriptionLength) {
        return 'Описание шага ${i + 1} не может превышать $maxStepDescriptionLength символов';
      }
      if (step.duration <= 0) {
        return 'Введите корректную длительность для шага ${i + 1}';
      }
    }

    return null;
  }

  String _calculateRatio() {
    final coffeeAmount = double.tryParse(_coffeeAmountController.text);
    final waterAmount = double.tryParse(_waterAmountController.text);

    if (coffeeAmount == null || coffeeAmount <= 0) {
      return '1:0';
    }

    if (waterAmount == null || waterAmount <= 0) {
      return '1:0';
    }

    return '1:${(waterAmount / coffeeAmount).toStringAsFixed(1)}';
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = false);
      return;
    }

    final basicInfoError = _validateBasicInfo();
    if (basicInfoError != null) {
      _showError(basicInfoError);
      setState(() => _isSubmitting = false);
      return;
    }

    final amountsError = _validateAmounts();
    if (amountsError != null) {
      _showError(amountsError);
      setState(() => _isSubmitting = false);
      return;
    }

    final stepsError = _validateSteps();
    if (stepsError != null) {
      _showError(stepsError);
      setState(() => _isSubmitting = false);
      return;
    }

    final difficulty =
        _difficulty == 'Легко'
            ? 'EASY'
            : _difficulty == 'Средне'
            ? 'MEDIUM'
            : _difficulty == 'Сложно'
            ? 'HARD'
            : 'EASY';

    final recipeDetails = RecipeDetails(
      id: widget.isEditing ? widget.initialRecipe!.id : 0,
      title: _nameController.text,
      method: _selectedBrewMethod.enumName,
      difficulty: difficulty,
      difficultyColor: _getDifficultyColor(),
      likes: widget.isEditing ? widget.initialRecipe!.likes : 0,
      liked: widget.isEditing ? widget.initialRecipe!.liked : false,
      time: _steps.fold(0, (sum, step) => sum + step.duration),
      author: (GetIt.I<AuthBloc>().state as Authenticated).user.username,
      authorId: (GetIt.I<AuthBloc>().state as Authenticated).user.id,
      description: _descriptionController.text,
      coffeeAmount: double.tryParse(_coffeeAmountController.text) ?? 0,
      coffeeGrind: _selectedGrindSize,
      waterAmount: int.tryParse(_waterAmountController.text) ?? 0,
      waterTemp: int.tryParse(_waterTempController.text) ?? 0,
      ratio: _calculateRatio(),
      brewingSteps: _steps,
    );

    try {
      GetIt.I.get<CreateRecipeBloc>().add(
        SubmitRecipeEvent(recipeDetails, isEditing: widget.isEditing),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showError('Не удалось создать рецепт. Попробуйте снова.');
    }
  }

  Color _getDifficultyColor() {
    switch (_difficulty) {
      case 'Легко':
        return Colors.green;
      case 'Средне':
        return Colors.indigo;
      case 'Сложно':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.errorRed,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}

class _BrewingStepDialog extends StatefulWidget {
  final BrewingStep? initialStep;
  final bool isDark;

  const _BrewingStepDialog({this.initialStep, required this.isDark});

  @override
  State<_BrewingStepDialog> createState() => _BrewingStepDialogState();
}

class _BrewingStepDialogState extends State<_BrewingStepDialog> {
  final _formKey = GlobalKey<FormState>();
  late BrewingStepType _selectedType;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialStep?.type ?? BrewingStepType.heatEquipment;
    _descriptionController = TextEditingController(
      text: widget.initialStep?.description ?? '',
    );
    _durationController = TextEditingController(
      text: widget.initialStep?.duration.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String hintText,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: theme.scaffoldBackgroundColor.withAlpha((0.5 * 255).round()),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.dividerColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.dividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color:
              isDark
                  ? AppTheme.primaryGreen
                  : AppTheme.primaryBlue, // Dynamic focused border color
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dialogWidth = MediaQuery.of(context).size.width * 0.9;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).cardColor,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      title: Row(
        children: [
          Icon(
            widget.initialStep == null
                ? Icons.add_circle_outline
                : Icons.edit_outlined,
            color: widget.isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
          ),
          const SizedBox(width: 12),
          Text(
            widget.initialStep == null ? 'Добавить шаг' : 'Редактировать шаг',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Тип шага',
                  style: textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownMenu<BrewingStepType>(
                  initialSelection: _selectedType,
                  onSelected: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                  dropdownMenuEntries:
                      BrewingStepType.values
                          .map(
                            (type) => DropdownMenuEntry(
                              value: type,
                              label: type.title,
                            ),
                          )
                          .toList(),
                  inputDecorationTheme: Theme.of(
                    context,
                  ).dropdownMenuTheme.inputDecorationTheme?.copyWith(
                    fillColor: Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withAlpha((0.5 * 255).round()),
                    focusedBorder: OutlineInputBorder(
                      // Also apply dynamic border to dropdown
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color:
                            widget.isDark
                                ? AppTheme.primaryGreen
                                : AppTheme.primaryBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                  menuStyle: Theme.of(
                    context,
                  ).dropdownMenuTheme.menuStyle?.copyWith(
                    backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).cardColor,
                    ),
                  ),
                  width: dialogWidth - 48,
                  textStyle: textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'Описание',
                  style: textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  maxLength: _CreateRecipeScreenState.maxStepDescriptionLength,
                  style: textTheme.bodyMedium,
                  decoration: _inputDecoration(
                    context,
                    '',
                    widget.isDark,
                  ).copyWith(counterText: ''),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      // Added mandatory validation
                      return 'Обязательно';
                    }
                    if (value.length >
                        _CreateRecipeScreenState.maxStepDescriptionLength) {
                      return 'Максимум ${_CreateRecipeScreenState.maxStepDescriptionLength} символов';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Длительность (секунды)',
                  style: textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  style: textTheme.bodyMedium,
                  decoration: _inputDecoration(context, '', widget.isDark),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Обязательно';
                    }
                    final duration = int.tryParse(value);
                    if (duration == null || duration <= 0) {
                      return 'Неверное значение';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).hintColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            textStyle: textTheme.labelLarge,
          ),
          child: const Text('Отмена'),
        ),
        Container(
          decoration: AppTheme.gradientButtonDecoration(context),
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.save_alt_outlined,
              size: 20,
              color: Colors.white,
            ),
            label: Text(
              'Сохранить',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newStep = BrewingStep(
                  type: _selectedType,
                  title: _selectedType.title,
                  description: _descriptionController.text,
                  duration: int.parse(_durationController.text),
                );
                Navigator.of(context).pop(newStep);
              }
            },
          ),
        ),
      ],
    );
  }
}
