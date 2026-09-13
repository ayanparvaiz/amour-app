import '../../core/constants/api_constants.dart';
import '../models/match_model.dart';
import '../providers/api_client.dart';

/// Everything the app reads or writes about *other* members. The signed-in
/// member's own record stays in AuthService.
class UserRepository {
  UserRepository({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  /// Candidate profiles, already scored by the server.
  ///
  /// `mode=discover` relaxes the two-way gender and age requirements, which is
  /// what the website's Explore listing sends. Leaving it off returns only the
  /// strict mutual matches the "Matchs Parfaits" row shows.
  Future<List<MatchModel>> matches({
    bool discoverMode = false,
    String? searchLevel,
    Map<String, dynamic> filters = const {},
  }) async {
    final body = await _api.get(
      ApiConstants.matches,
      query: {
        if (discoverMode) 'mode': 'discover',
        'searchLevel': ?searchLevel,
        ...filters,
      },
    );

    return ((body['matches'] as List?) ?? const [])
        .map((e) => MatchModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Mutual matches, plus who liked this member and who they liked.
  ///
  /// `likedBy` comes back empty for free accounts even though `likedByCount`
  /// is still populated — the server blanks the list but keeps the number, so
  /// the paywall can say how many are waiting.
  Future<AffinitiesResult> affinities() async {
    final body = await _api.get(ApiConstants.affinities);

    List<MatchModel> parse(String key) => ((body[key] as List?) ?? const [])
        .map((e) => MatchModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return AffinitiesResult(
      matches: parse('matches'),
      likedBy: parse('likedBy'),
      likesSent: parse('likes'),
      likedByCount: (body['likedByCount'] as num?)?.toInt() ?? 0,
    );
  }

  Future<MatchModel> profile(String id) async {
    final body = await _api.get(ApiConstants.publicProfile(id));
    return MatchModel.fromJson(Map<String, dynamic>.from(body['user'] as Map));
  }

  Future<LikeResult> like(String id) async =>
      LikeResult.fromJson(await _api.post(ApiConstants.like(id)));

  Future<LikeResult> superLike(String id) async =>
      LikeResult.fromJson(await _api.post(ApiConstants.superLike(id)));

  Future<void> pass(String id) => _api.post(ApiConstants.pass(id));

  Future<void> block(String id) => _api.post(ApiConstants.block(id));

  Future<void> report({required String userId, required String reason}) =>
      _api.post(ApiConstants.report,
          body: {'reportedUserId': userId, 'reason': reason});
}

class AffinitiesResult {
  const AffinitiesResult({
    required this.matches,
    required this.likedBy,
    required this.likesSent,
    required this.likedByCount,
  });

  final List<MatchModel> matches;
  final List<MatchModel> likedBy;
  final List<MatchModel> likesSent;
  final int likedByCount;
}
