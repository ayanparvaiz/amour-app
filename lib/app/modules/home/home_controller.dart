import 'package:get/get.dart';

import '../../data/models/match_model.dart';
import '../../data/providers/api_client.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';

class HomeController extends GetxController {
  HomeController({UserRepository? repository})
      : _repo = repository ?? UserRepository();

  final UserRepository _repo;

  final matches = <MatchModel>[].obs;
  final loading = true.obs;
  final error = RxnString();

  /// How many of the strict matches the home row shows. The rest live in
  /// Discover; this is a taste, not the full list.
  static const int previewCount = 6;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      // No discover mode here: the home row is the strict, two-way matches —
      // people whose own preferences point back at this member.
      final result = await _repo.matches();
      matches.assignAll(result.take(previewCount));
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  /// Pull to refresh re-reads the profile as well, so a plan bought on the
  /// website shows up here without signing out and back in.
  Future<void> refreshAll() async {
    await AuthService.to.refresh();
    await load();
  }
}
