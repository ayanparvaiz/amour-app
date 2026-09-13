import 'plan_model.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.gender,
    this.lookingFor,
    this.ageRange,
    this.age,
    this.location,
    this.photo,
    this.photos = const [],
    this.bio,
    this.planName,
    this.tier = PlanTier.free,
    this.subscriptionStatus,
    this.subscriptionExpiry,
    this.coordinates,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? gender;
  final String? lookingFor;
  final String? ageRange;
  final int? age;
  final String? location;
  final String? photo;
  final List<String> photos;
  final String? bio;
  final String? planName;
  final PlanTier tier;
  final String? subscriptionStatus;
  final DateTime? subscriptionExpiry;

  /// Longitude and latitude, in that order — the order GeoJSON and the backend
  /// both use, and the reverse of how people say it.
  ///
  /// Null when the member has never granted location. The schema defaults the
  /// field to [0, 0], which is a real point in the Gulf of Guinea rather than
  /// a marker for "unset", so that pair is treated as absent here: a radius
  /// search sent from it would return nobody and look like a broken filter.
  final (double, double)? coordinates;

  bool get isAdmin => role == 'admin';

  /// Whether the profile setup wizard still needs to run. The web app uses the
  /// same signal — `gender` is the first thing the wizard collects.
  bool get needsProfileSetup => (gender ?? '').isEmpty;

  // --- Entitlements ------------------------------------------------------
  // These mirror the server's rules so the UI can hide what the user cannot
  // use. They are a convenience, never the authority: every one of these is
  // enforced again in the controllers, because a client check is bypassable.

  bool get canSendMessages => isAdmin || tier.isPaid;
  bool get canSeeWhoLikedYou => isAdmin || tier.isPaid;
  bool get hasUnlimitedBrowsing => isAdmin || tier.isPaid;
  bool get canUseAdvancedFilters => isAdmin || tier.isUpperTier;
  bool get canSeeProfileVisitors => isAdmin || tier.isUpperTier;
  bool get canSuperLike => isAdmin || tier.isUpperTier;

  /// Free members see only the first five results; the server truncates the
  /// list as well, so this is purely for messaging in the UI.
  static const int freeBrowseLimit = 5;

  int get weeklySuperLikes => switch (tier) {
        PlanTier.prestige => 6,
        PlanTier.premium => 3,
        _ => 0,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // `plan` arrives populated as an object, or null on a fresh Free account.
    // Admins are handed a synthetic `{tier: 'Prestige', name: 'Admin Lifetime'}`
    // by the backend rather than a real plan document.
    final plan = json['plan'];
    final planMap = plan is Map ? Map<String, dynamic>.from(plan) : null;

    final rawCoords = (json['locationCoords'] as Map?)?['coordinates'] as List?;
    (double, double)? coords;
    if (rawCoords != null && rawCoords.length >= 2) {
      final lng = (rawCoords[0] as num?)?.toDouble() ?? 0;
      final lat = (rawCoords[1] as num?)?.toDouble() ?? 0;
      if (lng != 0 || lat != 0) coords = (lng, lat);
    }

    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
      gender: json['gender'] as String?,
      lookingFor: json['lookingFor'] as String?,
      ageRange: json['ageRange'] as String?,
      age: (json['age'] as num?)?.toInt(),
      location: json['location'] as String?,
      photo: json['photo'] as String?,
      photos: (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      bio: json['bio'] as String?,
      planName: planMap?['name'] as String?,
      tier: PlanTier.parse(planMap?['tier'] as String?),
      subscriptionStatus: json['subscriptionStatus'] as String?,
      subscriptionExpiry: DateTime.tryParse((json['subscriptionExpiry'] ?? '').toString()),
      coordinates: coords,
    );
  }

  /// Same member, different tier. Used by the development override that shows
  /// the paid screens without a subscription — see `DevFlags.previewAsPrestige`.
  UserModel withTier(PlanTier newTier) => UserModel(
        id: id,
        name: name,
        email: email,
        role: role,
        gender: gender,
        lookingFor: lookingFor,
        ageRange: ageRange,
        age: age,
        location: location,
        photo: photo,
        photos: photos,
        bio: bio,
        planName: planName,
        tier: newTier,
        subscriptionStatus: subscriptionStatus,
        subscriptionExpiry: subscriptionExpiry,
        coordinates: coordinates,
      );

  /// `GET /users/me` returns fewer fields than `PATCH /users/me` — it drops
  /// photos, bio, coordinates and most profile detail. Merging rather than
  /// replacing keeps the richer values that an earlier profile save gave us,
  /// which is the bug the web app still has.
  UserModel mergedWith(UserModel fresh) => UserModel(
        id: fresh.id.isNotEmpty ? fresh.id : id,
        name: fresh.name.isNotEmpty ? fresh.name : name,
        email: fresh.email.isNotEmpty ? fresh.email : email,
        role: fresh.role,
        gender: fresh.gender ?? gender,
        lookingFor: fresh.lookingFor ?? lookingFor,
        ageRange: fresh.ageRange ?? ageRange,
        age: fresh.age ?? age,
        location: fresh.location ?? location,
        photo: fresh.photo ?? photo,
        photos: fresh.photos.isNotEmpty ? fresh.photos : photos,
        bio: fresh.bio ?? bio,
        planName: fresh.planName ?? planName,
        tier: fresh.tier,
        subscriptionStatus: fresh.subscriptionStatus ?? subscriptionStatus,
        subscriptionExpiry: fresh.subscriptionExpiry ?? subscriptionExpiry,
        coordinates: fresh.coordinates ?? coordinates,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'gender': gender,
        'lookingFor': lookingFor,
        'ageRange': ageRange,
        'age': age,
        'location': location,
        'photo': photo,
        'photos': photos,
        'bio': bio,
        'plan': {'name': planName, 'tier': tier.name},
        'subscriptionStatus': subscriptionStatus,
        'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
        if (coordinates != null)
          'locationCoords': {
            'type': 'Point',
            'coordinates': [coordinates!.$1, coordinates!.$2],
          },
      };
}
