import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../home/views/home_view.dart';

class OnboardingController extends GetxController {
  var pageIndex = 0.obs;
  final PageController pageController = PageController();

  final List<Map<String, String>> onboardingPages = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': 'Smarter Learning\nStarts Here',
      'description': 'Personalized lessons that adapt to\nyour pace and goals.',
      'fit': 'contain',
      'alignment': 'center',
    },
    {
      'image': 'assets/images/onboarding2.png',
      'title': 'Learn. Practice.\nSucceed.',
      'description':
          'Structured content, mock tests, and\nprogress tracking in one place.',
      'fit': 'contain',
      'alignment': 'center',
    },
  ];

  void nextPage() {
    if (pageIndex.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Get.off(() => const HomeView());
    }
  }

  void skip() {
    Get.off(() => const HomeView());
  }

  void onPageChanged(int index) {
    pageIndex.value = index;
  }
}
