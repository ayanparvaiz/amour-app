import '../../core/constants/api_constants.dart';
import '../models/plan_model.dart';
import '../providers/api_client.dart';

class PlanRepository {
  PlanRepository({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  /// The catalogue, in the order the server ranks it.
  ///
  /// Public — no session needed, which is why the pricing page works for a
  /// signed-out visitor on the website.
  Future<List<PlanModel>> plans() async {
    final body = await _api.get(ApiConstants.plans, withAuth: false);
    return ((body['plans'] as List?) ?? const [])
        .map((e) => PlanModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }
}
