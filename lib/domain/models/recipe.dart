import 'package:flutter/material.dart';

class Recipe {
  final int id;
  final String title;
  final int time;
  final String difficulty;
  final Color difficultyColor;
  final String description;
  final int likes;
  final bool liked;

  Recipe({
    required this.id,
    required this.title,
    required this.time,
    required this.difficulty,
    required this.difficultyColor,
    required this.description,
    required this.likes,
    required this.liked,
  });
  factory Recipe.fromJson(Map<String, dynamic> json) {
    final String difficultyString = _capitalizeFirstLetter(
      json['difficulty'].toString().toLowerCase(),
    );
    final Color difficultyColor = _getDifficultyColor(json['difficulty']);

    return Recipe(
      id: json['id'],
      title: json['name'] as String,
      time: json['totalTime'] as int,
      difficulty: difficultyString,
      difficultyColor: difficultyColor,
      description: json['description'] as String,
      likes: json['likes'] as int,
      liked: json['liked'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'totalTime': time,
    'difficulty': difficulty,
    'difficultyColor': difficultyColor,
    'description': description,
    'likes': likes,
  };
  static Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'EASY':
        return Colors.green;
      case 'MEDIUM':
        return Colors.indigo;
      case 'HARD':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String _capitalizeFirstLetter(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String formatTime() {
    final minutes = (time / 60).floor();
    final remainingSeconds = time % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
