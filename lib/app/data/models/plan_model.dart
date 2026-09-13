/// Subscription tiers, in ascending order of entitlement.
///
/// The backend's Plan schema permits both `Essential` and `Essentiel`. Live data
/// uses `Essential`; the in-repo seeders disagree with each other and with
/// production, so [PlanTier.parse] accepts both spellings rather than trusting
/// whichever seeder last ran.
enum PlanTier {
  free,
  essential,
  premium,
  prestige;

  static PlanTier parse(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'essential':
      case 'essentiel':
        return PlanTier.essential;
      case 'premium':
        return PlanTier.premium;
      case 'prestige':
        return PlanTier.prestige;
      default:
        return PlanTier.free;
    }
  }

  bool get isPaid => this != PlanTier.free;

  /// Premium and Prestige only.
  bool get isUpperTier => this == PlanTier.premium || this == PlanTier.prestige;

  String get label => switch (this) {
        PlanTier.free => 'Gratuit',
        PlanTier.essential => 'Essential',
        PlanTier.premium => 'Premium',
        PlanTier.prestige => 'Prestige',
      };
}

class PlanModel {
  const PlanModel({
    required this.id,
    required this.name,
    required this.tier,
    required this.price,
    required this.duration,
    required this.durationUnit,
    this.priority = 0,
  });

  final String id;
  final String name;
  final PlanTier tier;
  final double price;
  final int duration;
  final String durationUnit;
  final int priority;

  /// The backend also returns a `features` list, but nothing renders it — the
  /// website builds its comparison table from hardcoded strings instead. It is
  /// deliberately not parsed here; see CLAUDE.md before relying on it.

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        tier: PlanTier.parse(json['tier'] as String?),
        price: (json['price'] as num?)?.toDouble() ?? 0,
        duration: (json['duration'] as num?)?.toInt() ?? 0,
        durationUnit: (json['durationUnit'] ?? 'month').toString(),
        priority: (json['priority'] as num?)?.toInt() ?? 0,
      );

  /// Duration rendered the way the pricing page phrases it.
  String get durationLabel {
    if (durationUnit == 'week') return '1 semaine';
    if (duration == 6) return '6 mois';
    return '1 mois';
  }

  String get priceLabel => '€${price.toStringAsFixed(2)}';
}
