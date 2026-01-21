import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/video_model.dart';

class VideoController extends GetxController {
  final ApiService _apiService = ApiService();
  var videoData = Rxn<VideoData>();
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // Video Player State
  VideoPlayerController? videoPlayerController;
  var isPlayerInitialized = false.obs;
  var isPlaying = false.obs;
  var position = Duration.zero.obs;
  var duration = Duration.zero.obs;

  // Track currently playing video
  var currentVideoId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVideoData();
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    super.onClose();
  }

  void fetchVideoData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      var data = await _apiService.getCourseDetails("");
      videoData.value = VideoData.fromJson(data);

      // Set first playable video as current if available
      if (videoData.value?.data?.videos != null &&
          videoData.value!.data!.videos!.isNotEmpty) {
        final firstVideo = videoData.value!.data!.videos!.first;
        currentVideoId.value = firstVideo.id ?? 0;
        if (firstVideo.videoUrl != null) {
          initializePlayer(firstVideo.videoUrl!);
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void initializePlayer(String url) async {
    // Dispose previous controller if any
    videoPlayerController?.dispose();
    isPlayerInitialized.value = false;

    // Force HTTPS to avoid Cleartext Traffic errors
    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'https://');
    }
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await videoPlayerController!.initialize();
      isPlayerInitialized.value = true;
      duration.value = videoPlayerController!.value.duration;

      // Auto play
      videoPlayerController!.play();
      isPlaying.value = true;

      // Listen to updates
      videoPlayerController!.addListener(() {
        if (videoPlayerController != null) {
          position.value = videoPlayerController!.value.position;
          isPlaying.value = videoPlayerController!.value.isPlaying;
          duration.value = videoPlayerController!.value.duration;
        }
      });
    } catch (e) {
      print("Error initializing video player: $e");
      Get.snackbar("Error", "Could not play video: $e");
    }
  }

  void playVideo(int id) {
    currentVideoId.value = id;
    final video = videoData.value?.data?.videos?.firstWhere((v) => v.id == id);
    if (video != null && video.videoUrl != null) {
      initializePlayer(video.videoUrl!);
    }
  }

  void togglePlay() {
    if (videoPlayerController != null && isPlayerInitialized.value) {
      if (videoPlayerController!.value.isPlaying) {
        videoPlayerController!.pause();
      } else {
        videoPlayerController!.play();
      }
    }
  }

  void seekTo(double value) {
    if (videoPlayerController != null && isPlayerInitialized.value) {
      videoPlayerController!.seekTo(Duration(seconds: value.toInt()));
    }
  }

  bool isLocked(Video video) {
    return video.status == 'locked';
  }
}
