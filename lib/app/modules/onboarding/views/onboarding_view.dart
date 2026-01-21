// onboarding_view.dart (keep most of your structure)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(
      OnboardingController(),
    ); // or better: use Get.lazyPut in controller init if needed

    return Scaffold(
      body: PageView.builder(
        controller: controller.pageController,
        itemCount: controller.onboardingPages.length,
        onPageChanged: controller.onPageChanged,
        itemBuilder: (context, index) {
          final pageData = controller.onboardingPages[index];
          return _OnboardPage(
            data: pageData,
            pageIndex: index,
            total: controller.onboardingPages.length,
            onNext: controller.nextPage,
            onSkip: controller.skip,
          );
        },
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final Map<String, String> data;
  final int pageIndex;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _OnboardPage({
    required this.data,
    required this.pageIndex,
    required this.total,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 🔹 Background + Image
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: size.height * 0.55,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF0AA6A6),
            child: Image.asset(
              data['image']!,
              fit: data['fit'] == 'cover' ? BoxFit.cover : BoxFit.contain,
              alignment: data['alignment'] == 'topCenter'
                  ? Alignment.topCenter
                  : Alignment.center,
            ),
          ),
        ),

        // 🔹 White Curved Part using ClipPath
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(height: size.height * 0.52, color: Colors.white),
          ),
        ),

        // 🔹 Center Logo Circle
        Positioned(
          bottom: size.height * 0.52 - 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFF0AA6A6),
                child: Image.asset(
                  'assets/images/ologo.png',
                  height: 35,
                  color: Colors.white,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, color: Colors.white);
                  },
                ),
              ),
            ),
          ),
        ),

        // Title + Description
        Positioned(
          bottom: 160,
          left: 32,
          right: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data['title']!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data['description']!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        // Page dots (reactive)
        Positioned(
          bottom: 110,
          child: Obx(() {
            final activeIndex =
                Get.find<OnboardingController>().pageIndex.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                final isActive = i == activeIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: isActive ? 12 : 8,
                  height: isActive ? 12 : 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF0AA6A6)
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          }),
        ),

        // Next button + Skip
        Positioned(
          bottom: 40,
          left: 32,
          right: 32,
          child: Column(
            children: [
              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0AA6A6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: onNext,
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onSkip,
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Color(0xFF0AA6A6),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 100); // Start slightly down
    path.quadraticBezierTo(
      size.width / 2,
      0, // Peak in center
      size.width,
      100, // End slightly down
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
