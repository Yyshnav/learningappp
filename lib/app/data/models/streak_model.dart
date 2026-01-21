class StreakData {
  int? currentDay;
  int? totalDays;
  List<Day>? days;

  StreakData({this.currentDay, this.totalDays, this.days});

  StreakData.fromJson(Map<String, dynamic> json) {
    currentDay = json['current_day'];
    totalDays = json['total_days'];
    if (json['days'] != null) {
      days = <Day>[];
      json['days'].forEach((v) {
        days!.add(Day.fromJson(v));
      });
    }
  }
}

class Day {
  int? id;
  int? dayNumber;
  String? label;
  bool? isCompleted;
  bool? isCurrent;
  Topic? topic;

  Day({
    this.id,
    this.dayNumber,
    this.label,
    this.isCompleted,
    this.isCurrent,
    this.topic,
  });

  Day.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dayNumber = json['day_number'];
    label = json['label'];
    isCompleted = json['is_completed'];
    isCurrent = json['is_current'];
    topic = json['topic'] != null ? Topic.fromJson(json['topic']) : null;
  }
}

class Topic {
  String? title;
  List<Module>? modules;

  Topic({this.title, this.modules});

  Topic.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if (json['modules'] != null) {
      modules = <Module>[];
      json['modules'].forEach((v) {
        modules!.add(Module.fromJson(v));
      });
    }
  }
}

class Module {
  String? name;
  String? description;

  Module({this.name, this.description});

  Module.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
  }
}
