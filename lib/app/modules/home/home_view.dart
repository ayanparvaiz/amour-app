import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';

/// Placeholder. Its only job today is to prove the session, the API client and
/// the entitlement mapping all work against the live backend — the real screens
/// replace it.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amour Et Sincérité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Se déconnecter',
            onPressed: AuthService.to.signOut,
          ),
        ],
      ),
      body: Obx(() {
        final user = AuthService.to.user;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async => AuthService.to.refresh(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Bonjour ${user.name} 👋', style: text.headlineLarge),
              const SizedBox(height: 6),
              Text(user.email, style: text.bodySmall),
              const SizedBox(height: 22),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.workspace_premium_outlined,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(user.planName ?? user.tier.label,
                              style: text.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _Entitlement('Envoyer des messages', user.canSendMessages),
                      _Entitlement('Voir qui vous a liké', user.canSeeWhoLikedYou),
                      _Entitlement('Filtres avancés', user.canUseAdvancedFilters),
                      _Entitlement('Visiteurs du profil', user.canSeeProfileVisitors),
                      _Entitlement(
                        user.canSuperLike
                            ? 'Super Likes (${user.weeklySuperLikes}/semaine)'
                            : 'Super Likes',
                        user.canSuperLike,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Les écrans de l\'application arrivent ensuite.',
                style: text.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Entitlement extends StatelessWidget {
  const _Entitlement(this.label, this.allowed);

  final String label;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            allowed ? Icons.check_circle_rounded : Icons.remove_circle_outline,
            size: 18,
            color: allowed ? AppColors.online : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                color: allowed ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
