import 'package:flutter/foundation.dart';

/// Switches that exist only to make the app testable while it is being built.
///
/// Every one is gated behind [kDebugMode], so a release build ignores them even
/// if someone leaves one switched on. Flip a value, then **hot restart** — a
/// hot reload will not pick these up.
class DevFlags {
  DevFlags._();

  // ───────────────────────────────────────────────────────────────────────────
  //  Language
  //
  //  false → English, easier to read while building
  //  true  → French, the language the app ships in
  //
  //  French runs longer than English for the same sentence, so the labels that
  //  look comfortable in English are the ones that overflow. Check here before
  //  calling a screen finished.
  // ───────────────────────────────────────────────────────────────────────────
  static const bool _previewInFrench = false;

  // ───────────────────────────────────────────────────────────────────────────
  //  Subscription tier
  //
  //  false → the real plan the account holds
  //  true  → treat the signed-in member as Prestige
  //
  //  This unlocks the paid screens so they can be opened and laid out without
  //  a subscription. It is a *view* of the app, not a subscription: the server
  //  still enforces the real tier, so anything that calls the API — sending a
  //  message, opening the visitors list, spending a super like — still comes
  //  back 403. Use it to build and check paid screens; use a genuinely paid or
  //  admin account to test that they work.
  // ───────────────────────────────────────────────────────────────────────────
  static const bool _previewAsPrestige = false;

  static bool get previewInFrench => kDebugMode && _previewInFrench;

  static bool get previewAsPrestige => kDebugMode && _previewAsPrestige;
}
