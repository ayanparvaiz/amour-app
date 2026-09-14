import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../localization/translation_keys.dart';
import '../theme/app_colors.dart';
import 'member_avatar.dart';

/// The app's main navigation, carrying the same destinations as the website's
/// menu. The admin entry appears only for administrators, as it does there.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.current});

  /// Route name of the screen showing now, so it can be marked and not
  /// navigated to again.
  final String current;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.user;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _Item(
                    icon: Icons.search_rounded,
                    label: TrKeys.navDiscover.tr,
                    route: AppRoutes.discover,
                    current: current,
                  ),
                  _Item(
                    icon: Icons.favorite_border_rounded,
                    label: TrKeys.navMatches.tr,
                    route: AppRoutes.matches,
                    current: current,
                  ),
                  _Item(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: TrKeys.navMessages.tr,
                    route: AppRoutes.messages,
                    current: current,
                  ),
                  _Item(
                    icon: Icons.person_outline_rounded,
                    label: TrKeys.navProfile.tr,
                    route: AppRoutes.profile,
                    current: current,
                  ),
                  _Item(
                    icon: Icons.workspace_premium_outlined,
                    label: TrKeys.navPlans.tr,
                    route: AppRoutes.plans,
                    current: current,
                  ),
                  const Divider(height: 20, indent: 20, endIndent: 20),
                  _Item(
                    icon: Icons.settings_outlined,
                    label: TrKeys.navSettings.tr,
                    route: AppRoutes.settings,
                    current: current,
                  ),
                  if (user?.isAdmin ?? false)
                    _Item(
                      icon: Icons.dashboard_outlined,
                      label: TrKeys.navAdmin.tr,
                      route: AppRoutes.admin,
                      current: current,
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            _SignOutTile(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = AuthService.to.user;
      final planLabel = user?.planName ?? user?.tier.label ?? '';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MemberAvatar(
              initial: (user?.name.isNotEmpty ?? false)
                  ? user!.name[0].toUpperCase()
                  : '?',
              photo: user?.photo,
              size: 60,
              borderColor: Colors.white,
            ),
            const SizedBox(height: 14),
            Text(
              user?.name ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              user?.email ?? '',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (planLabel.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      planLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.route,
    required this.current,
  });

  final IconData icon;
  final String label;
  final String route;
  final String current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = route == current;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        dense: true,
        selected: selected,
        selectedTileColor: scheme.primary.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(icon,
            size: 22,
            color: selected ? scheme.primary : scheme.onSurfaceVariant),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurface,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop(); // close the drawer first
          if (!selected) Get.toNamed(route);
        },
      ),
    );
  }
}

class _SignOutTile extends StatelessWidget {
  Future<void> _confirm(BuildContext context) async {
    Navigator.of(context).pop();

    final leave = await Get.dialog<bool>(
      AlertDialog(
        title: Text(TrKeys.signOutConfirmTitle.tr),
        content: Text(TrKeys.signOutConfirmBody.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              TrKeys.signOut.tr,
              style: const TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );

    if (leave ?? false) AuthService.to.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: const Icon(Icons.logout_rounded,
            size: 22, color: AppColors.destructive),
        title: Text(
          TrKeys.signOut.tr,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: AppColors.destructive,
          ),
        ),
        onTap: () => _confirm(context),
      ),
    );
  }
}
