import 'package:barista_helper/domain/models/step_type.dart';

class BrewingStep {
  final BrewingStepType type;
  final String title;
  final String description;
  final int duration;

  BrewingStep({
    required this.type,
    required this.title,
    required this.description,
    required this.duration,
  });

  factory BrewingStep.fromJson(Map<String, dynamic> json) {
    return BrewingStep(
      type: _parseStepType(json['type']),
      title: _getStepTitle(json['type']),
      description: json['description'] ?? '',
      duration: json['time'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.enumName,
    'description': description,
    'time': duration,
  };

  static BrewingStepType _parseStepType(String type) {
    switch (type) {
      case 'HEAT':
        return BrewingStepType.heatEquipment;
      case 'GRIND_COFFEE':
        return BrewingStepType.grindCoffee;
      case 'PREPARE_FILTER':
        return BrewingStepType.prepareFilter;
      case 'WEIGH_COFFEE':
        return BrewingStepType.weighCoffee;
      case 'DISTRIBUTE_GROUNDS':
        return BrewingStepType.distributeGrounds;
      case 'TAMP':
        return BrewingStepType.tamp;
      case 'BLOOM':
        return BrewingStepType.bloom;
      case 'BREW':
        return BrewingStepType.brew;
      case 'POUR_WATER':
        return BrewingStepType.pourWater;
      case 'STIR':
        return BrewingStepType.stir;
      case 'PRESS':
        return BrewingStepType.press;
      case 'WAIT':
        return BrewingStepType.wait;
      case 'REMOVE_GROUNDS':
        return BrewingStepType.removeGrounds;
      case 'TRANSFER':
        return BrewingStepType.transfer;
      case 'DILUTE':
        return BrewingStepType.dilute;
      case 'DECORATE':
        return BrewingStepType.decorate;
      case 'SERVE':
        return BrewingStepType.serve;
      default:
        return BrewingStepType.custom;
    }
  }

  static String _getStepTitle(String type) {
    try {
      final stepType = _parseStepType(type);
      return stepType.title;
    } catch (e) {
      return BrewingStepType.custom.title;
    }
  }

  BrewingStep copyWith({
    BrewingStepType? type,
    String? title,
    String? description,
    int? duration,
  }) {
    return BrewingStep(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
