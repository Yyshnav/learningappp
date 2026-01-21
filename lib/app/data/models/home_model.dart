class HomeData {
  User? user;
  List<HeroBanner>? heroBanners;
  ActiveCourse? activeCourse;
  List<PopularCourseCategory>? popularCourses;
  LiveSession? liveSession;

  HomeData({
    this.user,
    this.heroBanners,
    this.activeCourse,
    this.popularCourses,
    this.liveSession,
  });

  HomeData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['hero_banners'] != null) {
      heroBanners = <HeroBanner>[];
      json['hero_banners'].forEach((v) {
        heroBanners!.add(HeroBanner.fromJson(v));
      });
    }
    activeCourse = json['active_course'] != null
        ? ActiveCourse.fromJson(json['active_course'])
        : null;
    if (json['popular_courses'] != null) {
      popularCourses = <PopularCourseCategory>[];
      json['popular_courses'].forEach((v) {
        popularCourses!.add(PopularCourseCategory.fromJson(v));
      });
    }
    liveSession = json['live_session'] != null
        ? LiveSession.fromJson(json['live_session'])
        : null;
  }
}

class User {
  String? name;
  String? greeting;
  Streak? streak;

  User({this.name, this.greeting, this.streak});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    greeting = json['greeting'];
    streak = json['streak'] != null ? Streak.fromJson(json['streak']) : null;
  }
}

class Streak {
  int? days;
  String? icon;

  Streak({this.days, this.icon});

  Streak.fromJson(Map<String, dynamic> json) {
    days = json['days'];
    icon = json['icon'];
  }
}

class HeroBanner {
  int? id;
  String? title;
  String? image;
  bool? isActive;

  HeroBanner({this.id, this.title, this.image, this.isActive});

  HeroBanner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    isActive = json['is_active'];
  }
}

class ActiveCourse {
  int? id;
  String? title;
  int? progress;
  int? testsCompleted;
  int? totalTests;

  ActiveCourse({this.id, this.title, this.progress, this.testsCompleted, this.totalTests});

  ActiveCourse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    progress = json['progress'];
    testsCompleted = json['tests_completed'];
    totalTests = json['total_tests'];
  }
}

class PopularCourseCategory {
  int? id;
  String? name;
  List<Course>? courses;

  PopularCourseCategory({this.id, this.name, this.courses});

  PopularCourseCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['courses'] != null) {
      courses = <Course>[];
      json['courses'].forEach((v) {
        courses!.add(Course.fromJson(v));
      });
    }
  }
}

class Course {
  int? id;
  String? title;
  String? image;
  String? action;

  Course({this.id, this.title, this.image, this.action});

  Course.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    action = json['action'];
  }
}

class LiveSession {
  int? id;
  bool? isLive;
  String? title;
  Instructor? instructor;
  SessionDetails? sessionDetails;
  String? action;

  LiveSession({this.id, this.isLive, this.title, this.instructor, this.sessionDetails, this.action});

  LiveSession.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isLive = json['is_live'];
    title = json['title'];
    instructor = json['instructor'] != null ? Instructor.fromJson(json['instructor']) : null;
    sessionDetails = json['session_details'] != null ? SessionDetails.fromJson(json['session_details']) : null;
    action = json['action'];
  }
}

class Instructor {
  String? name;

  Instructor({this.name});

  Instructor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }
}

class SessionDetails {
  int? sessionNumber;
  String? date;
  String? time;

  SessionDetails({this.sessionNumber, this.date, this.time});

  SessionDetails.fromJson(Map<String, dynamic> json) {
    sessionNumber = json['session_number'];
    date = json['date'];
    time = json['time'];
  }
}
