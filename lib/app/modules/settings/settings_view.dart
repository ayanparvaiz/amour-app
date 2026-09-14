import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/member_avatar.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'settings_controller.dart';

/// The settings menu — where everything about the account lives. Editing the
/// profile itself is one entry here, not this screen.
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(TrKeys.navSettings.tr)),
      drawer: const AppDrawer(current: AppRoutes.settings),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const _AccountHeader(),
          const SizedBox(height: 26),

          _Group(
            title: TrKeys.setMenuAccount.tr,
            children: [
              _Row(
                icon: Icons.person_outline_rounded,
                label: TrKeys.setEditProfile.tr,
                sublabel: TrKeys.setEditProfileBody.tr,
                onTap: () => Get.toNamed(AppRoutes.editProfile),
              ),
              _Row(
                icon: Icons.lock_outline_rounded,
                label: TrKeys.changePasswordTitle.tr,
                onTap: () => Get.toNamed(AppRoutes.changePassword),
              ),
              _Row(
                icon: Icons.workspace_premium_outlined,
                label: TrKeys.navPlans.tr,
                onTap: () => Get.toNamed(AppRoutes.plans),
              ),
            ],
          ),
          const SizedBox(height: 22),

          _Group(
            title: TrKeys.setMenuLegal.tr,
            children: [
              _Row(
                icon: Icons.shield_outlined,
                label: TrKeys.navTerms.tr,
                onTap: () => Get.toNamed(AppRoutes.terms),
              ),
              _Row(
                icon: Icons.privacy_tip_outlined,
                label: TrKeys.setPrivacy.tr,
                onTap: () => Get.toNamed(AppRoutes.privacy),
              ),
            ],
          ),
          const SizedBox(height: 22),

          _Group(
            title: TrKeys.setMenuDanger.tr,
            children: [
              _Row(
                icon: Icons.logout_rounded,
                label: TrKeys.signOut.tr,
                onTap: controller.signOut,
                tint: scheme.onSurface,
              ),
              Obx(() => _Row(
                    icon: Icons.delete_forever_outlined,
                    label: TrKeys.setDeleteAccount.tr,
                    sublabel: TrKeys.setDeleteBody.tr,
                    onTap: controller.deleting.value
                        ? null
                        : controller.deleteAccount,
                    tint: scheme.error,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final user = AuthService.to.user;
      if (user == null) return const SizedBox.shrink();

      return Row(
        children: [
          MemberAvatar(
            initial: user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
            photo: user.photo,
            size: 54,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(user.email,
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.planName ?? user.tier.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
            color: scheme.surface,
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(height: 1, indent: 52, color: scheme.outline),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.sublabel,
    this.onTap,
    this.tint,
  });

  final IconData icon;
  final String label;
  final String? sublabel;
  final VoidCallback? onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colour = tint ?? scheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 21, color: tint ?? scheme.primary),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: colour,
                    ),
                  ),
                  if (sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(sublabel!,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant,
                        )),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
