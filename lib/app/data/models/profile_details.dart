import 'match_model.dart';
import 'user_model.dart';

/// One shape for the profile screen, whichever member it is showing.
///
/// The signed-in member arrives as a [UserModel] and everyone else as a
/// [MatchModel]; the two carry the same profile fields from different
/// endpoints. Folding them here keeps the screen from branching on which one
/// it was handed.
class ProfileDetails {
  const ProfileDetails({
    required this.id,
    required this.name,
    required this.isOwn,
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
    this.eyeColor,
    this.hairColor,
    this.smoke,
    this.alcohol,
    this.planName,
    this.lookingFor,
    this.ageRange,
  });

  final String id;
  final String name;
  final bool isOwn;
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
  final String? eyeColor;
  final String? hairColor;
  final String? smoke;
  final String? alcohol;

  /// Own profile only — nobody is shown another member's plan or preferences.
  final String? planName;
  final String? lookingFor;
  final String? ageRange;

  factory ProfileDetails.own(UserModel user) => ProfileDetails(
        id: user.id,
        name: user.name,
        isOwn: true,
        age: user.age,
        location: user.location,
        gender: user.gender,
        photo: user.photo,
        photos: user.photos,
        bio: user.bio,
        hobbies: user.hobbies,
        favoriteActivities: user.favoriteActivities,
        zodiacSign: user.zodiacSign,
        religion: user.religion,
        children: user.children,
        height: user.height,
        eyeColor: user.eyeColor,
        hairColor: user.hairColor,
        smoke: user.smoke,
        alcohol: user.alcohol,
        planName: user.planName ?? user.tier.label,
        lookingFor: user.lookingFor,
        ageRange: user.ageRange,
      );

  factory ProfileDetails.other(MatchModel match) => ProfileDetails(
        id: match.id,
        name: match.name,
        isOwn: false,
        age: match.age,
        location: match.location,
        gender: match.gender,
        photo: match.photo,
        photos: match.photos,
        bio: match.bio,
        hobbies: match.hobbies,
        favoriteActivities: match.favoriteActivities,
        zodiacSign: match.zodiacSign,
        religion: match.religion,
        children: match.children,
        height: match.height,
        eyeColor: match.eyeColor,
        hairColor: match.hairColor,
        smoke: match.smoke,
        alcohol: match.alcohol,
      );

  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  /// Photos for the cover carousel, with the main one first and duplicates
  /// removed — the gallery and the avatar often hold the same image.
  List<String> get gallery {
    final all = <String>[
      if ((photo ?? '').isNotEmpty) photo!,
      ...photos.where((p) => p.isNotEmpty),
    ];
    return all.toSet().toList();
  }
}
