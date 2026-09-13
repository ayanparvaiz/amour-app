/// A profile as it comes back from `GET /users/matches`.
///
/// The server scores every candidate and returns [matchPercent] alongside the
/// profile — it is computed, never stored, so it is part of this response
/// rather than of the member's own record.
class MatchModel {
  const MatchModel({
    required this.id,
    required this.name,
    this.age,
    this.location,
    this.gender,
    this.photo,
    this.photos = const [],
    this.bio,
    this.hobbies,
    this.favoriteActivities,
    this.zodiacSign,
    this.religion,
    this.children,
    this.height,
    this.smoke,
    this.alcohol,
    this.matchPercent,
  });

  final String id;
  final String name;
  final int? age;
  final String? location;
  final String? gender;
  final String? photo;
  final List<String> photos;
  final String? bio;
  final String? hobbies;
  final String? favoriteActivities;
  final String? zodiacSign;
  final String? religion;
  final String? children;
  final String? height;
  final String? smoke;
  final String? alcohol;
  final int? matchPercent;

  bool get hasPhoto => (photo ?? '').isNotEmpty;

  /// First letter of the name, for the fallback avatar.
  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    String? nonEmpty(Object? v) {
      final s = v?.toString().trim() ?? '';
      return s.isEmpty ? null : s;
    }

    return MatchModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      age: (json['age'] as num?)?.toInt(),
      location: nonEmpty(json['location']),
      gender: nonEmpty(json['gender']),
      photo: nonEmpty(json['photo']),
      photos: (json['photos'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      bio: nonEmpty(json['bio']),
      hobbies: nonEmpty(json['hobbies']),
      favoriteActivities: nonEmpty(json['favoriteActivities']),
      zodiacSign: nonEmpty(json['zodiacSign']),
      religion: nonEmpty(json['religion']),
      children: nonEmpty(json['children']),
      height: nonEmpty(json['height']),
      smoke: nonEmpty(json['smoke']),
      alcohol: nonEmpty(json['alcohol']),
      matchPercent: (json['matchPercent'] as num?)?.toInt(),
    );
  }
}

/// What `POST /users/like/:id` and the super-like route report back.
class LikeResult {
  const LikeResult({required this.isMatch, required this.message});

  final bool isMatch;
  final String message;

  factory LikeResult.fromJson(Map<String, dynamic> json) => LikeResult(
        isMatch: json['isMatch'] == true,
        message: (json['message'] ?? '').toString(),
      );
}
