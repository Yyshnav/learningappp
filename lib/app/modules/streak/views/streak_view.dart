import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/streak_model.dart';
import '../controllers/streak_controller.dart';
import '../../widgets/state_widgets.dart';
import 'dart:ui' as ui;

class StreakView extends GetView<StreakController> {
  const StreakView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(StreakController());
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0AA6B4)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient - Light Cyan
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFCCF9FF), Color(0xFFE0FBFF)],
              ),
            ),
          ),

          // Background Decorations (Stars/Diamonds)
          ..._buildDecorations(),

          // Scrollable Content
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingStateWidget();
              }
              if (controller.errorMessage.isNotEmpty) {
                return ErrorStateWidget(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchStreakData,
                );
              }
              final data = controller.streakData.value;
              if (data == null || data.days == null || data.days!.isEmpty) {
                return EmptyStateWidget(
                  message: 'No Streak Data',
                  onAction: controller.fetchStreakData,
                  actionLabel: 'Refresh',
                );
              }

              // Define the S-shaped serpentine path positions
              // We use a normalized 0.0 to 1.0 coordinate system for flexibility
              final positions = [
                const Offset(0.5, 0.90), // Day 1 (Bottom Center)
                const Offset(0.75, 0.78), // Day 2 (Rightish)
                const Offset(0.35, 0.68), // Day 3 (Leftish)
                const Offset(0.30, 0.52), // Day 4 (Left)
                const Offset(0.68, 0.42), // Day 5 (Rightish - Current)
                const Offset(0.35, 0.32), // Day 6 (Leftish)
                const Offset(0.18, 0.20), // Day 7 (Far Left)
                const Offset(0.58, 0.10), // Day 8 (Top Center)
              ];

              final sortedDays = List<Day>.from(
                data.days!,
              )..sort((a, b) => (a.dayNumber ?? 0).compareTo(b.dayNumber ?? 0));

              return LayoutBuilder(
                builder: (context, constraints) {
                  const double totalHeight =
                      1200; // Increased height for better spacing
                  return SingleChildScrollView(
                    child: SizedBox(
                      height: totalHeight,
                      width: constraints.maxWidth,
                      child: Stack(
                        children: [
                          // Path Painter (Background)
                          CustomPaint(
                            size: Size(constraints.maxWidth, totalHeight),
                            painter: SerpentinePathPainter(
                              positions: positions,
                            ),
                          ),

                          // Render Nodes
                          ...List.generate(sortedDays.length, (index) {
                            if (index >= positions.length)
                              return const SizedBox.shrink();
                            final day = sortedDays[index];
                            final pos = positions[index];
                            final isCurrent = day.isCurrent == true;

                            return _dayCircle(
                              context,
                              constraints,
                              day,
                              pos,
                              isCurrent,
                              totalHeight,
                            );
                          }),

                          // Render Tooltip for Current Day
                          Builder(
                            builder: (context) {
                              final currentIndex = sortedDays.indexWhere(
                                (d) => d.isCurrent == true,
                              );
                              if (currentIndex != -1 &&
                                  currentIndex < positions.length) {
                                final pos = positions[currentIndex];
                                final day = sortedDays[currentIndex];

                                // Centering tooltip: -75 is half of 150 width
                                return Positioned(
                                  left: constraints.maxWidth * pos.dx - 75,
                                  top: totalHeight * pos.dy - 100,
                                  child: _todayTooltip(day),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecorations() {
    return [
      _starIcon(top: 120, left: 110, size: 28), // Matches Day 8 area
      _starIcon(top: 180, right: 30, size: 35, opacity: 0.3), // Mid right
      _starIcon(top: 450, left: 15, size: 22), // Near Day 4
      _starIcon(top: 550, right: 60, size: 30, opacity: 0.2), // Near Day 5
      _starIcon(bottom: 120, left: 20, size: 25, opacity: 0.5), // Bottom left
    ];
  }

  Widget _starIcon({
    double? top,
    double? left,
    double? right,
    double? bottom,
    double size = 20,
    double opacity = 0.6,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Icon(
        Icons.auto_awesome,
        color: const Color(0xFF0AA6B4).withOpacity(opacity),
        size: size,
      ),
    );
  }

  Widget _dayCircle(
    BuildContext context,
    BoxConstraints constraints,
    Day day,
    Offset pos,
    bool isCurrent,
    double totalHeight,
  ) {
    return Positioned(
      left: constraints.maxWidth * pos.dx - 30, // Adjusted for smaller 60 width
      top: totalHeight * pos.dy - 30,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF0AA6B4),
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "Day ${day.dayNumber}",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          // Directional marker below some nodes to match UI
          if ((day.dayNumber ?? 0) % 2 != 0)
            Transform.translate(
              offset: const Offset(0, -5),
              child: CustomPaint(
                size: const Size(12, 6),
                painter: TrianglePainter(
                  color: const Color(0xFF0AA6B4).withOpacity(0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _todayTooltip(Day day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0AA6B4),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Topic",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 9),
              ),
              const SizedBox(height: 3),
              if (day.topic?.modules != null &&
                  day.topic!.modules!.isNotEmpty) ...[
                Text(
                  day.topic!.modules!.first.name ?? "Core Module",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.white24,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                ),
                Text(
                  day.topic!.modules!.last.name ?? "Core Module",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 30),
          width: 20,
          height: 10,
          child: CustomPaint(
            painter: TrianglePainter(color: const Color(0xFF0AA6B4)),
          ),
        ),
      ],
    );
  }
}

class SerpentinePathPainter extends CustomPainter {
  final List<Offset> positions;
  SerpentinePathPainter({required this.positions});

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();

    Offset getPoint(int index) {
      return Offset(
        positions[index].dx * size.width,
        positions[index].dy * size.height,
      );
    }

    path.moveTo(getPoint(0).dx, getPoint(0).dy);

    for (int i = 0; i < positions.length - 1; i++) {
      final p1 = getPoint(i);
      final p2 = getPoint(i + 1);

      // Create a smooth serpentine S-curve
      // We use a mid-point for the control points on the Y axis
      // to ensure a smooth transition between segments.
      final midY = (p1.dy + p2.dy) / 2;

      final c1 = Offset(p1.dx, midY);
      final c2 = Offset(p2.dx, midY);

      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    // Draw Dashed Path
    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(pathMetric.extractPath(distance, distance + 8), paint);
        distance += 16;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
