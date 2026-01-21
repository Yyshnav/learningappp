import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../data/models/video_model.dart';
import '../controllers/video_controller.dart';
import '../../widgets/state_widgets.dart';

class VideoView extends GetView<VideoController> {
  const VideoView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(VideoController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingStateWidget();
          }
          if (controller.errorMessage.isNotEmpty) {
            return ErrorStateWidget(
              message: controller.errorMessage.value,
              onRetry: controller.fetchVideoData,
            );
          }
          if (controller.videoData.value == null) {
            return EmptyStateWidget(
              message: 'No details available',
              onAction: controller.fetchVideoData,
              actionLabel: 'Refresh',
            );
          }

          final data = controller.videoData.value!;
          // Find current video or default to first
          final currentVideo = data.data?.videos?.firstWhere(
            (v) => v.id == controller.currentVideoId.value,
            orElse: () => data.data!.videos!.first,
          );

          return Column(
            children: [
              // 1. Header & Video Player Section
              _buildVideoPlayerSection(currentVideo),

              // 2. Video Info (Title, Desc, Download)
              _buildVideoInfo(currentVideo),

              const Divider(thickness: 1, height: 1, color: Color(0xFFF0F0F0)),

              // 3. Meditation Journey List
              Expanded(
                child: Container(
                  color: const Color(
                    0xFFF5F9FA,
                  ), // Light background for list area
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Text(
                          data.data?.title ?? 'Meditation Journey',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 0,
                          ),
                          itemCount: data.data?.videos?.length ?? 0,
                          itemBuilder: (context, index) {
                            final video = data.data!.videos![index];
                            final isLast =
                                index == (data.data!.videos!.length - 1);
                            return _buildTimelineItem(video, isLast);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildVideoPlayerSection(Video? video) {
    return Stack(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video Player or Placeholder
              Obx(() {
                if (controller.isPlayerInitialized.value &&
                    controller.videoPlayerController != null) {
                  return AspectRatio(
                    aspectRatio:
                        controller.videoPlayerController!.value.aspectRatio,
                    child: VideoPlayer(controller.videoPlayerController!),
                  );
                } else {
                  return Image.network(
                    'https://trogon.info/task/api/images/banners/Screenshot2025-12-31131948.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 240,
                    color: Colors.black.withOpacity(0.4),
                    colorBlendMode: BlendMode.darken,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.black),
                  );
                }
              }),

              // Play/Pause Button Center (Only show if paused or initially)
              Obx(
                () => controller.isPlayerInitialized.value
                    ? (controller.isPlaying.value
                          ? const SizedBox.shrink() // Hide when playing
                          : GestureDetector(
                              onTap: controller.togglePlay,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ))
                    : const SizedBox.shrink(), // detailed loading state handled elsewhere or just wait
              ),

              // Back Button (Overlaid)
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),

              GestureDetector(
                onTap: controller.togglePlay, // Allow tapping screen to toggle
                behavior: HitTestBehavior.translucent,
                child: SizedBox(width: double.infinity, height: 240),
              ),

              // Controls Overlay (Bottom)
              Positioned(
                bottom: 10,
                left: 15,
                right: 15,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Bar
                    Obx(() {
                      final position = controller.position.value.inMilliseconds
                          .toDouble();
                      final duration = controller.duration.value.inMilliseconds
                          .toDouble();
                      final max = duration > 0 ? duration : 1.0;
                      final value = position.clamp(0.0, max);

                      return Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(Get.context!).copyWith(
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white30,
                                thumbColor: Colors.white,
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 10,
                                ),
                              ),
                              child: Slider(
                                value: value,
                                min: 0.0,
                                max: max,
                                onChanged: (val) {
                                  controller.seekTo(val / 1000);
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text(
                            "${_formatDuration(controller.position.value.inSeconds)} / ${_formatDuration(controller.duration.value.inSeconds)}",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        // Fullscreen icon or similar could go here
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo(Video? video) {
    if (video == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title ?? 'Video Title',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  video.description ?? '',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.download_rounded, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Video video, bool isLast) {
    bool isCompleted = video.status == 'completed';
    bool isLocked = video.status == 'locked';
    // bool isInProgress = video.status == 'in_progress';

    Color activeColor = const Color(0xFF00C9B7); // Teal/Cyan

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Icon
          Column(
            children: [
              // Icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? activeColor
                      : (isLocked ? Colors.white : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLocked
                        ? Colors.transparent
                        : (isCompleted ? activeColor : Colors.grey.shade300),
                    width: 0, // handled by color
                  ),
                  boxShadow: isLocked
                      ? []
                      : [
                          // Only show shadow if not locked? Or maybe mock lock UI
                        ],
                ),
                // If locked, it looks like a white circle with a lock icon.
                // If completed, green circle with check.
                child: Center(
                  child: isLocked
                      ? Icon(Icons.lock, color: Colors.grey.shade800, size: 16)
                      : (isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : Icon(
                                Icons.lock_open,
                                color: Colors.grey.shade400,
                                size: 16,
                              ) // Default state
                              ),
                ),
              ),
              // Line
              if (!isLast)
                Expanded(
                  child: CustomPaint(
                    painter: DottedLinePainter(),
                    child: const SizedBox(width: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),

          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title ?? '',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          video.description ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return "00:00";
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF00C9B7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double dashHeight = 4, dashSpace = 4, startY = 4;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
