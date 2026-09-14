import 'package:amour_app/app/core/localization/translation_keys.dart';
import 'package:amour_app/app/data/models/plan_model.dart';
import 'package:amour_app/app/data/repositories/plan_repository.dart';
import 'package:amour_app/app/modules/plans/plans_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// The catalogue exactly as production serves it, read back from GET /api/plans.
const _live = [
  PlanModel(id: '0', name: 'Free', tier: PlanTier.free, price: 0, duration: 0, durationUnit: 'month', priority: 0),
  PlanModel(id: '1', name: 'Essential (6 Mois)', tier: PlanTier.essential, price: 44.9, duration: 6, durationUnit: 'month', priority: 1),
  PlanModel(id: '2', name: 'Essential (1 Mois)', tier: PlanTier.essential, price: 24.9, duration: 1, durationUnit: 'month', priority: 2),
  PlanModel(id: '3', name: 'Essential (1 Semaine)', tier: PlanTier.essential, price: 9.9, duration: 1, durationUnit: 'week', priority: 3),
  PlanModel(id: '4', name: 'Premium (6 Mois)', tier: PlanTier.premium, price: 64.9, duration: 6, durationUnit: 'month', priority: 4),
  PlanModel(id: '5', name: 'Premium (1 Mois)', tier: PlanTier.premium, price: 34.9, duration: 1, durationUnit: 'month', priority: 5),
  PlanModel(id: '6', name: 'Prestige (1 Mois)', tier: PlanTier.prestige, price: 49.9, duration: 1, durationUnit: 'month', priority: 8),
];

class _FakeRepository extends PlanRepository {
  _FakeRepository(this._plans);
  final List<PlanModel> _plans;

  @override
  Future<List<PlanModel>> plans() async => _plans;
}

PlansController _controller([List<PlanModel>? plans]) {
  final c = PlansController(repository: _FakeRepository(plans ?? _live));
  c.plans.assignAll(plans ?? _live);
  return c;
}

void main() {
  group('catalogue', () {
    test('offers only the paid tiers that exist', () {
      // Free is not something to buy, and a tier with no plans is not offered.
      expect(_controller().tiers,
          [PlanTier.essential, PlanTier.premium, PlanTier.prestige]);

      final essentialOnly =
          _controller(_live.where((p) => p.tier != PlanTier.prestige).toList());
      expect(essentialOnly.tiers, [PlanTier.essential, PlanTier.premium]);
    });

    test('lists the longest plan first', () {
      final c = _controller()..chooseTier(PlanTier.essential);
      expect(c.tierPlans.map((p) => p.name).toList(), [
        'Essential (6 Mois)',
        'Essential (1 Mois)',
        'Essential (1 Semaine)',
      ]);
    });

    test('starts on the monthly plan', () {
      final c = _controller()..chooseTier(PlanTier.premium);
      expect(c.selectedPlan.value?.name, 'Premium (1 Mois)');
    });
  });

  group('pricing', () {
    test('shows a monthly plan at its own price', () {
      final monthly = _live.firstWhere((p) => p.name == 'Essential (1 Mois)');
      expect(_controller().unitPrice(monthly), '24.90');
    });

    test('breaks a six-month plan down per month', () {
      final half = _live.firstWhere((p) => p.name == 'Essential (6 Mois)');
      expect(_controller().unitPrice(half), '7.48');
    });

    test('leaves a weekly plan per week', () {
      // Dividing a week into a month would read as noise.
      final weekly = _live.firstWhere((p) => p.name == 'Essential (1 Semaine)');
      final c = _controller();
      expect(c.isWeekly(weekly), isTrue);
      expect(c.unitPrice(weekly), '9.90');
    });

    test('works out the saving against the monthly plan', () {
      final c = _controller()..chooseTier(PlanTier.essential);
      final half = _live.firstWhere((p) => p.name == 'Essential (6 Mois)');
      // 7.48 a month against 24.90 is 70% off.
      expect(c.savingPercent(half), 70);
    });

    test('claims no saving on the monthly or weekly plans', () {
      final c = _controller()..chooseTier(PlanTier.essential);
      expect(
          c.savingPercent(
              _live.firstWhere((p) => p.name == 'Essential (1 Mois)')),
          isNull);
      expect(
          c.savingPercent(
              _live.firstWhere((p) => p.name == 'Essential (1 Semaine)')),
          isNull);
    });
  });

  group('what each tier promises', () {
    // The website's pricing page claims read receipts, going back to a passed
    // profile, ad-free browsing and "unlimited" messages. None of the four
    // exist. Repeating them on the in-app paywall would put unfounded promises
    // in front of a store reviewer, so the list is built from what the server
    // actually enforces.
    test('every listed feature is one the server really gates', () {
      const enforced = {
        TrKeys.featUnlimitedBrowsing,
        TrKeys.entSendMessages,
        TrKeys.entSeeWhoLikedYou,
        TrKeys.entAdvancedFilters,
        TrKeys.entProfileVisitors,
        TrKeys.entSuperLikes,
        TrKeys.featPriority,
      };

      expect(kTierFeatures.map((f) => f.labelKey).toSet(), enforced);
    });

    test('matches the backend rules tier by tier', () {
      Map<String, bool> forTier(bool Function(TierFeature) pick) => {
            for (final f in kTierFeatures) f.labelKey: pick(f),
          };

      // Free: nothing. Everything on this list is behind a paid plan.
      expect(forTier((f) => f.free).values.every((v) => !v), isTrue);

      // Essential: messaging, who liked you, unlimited browsing — no more.
      final essential = forTier((f) => f.essential);
      expect(essential[TrKeys.entSendMessages], isTrue);
      expect(essential[TrKeys.entSeeWhoLikedYou], isTrue);
      expect(essential[TrKeys.featUnlimitedBrowsing], isTrue);
      expect(essential[TrKeys.entAdvancedFilters], isFalse);
      expect(essential[TrKeys.entProfileVisitors], isFalse);
      expect(essential[TrKeys.entSuperLikes], isFalse);

      // Premium adds filters, visitors and super likes.
      final premium = forTier((f) => f.premium);
      expect(premium[TrKeys.entAdvancedFilters], isTrue);
      expect(premium[TrKeys.entProfileVisitors], isTrue);
      expect(premium[TrKeys.entSuperLikes], isTrue);
      expect(premium[TrKeys.featPriority], isFalse);

      // Only Prestige is ranked higher in everyone else's results.
      expect(forTier((f) => f.prestige)[TrKeys.featPriority], isTrue);
    });
  });
}
