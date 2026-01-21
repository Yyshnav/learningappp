import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/home_model.dart';
import '../../streak/views/streak_view.dart';
import '../../video/views/video_view.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();
  var homeData = Rxn<HomeData>();
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var selectedCategoryIndex = 0.obs;
  var currentBannerIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  void fetchHomeData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      var data = await _apiService.getHomeData();
      homeData.value = HomeData.fromJson(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToStreak() {
    // Navigate to Streak Page
    Get.to(() => const StreakView());
  }

  void navigateToCourse(int courseId) {
    // Navigate to Video/Subjects Page
    Get.to(() => const VideoView());
  }

  void onCategorySelected(int index) {
    selectedCategoryIndex.value = index;
  }
}
