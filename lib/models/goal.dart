import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 1)
class Goal {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted; // Track if goal is checked

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime? completedOn;

  Goal({
    required this.title,
    this.isCompleted = false,
    this.description = '',
    this.completedOn,
  });

  // Convert to Map (for Hive storage)
  Map<String, dynamic> toMap() => {
    "title": title,
    "isCompleted": isCompleted,
    "description": description,
    "completedOn": completedOn?.toIso8601String(),
  };

  // Convert from Map
  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
    title: map["title"],
    isCompleted: map["isCompleted"] ?? false,
    description: map["description"],
    completedOn:
        map["completedOn"] != null ? DateTime.parse(map["completedOn"]) : null,
  );
}
