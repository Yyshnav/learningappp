import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/streak_model.dart'; // Ensure this import manages the new model

class StreakController extends GetxController {
  final ApiService _apiService = ApiService();
  var streakData = Rxn<StreakData>();
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStreakData();
  }

  void fetchStreakData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      var data = await _apiService.getStreakData();
      streakData.value = StreakData.fromJson(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
