import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/member_avatar.dart';
import '../../data/models/profile_details.dart';
import '../../routes/app_routes.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Own profile is a drawer destination; somebody else's was pushed on top
      // of Discover, so that one gets a back arrow instead.
      drawer: controller.isOwn ? const AppDrawer(current: AppRoutes.profile) : null,
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final member = controller.profile.value;
        if (member == null) {
          return _NotFound(message: controller.error.value);
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: CustomScrollView(
            slivers: [
              _Cover(member: member),
              SliverToBoxAdapter(
                child: Obx(() => ProfileContent(
                      member: member,
                      busy: controller.acting.value,
                      onEdit: () => Get.toNamed(AppRoutes.settings),
                      onLike: controller.like,
                      onMessage: () =>
                          Get.toNamed(AppRoutes.messages, arguments: member.id),
                      onBlock: controller.block,
                      onReport: controller.report,
                    )),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Photo carousel behind a collapsing bar. Falls back to the brand gradient
/// with the member's initial when there is no photo at all.
class _Cover extends GetView<ProfileController> {
  const _Cover({required this.member});

  final ProfileDetails member;

  @override
  Widget build(BuildContext context) {
    final gallery = member.gallery;

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: controller.isOwn
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                tooltip: TrKeys.navMenu.tr,
                onPressed: Scaffold.of(context).openDrawer,
              ),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: TrKeys.back.tr,
              onPressed: Get.back,
            ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Obx(() {
              final index = controller.activePhoto.value.clamp(
                0,
                gallery.isEmpty ? 0 : gallery.length - 1,
              );
              return MemberAvatar.fill(
                initial: member.initial,
                photo: gallery.isEmpty ? null : gallery[index],
              );
            }),
            // Keeps the leading icon and the dots legible over any photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black54],
                  stops: [0, 0.35, 1],
                ),
              ),
            ),
            if (gallery.length > 1)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < gallery.length; i++)
                          GestureDetector(
                            onTap: () => controller.showPhoto(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 6,
                              width: controller.activePhoto.value == i ? 22 : 6,
                              decoration: BoxDecoration(
                                color: controller.activePhoto.value == i
                                    ? Colors.white
                                    : Colors.white54,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                      ],
                    )),
              ),
          ],
        ),
      ),
    );
  }
}

/// Everything below the cover photo.
///
/// Deliberately free of controllers: it takes the member and a callback per
/// action, so a test can render it at any width without starting the app's
/// services. That matters here — this screen is long, and French copy runs
/// longer than the English it was laid out in.
class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.member,
    this.busy = false,
    this.onEdit,
    this.onLike,
    this.onMessage,
    this.onBlock,
    this.onReport,
  });

  final ProfileDetails member;
  final bool busy;
  final VoidCallback? onEdit;
  final VoidCallback? onLike;
  final VoidCallback? onMessage;
  final VoidCallback? onBlock;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NameLine(member: member),
          const SizedBox(height: 20),
          _Actions(
            member: member,
            busy: busy,
            onEdit: onEdit,
            onLike: onLike,
            onMessage: onMessage,
            onBlock: onBlock,
            onReport: onReport,
          ),
          const SizedBox(height: 28),

          _SectionTitle(member.isOwn
              ? TrKeys.profileAboutMe.tr
              : TrKeys.profileAboutOther.trParams({'name': member.name})),
          Text(
            (member.bio ?? '').isEmpty ? TrKeys.profileNoBio.tr : member.bio!,
            style: text.bodyLarge,
          ),
          const SizedBox(height: 28),

          _SectionTitle(TrKeys.profileQuickInfo.tr),
          _QuickInfo(member: member),

          if (member.isOwn) ...[
            const SizedBox(height: 28),
            _SectionTitle(TrKeys.profileMyPreferences.tr),
            _Preferences(member: member),
          ],

          const SizedBox(height: 28),
          const _SafetyCard(),

          const SizedBox(height: 28),
          _SectionTitle(TrKeys.profileDetails.tr),
          _Details(member: member),
        ],
      ),
    );
  }
}

class _NameLine extends StatelessWidget {
  const _NameLine({required this.member});

  final ProfileDetails member;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                member.age == null ? member.name : '${member.name}, ${member.age}',
                style: text.headlineLarge,
              ),
            ),
            // The rose full stop the website sets after the name.
            Text('.', style: text.headlineLarge?.copyWith(color: scheme.primary)),
          ],
        ),
        if ((member.location ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 15, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Flexible(child: Text(member.location!, style: text.bodySmall)),
            ],
          ),
        ],
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.member,
    required this.busy,
    this.onEdit,
    this.onLike,
    this.onMessage,
    this.onBlock,
    this.onReport,
  });

  final ProfileDetails member;
  final bool busy;
  final VoidCallback? onEdit;
  final VoidCallback? onLike;
  final VoidCallback? onMessage;
  final VoidCallback? onBlock;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    // Two buttons share the row, and French labels run long — "Paramètres"
    // against a 320px screen leaves almost nothing. Trim the padding, drop the
    // type a little, and let the label itself shrink rather than push the row
    // wider than it is allowed to be.
    final tight = ButtonStyle(
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 8)),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );

    if (member.isOwn) {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onEdit,
              style: tight,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(TrKeys.profileEdit.tr, overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEdit,
              style: tight,
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: Text(TrKeys.navSettings.tr, overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: busy ? null : onLike,
                style: tight,
                icon: const Icon(Icons.favorite_rounded, size: 18),
                label: Text(TrKeys.profileLike.tr, overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onMessage,
                style: tight,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: Text(TrKeys.discoverMessage.tr, overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: onBlock,
                icon: const Icon(Icons.person_off_outlined, size: 17),
                label: Text(TrKeys.profileBlock.tr, overflow: TextOverflow.ellipsis, maxLines: 1),
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: onReport,
                icon: const Icon(Icons.flag_outlined, size: 17),
                label: Text(TrKeys.profileReport.tr, overflow: TextOverflow.ellipsis, maxLines: 1),
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickInfo extends StatelessWidget {
  const _QuickInfo({required this.member});

  final ProfileDetails member;

  @override
  Widget build(BuildContext context) {
    final gender = switch (member.gender) {
      'man' => TrKeys.psMan.tr,
      'woman' => TrKeys.psWoman.tr,
      _ => null,
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (member.age != null)
          _Stat(
            label: TrKeys.age.tr,
            value: TrKeys.psYearsOld.trParams({'count': '${member.age}'}),
          ),
        if (gender != null) _Stat(label: TrKeys.profileGender.tr, value: gender),
        if (member.isOwn && (member.planName ?? '').isNotEmpty)
          _Stat(label: TrKeys.profileSubscription.tr, value: member.planName!),
      ],
    );
  }
}

class _Preferences extends StatelessWidget {
  const _Preferences({required this.member});

  final ProfileDetails member;

  @override
  Widget build(BuildContext context) {
    String personLabel(String? raw) => switch (raw) {
          'man' => TrKeys.psMan.tr,
          'woman' => TrKeys.psWoman.tr,
          'everyone' => TrKeys.psEveryone.tr,
          _ => TrKeys.profileNotSet.tr,
        };

    return Column(
      children: [
        _Row(label: TrKeys.profileIAm.tr, value: personLabel(member.gender)),
        _Row(
            label: TrKeys.profileLookingFor.tr,
            value: personLabel(member.lookingFor)),
        _Row(
          label: TrKeys.psAgeRangeTitle.tr,
          value: (member.ageRange ?? '').isEmpty
              ? TrKeys.profileNotSet.tr
              : member.ageRange!,
        ),
        _Row(
          label: TrKeys.psLocationTitle.tr,
          value: (member.location ?? '').isEmpty
              ? TrKeys.profileNotSet.tr
              : member.location!,
        ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.member});

  final ProfileDetails member;

  @override
  Widget build(BuildContext context) {
    // Values are shown exactly as they were saved. The website tries to map
    // them onto a different vocabulary — 'yes'/'no' for smoking, 'have'/'want'
    // for children — which never matches what its own forms store, so the rows
    // end up blank there.
    final entries = <(IconData, String, String?)>[
      (Icons.favorite_border_rounded, TrKeys.profileHobbies.tr, member.hobbies),
      (Icons.local_activity_outlined, TrKeys.profileActivities.tr,
          member.favoriteActivities),
      (Icons.nightlight_outlined, TrKeys.profileZodiac.tr, member.zodiacSign),
      (Icons.auto_awesome_outlined, TrKeys.profileReligion.tr, member.religion),
      (Icons.child_care_outlined, TrKeys.profileChildren.tr, member.children),
      (
        Icons.straighten_outlined,
        TrKeys.profileHeight.tr,
        (member.height ?? '').isEmpty
            ? null
            : TrKeys.profileHeightCm.trParams({'value': member.height!})
      ),
      (Icons.visibility_outlined, TrKeys.profileEyes.tr, member.eyeColor),
      (Icons.content_cut_outlined, TrKeys.profileHair.tr, member.hairColor),
      (Icons.smoking_rooms_outlined, TrKeys.profileSmoke.tr, member.smoke),
      (Icons.wine_bar_outlined, TrKeys.profileAlcohol.tr, member.alcohol),
    ];

    // Empty rows are an invitation to fill them in on your own profile, and
    // noise on anyone else's.
    final visible = member.isOwn
        ? entries
        : entries.where((e) => (e.$3 ?? '').isNotEmpty).toList();

    if (visible.isEmpty) {
      return Text(TrKeys.profileNoBio.tr,
          style: Theme.of(context).textTheme.bodySmall);
    }

    return Column(
      children: [
        for (final (icon, label, value) in visible)
          _DetailTile(
            icon: icon,
            label: label,
            value: value,
            onTap: member.isOwn ? () => Get.toNamed(AppRoutes.settings) : null,
          ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final empty = (value ?? '').isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: empty
            ? scheme.primary.withValues(alpha: 0.05)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(kRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadius),
              border: Border.all(
                color: empty
                    ? scheme.primary.withValues(alpha: 0.3)
                    : scheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.9,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        empty ? TrKeys.profileAdd.tr : value!,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: empty ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadius),
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            // Both sides can be long — "TRANCHE D'ÂGE PRÉFÉRÉE" against a value
            // like "Non spécifié" — so neither is allowed to push the row wider
            // than the card.
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        color: scheme.primary.withValues(alpha: 0.06),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.shield_outlined, size: 18, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(TrKeys.profileSafetyTitle.tr, style: text.titleMedium),
                const SizedBox(height: 4),
                Text(TrKeys.profileSafetyBody.tr, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: Theme.of(context).textTheme.headlineMedium),
      );
}

class _NotFound extends StatelessWidget {
  const _NotFound({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_off_outlined,
                  size: 40, color: scheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(TrKeys.profileNotFound.tr,
                  style: text.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message ?? TrKeys.profileNotFoundBody.tr,
                  style: text.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => Get.offAllNamed(AppRoutes.discover),
                child: Text(TrKeys.profileBackToDiscover.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
