import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../data/models/plan_model.dart';
import '../../data/providers/api_client.dart';
import '../../data/repositories/plan_repository.dart';
import '../../data/services/auth_service.dart';

/// What a tier actually grants, taken from the rules the server enforces.
///
/// Not from the website's pricing copy: four of its claims — read receipts,
/// going back to a passed profile, ad-free browsing and "unlimited" messages —
/// have nothing behind them, and repeating them here would put the same
/// unfounded promises on the in-app paywall.
typedef TierFeature = ({String labelKey, bool free, bool essential, bool premium, bool prestige});

const List<TierFeature> kTierFeatures = [
  (
    labelKey: TrKeys.featUnlimitedBrowsing,
    free: false, essential: true, premium: true, prestige: true,
  ),
  (
    labelKey: TrKeys.entSendMessages,
    free: false, essential: true, premium: true, prestige: true,
  ),
  (
    labelKey: TrKeys.entSeeWhoLikedYou,
    free: false, essential: true, premium: true, prestige: true,
  ),
  (
    labelKey: TrKeys.entAdvancedFilters,
    free: false, essential: false, premium: true, prestige: true,
  ),
  (
    labelKey: TrKeys.entProfileVisitors,
    free: false, essential: false, premium: true, prestige: true,
  ),
  (
    labelKey: TrKeys.entSuperLikes,
    free: false, essential: false, premium: true, prestige: true,
  ),
  (
    labelKey: TrKeys.featPriority,
    free: false, essential: false, premium: false, prestige: true,
  ),
];

class PlansController extends GetxController {
  PlansController({PlanRepository? repository})
      : _repo = repository ?? PlanRepository();

  final PlanRepository _repo;

  final plans = <PlanModel>[].obs;
  final loading = true.obs;
  final error = RxnString();

  final selectedTier = PlanTier.essential.obs;
  final selectedPlan = Rxn<PlanModel>();

  PlanTier get currentTier => AuthService.to.user?.tier ?? PlanTier.free;
  bool get isAdmin => AuthService.to.user?.isAdmin ?? false;

  /// The paid tiers that the catalogue actually contains, in order.
  List<PlanTier> get tiers => [
        for (final tier in [PlanTier.essential, PlanTier.premium, PlanTier.prestige])
          if (plans.any((p) => p.tier == tier)) tier,
      ];

  List<PlanModel> get tierPlans {
    final list = plans.where((p) => p.tier == selectedTier.value).toList()
      // Longest first, which is how the website orders them.
      ..sort((a, b) => _months(b).compareTo(_months(a)));
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      plans.assignAll(await _repo.plans());

      final available = tiers;
      if (available.isNotEmpty && !available.contains(selectedTier.value)) {
        selectedTier.value = available.first;
      }
      _selectDefault();
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  void chooseTier(PlanTier tier) {
    selectedTier.value = tier;
    _selectDefault();
  }

  void choosePlan(PlanModel plan) => selectedPlan.value = plan;

  /// The monthly plan is the one most people take, so it starts selected.
  void _selectDefault() {
    final list = tierPlans;
    if (list.isEmpty) {
      selectedPlan.value = null;
      return;
    }
    selectedPlan.value = list.firstWhereOrNull(
          (p) => p.duration == 1 && p.durationUnit == 'month',
        ) ??
        list.first;
  }

  double _months(PlanModel plan) =>
      plan.durationUnit == 'week' ? plan.duration / 4.345 : plan.duration.toDouble();

  /// Price per month, so plans of different lengths can be compared. Weekly
  /// plans are left per week — dividing a week into a month reads as noise.
  String unitPrice(PlanModel plan) =>
      (plan.durationUnit == 'week' ? plan.price : plan.price / plan.duration)
          .toStringAsFixed(2);

  bool isWeekly(PlanModel plan) => plan.durationUnit == 'week';

  /// How much a longer plan saves against the monthly one in the same tier.
  /// Null when there is nothing to compare against, or nothing to save.
  int? savingPercent(PlanModel plan) {
    if (plan.durationUnit == 'week' || plan.duration == 1) return null;

    final monthly = tierPlans.firstWhereOrNull(
      (p) => p.duration == 1 && p.durationUnit == 'month',
    );
    if (monthly == null || monthly.price <= 0) return null;

    final perMonth = plan.price / plan.duration;
    final saved = ((1 - perMonth / monthly.price) * 100).round();
    return saved > 0 ? saved : null;
  }

  bool isCurrent(PlanModel plan) => plan.tier == currentTier && currentTier.isPaid;

  /// ── Where buying will happen ──────────────────────────────────────────────
  /// Nothing is charged yet. Subscriptions have to go through StoreKit and
  /// Google Play Billing — both stores reject an app that takes payment for
  /// digital goods any other way — and neither is set up.
  ///
  /// When it is, this is the single place that changes: validate the purchase
  /// with the store, send the receipt to the backend, and let the server grant
  /// the tier. Nothing else on this screen needs to move.
  void purchase(PlanModel plan) {
    Get.snackbar(
      TrKeys.planUnavailableTitle.tr,
      TrKeys.planUnavailableBody.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }
}
