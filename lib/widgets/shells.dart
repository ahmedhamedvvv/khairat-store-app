import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/format.dart';
import '../data/models.dart';
import '../state/providers.dart';
import 'common.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.storefront_outlined), selectedIcon: const Icon(Icons.storefront_rounded), label: s.navHome),
          NavigationDestination(icon: const Icon(Icons.grid_view_outlined), selectedIcon: const Icon(Icons.grid_view_rounded), label: s.navCategories),
          NavigationDestination(
            icon: CartBump(key: navCartKey, child: const CartBadgeIcon()),
            selectedIcon: const CartBadgeIcon(selected: true),
            label: s.navCart,
          ),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long_rounded), label: s.navOrders),
          NavigationDestination(icon: const Icon(Icons.person_outline_rounded), selectedIcon: const Icon(Icons.person_rounded), label: s.navAccount),
        ],
      ),
    );
  }
}

class MerchantShell extends ConsumerWidget {
  const MerchantShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final waiting = ref.watch(ordersProvider.select((o) => o.where((e) => e.status == OrderStatus.placed).length));
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.space_dashboard_outlined), selectedIcon: const Icon(Icons.space_dashboard_rounded), label: s.dashboard),
          NavigationDestination(
            icon: Badge(isLabelVisible: waiting > 0, label: Text('$waiting'), child: const Icon(Icons.inbox_outlined)),
            selectedIcon: Badge(isLabelVisible: waiting > 0, label: Text('$waiting'), child: const Icon(Icons.inbox_rounded)),
            label: s.orders,
          ),
          NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), selectedIcon: const Icon(Icons.inventory_2_rounded), label: s.products),
          NavigationDestination(icon: const Icon(Icons.local_offer_outlined), selectedIcon: const Icon(Icons.local_offer_rounded), label: s.coupons),
        ],
      ),
    );
  }
}

/// App bar action that flips between the shopper app and the merchant dashboard.
class RoleSwitchButton extends ConsumerWidget {
  const RoleSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(settingsProvider).role;
    return IconButton(
      tooltip: context.s.switchRole,
      icon: const Icon(Icons.swap_horiz_rounded),
      onPressed: () => ref.read(settingsProvider.notifier).setRole(role == Role.merchant ? Role.customer : Role.merchant),
    );
  }
}
