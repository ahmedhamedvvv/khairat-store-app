import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/phone_frame.dart';
import 'core/theme.dart';
import 'features/account/account_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/catalog/catalog_screens.dart';
import 'features/checkout/checkout_screen.dart';
import 'features/checkout/success_screen.dart';
import 'features/home/home_screen.dart';
import 'features/merchant/merchant_screens.dart';
import 'features/orders/invoice_screen.dart';
import 'features/orders/orders_screens.dart';
import 'features/product/product_screen.dart';
import 'features/welcome/welcome_screens.dart';
import 'l10n/app_localizations.dart';
import 'state/providers.dart';
import 'widgets/shells.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Read once: the router redirects on role changes through refreshListenable.
  final roleListenable = ValueNotifier<Role?>(ref.read(settingsProvider).role);
  ref.listen(settingsProvider.select((s) => s.role), (_, r) => roleListenable.value = r);
  ref.onDispose(roleListenable.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: roleListenable,
    redirect: (context, state) {
      final role = roleListenable.value;
      final loc = state.matchedLocation;
      final atWelcome = loc == '/' || loc == '/login';
      if (role == null) return atWelcome ? null : '/';
      if (loc == '/') return role == Role.merchant ? '/merchant' : '/home';
      if (role == Role.merchant && !loc.startsWith('/merchant') && loc != '/login') return '/merchant';
      if (role == Role.customer && loc.startsWith('/merchant')) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => CustomerShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/categories', builder: (_, _) => const CategoriesScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/cart', builder: (_, _) => const CartScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/orders', builder: (_, _) => const OrdersScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/account', builder: (_, _) => const AccountScreen())],
          ),
        ],
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/search', builder: (_, _) => const SearchScreen()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/favorites', builder: (_, _) => const FavoritesScreen()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/category/:id',
        builder: (_, s) => CategoryScreen(id: s.pathParameters['id']!, initialFilter: s.uri.queryParameters['f']),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/product/:id',
        builder: (_, s) => ProductScreen(id: s.pathParameters['id']!, heroTag: s.extra as String?),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/checkout', builder: (_, _) => const CheckoutScreen()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/success/:id',
        pageBuilder: (_, s) => CustomTransitionPage(
          child: SuccessScreen(id: s.pathParameters['id']!),
          transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/order/:id',
        builder: (_, s) => OrderDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/invoice/:id',
        builder: (_, s) => InvoiceScreen(id: s.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MerchantShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/merchant', builder: (_, _) => const DashboardScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/merchant/orders',
                builder: (_, s) => MerchantOrdersScreen(initial: s.uri.queryParameters['s']),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/merchant/products',
                builder: (_, s) => MerchantProductsScreen(lowOnly: s.uri.queryParameters['low'] == '1'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/merchant/coupons', builder: (_, _) => const CouponsScreen())],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/merchant/order/:id',
        builder: (_, s) => MerchantOrderScreen(id: s.pathParameters['id']!),
      ),
    ],
  );
});

class KhairatApp extends ConsumerWidget {
  const KhairatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      onGenerateTitle: (c) => S.of(c).appName,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      locale: settings.locale,
      supportedLocales: S.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: settings.themeMode,
      builder: (context, child) => PhoneFrame(child: child!),
    );
  }
}
