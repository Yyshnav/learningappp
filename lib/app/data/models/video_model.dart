class VideoData {
  int? status;
  String? message;
  VideoDetails? data;

  VideoData({this.status, this.message, this.data});

  VideoData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? VideoDetails.fromJson(json['data']) : null;
  }
}

class VideoDetails {
  String? title;
  List<Video>? videos;

  VideoDetails({this.title, this.videos});

  VideoDetails.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if (json['videos'] != null) {
      videos = <Video>[];
      json['videos'].forEach((v) {
        videos!.add(Video.fromJson(v));
      });
    }
  }
}

class Video {
  int? id;
  String? title;
  String? description;
  String? status;
  String? videoUrl;
  int? totalDuration;
  int? watchedDuration;
  int? progressPercentage;
  bool? hasPlayButton;

  Video(
      {this.id,
      this.title,
      this.description,
      this.status,
      this.videoUrl,
      this.totalDuration,
      this.watchedDuration,
      this.progressPercentage,
      this.hasPlayButton});

  Video.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    status = json['status'];
    videoUrl = json['video_url'];
    totalDuration = json['total_duration'];
    watchedDuration = json['watched_duration'];
    progressPercentage = json['progress_percentage'];
    hasPlayButton = json['has_play_button'];
  }
}
