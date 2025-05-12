import 'package:barista_helper/domain/models/brewing_step.dart';
import 'package:barista_helper/domain/models/grind_size.dart';
import 'package:flutter/material.dart';

class RecipeDetails {
  final int id;
  final String title;
  final String method;
  final String difficulty;
  final Color difficultyColor;
  final int likes;
  final bool liked;
  final int time;
  final String author;
  final int authorId;
  final String description;
  final int coffeeAmount;
  final GrindSizeType coffeeGrind;
  final int waterAmount;
  final int waterTemp;
  final String ratio;
  final List<BrewingStep> brewingSteps;

  RecipeDetails({
    required this.id,
    required this.title,
    required this.method,
    required this.difficulty,
    required this.difficultyColor,
    required this.likes,
    required this.liked,
    required this.time,
    required this.author,
    required this.authorId,
    required this.description,
    required this.coffeeAmount,
    required this.coffeeGrind,
    required this.waterAmount,
    required this.waterTemp,
    required this.ratio,
    required this.brewingSteps,
  });

  RecipeDetails copyWith({
    int? id,
    String? title,
    String? method,
    String? difficulty,
    Color? difficultyColor,
    int? likes,
    bool? liked,
    int? time,
    String? author,
    int? authorId,
    String? description,
    int? coffeeAmount,
    GrindSizeType? coffeeGrind,
    int? waterAmount,
    int? waterTemp,
    String? ratio,
    List<BrewingStep>? brewingSteps,
  }) {
    return RecipeDetails(
      id: id ?? this.id,
      title: title ?? this.title,
      method: method ?? this.method,
      difficulty: difficulty ?? this.difficulty,
      difficultyColor: difficultyColor ?? this.difficultyColor,
      likes: likes ?? this.likes,
      liked: liked ?? this.liked,
      time: time ?? this.time,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      description: description ?? this.description,
      coffeeAmount: coffeeAmount ?? this.coffeeAmount,
      coffeeGrind: coffeeGrind ?? this.coffeeGrind,
      waterAmount: waterAmount ?? this.waterAmount,
      waterTemp: waterTemp ?? this.waterTemp,
      ratio: ratio ?? this.ratio,
      brewingSteps: brewingSteps ?? this.brewingSteps,
    );
  }

  factory RecipeDetails.fromJson(Map<String, dynamic> json) {
    final double ratioValue =
        json['waterAmount'] > 0 && json['coffeeWeight'] > 0
            ? json['waterAmount'] / json['coffeeWeight']
            : 0;

    return RecipeDetails(
      id: json['id'],
      title: json['name'],
      method: '',
      difficulty: _capitalizeFirstLetter(json['difficulty']),
      difficultyColor: getDifficultyColor(json['difficulty']),
      likes: json['likes'],
      liked: json['liked'],
      time: json['totalTime'],
      author: json['authorName'],
      authorId: json['authorId'],
      description: json['description'],
      coffeeAmount: json['coffeeWeight'],
      coffeeGrind: _parseGrind(json['grindSize']),
      waterAmount: json['waterAmount'],
      waterTemp: json['waterTemperature'],
      ratio: ratioValue.toStringAsFixed(1),
      brewingSteps:
          (json['steps'] as List<dynamic>?)
              ?.map((step) => BrewingStep.fromJson(step))
              .toList() ??
          [],
    );
  }

  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'EASY':
      case 'ЛЕГКО':
        return Colors.green;
      case 'MEDIUM':
      case 'СРЕДНЕ':
        return Colors.indigo;
      case 'HARD':
      case 'СЛОЖНО':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String _capitalizeFirstLetter(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static GrindSizeType _parseGrind(String grind) {
    switch (grind.toUpperCase()) {
      case 'FINE':
        return GrindSizeType.fine;
      case 'MEDIUMFINE':
        return GrindSizeType.mediumFine;
      case 'MEDIUM':
        return GrindSizeType.medium;
      case 'MEDIUMCOARSE':
        return GrindSizeType.mediumCoarse;
      case 'COARSE':
        return GrindSizeType.coarse;
      default:
        return GrindSizeType.none;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': title,
    'brewingMethod': method,
    'difficulty': difficulty,
    'likes': likes,
    'totalTime': time,
    'authorName': author,
    'description': description,
    'coffeeWeight': coffeeAmount,
    'grindSize': coffeeGrind.name,
    'waterAmount': waterAmount,
    'waterTemperature': waterTemp,
    'steps': brewingSteps.map((step) => step.toJson()).toList(),
  };

  String formatTime() {
    final minutes = (time / 60).floor();
    final remainingSeconds = time % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
