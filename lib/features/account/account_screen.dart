import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/pricing.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final settings = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final orders = ref.watch(ordersProvider).length;
    final favs = ref.watch(favoritesProvider).length;

    return Scaffold(
      appBar: AppBar(title: Text(s.account)),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          Card(
            color: Palette.oud,
            child: Padding(
              padding: const EdgeInsets.all(Tokens.s16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Palette.gold,
                    child: Icon(Icons.person_rounded, color: Palette.oudDeep, size: 30),
                  ),
                  const SizedBox(width: Tokens.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.phone == null ? s.guest : (context.isAr ? 'نورة العتيبي' : 'Noura Al-Otaibi'),
                          style: context.text.titleMedium?.copyWith(color: Colors.white),
                        ),
                        Text(
                          settings.phone ?? s.continueAsGuest,
                          textDirection: TextDirection.ltr,
                          style: context.text.bodySmall?.copyWith(color: Palette.goldSoft),
                        ),
                      ],
                    ),
                  ),
                  if (settings.phone == null)
                    FilledButton(
                      onPressed: () => context.push('/login'),
                      style: FilledButton.styleFrom(backgroundColor: Palette.gold, foregroundColor: Palette.oudDeep, minimumSize: const Size(0, 40)),
                      child: Text(s.signIn),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Tokens.s12),
          Row(
            children: [
              Expanded(
                child: _Stat(icon: Icons.receipt_long_rounded, value: '$orders', label: s.myOrders, onTap: () => context.go('/orders')),
              ),
              const SizedBox(width: Tokens.s12),
              Expanded(
                child: _Stat(icon: Icons.favorite_rounded, value: '$favs', label: s.favorites, onTap: () => context.push('/favorites')),
              ),
            ],
          ),
          const SizedBox(height: Tokens.s16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(s.language),
                  trailing: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'ar', label: Text('عربي')),
                      ButtonSegment(value: 'en', label: Text('EN')),
                    ],
                    selected: {settings.locale.languageCode},
                    onSelectionChanged: (v) {
                      if (v.first != settings.locale.languageCode) n.toggleLocale();
                    },
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(s.darkMode),
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (v) => n.setTheme(v ? ThemeMode.dark : ThemeMode.light),
                ),
                ListTile(
                  leading: const Icon(Icons.public_rounded),
                  title: Text(s.region),
                  subtitle: Text(settings.region == Region.sa ? s.regionSa : s.regionAe),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (c) => SafeArea(
                      child: RadioGroup<Region>(
                        groupValue: settings.region,
                        onChanged: (r) {
                          n.setRegion(r!);
                          Navigator.pop(c);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile(value: Region.sa, title: Text(s.regionSa)),
                            RadioListTile(value: Region.ae, title: Text(s.regionAe)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Tokens.s12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storefront_rounded),
                  title: Text(s.switchToMerchant),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => n.setRole(Role.merchant),
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: Text(s.resetDemo),
                  onTap: () async {
                    await resetDemo(ref);
                    if (context.mounted) showToast(context, s.resetDone);
                  },
                ),
                ListTile(leading: const Icon(Icons.info_outline_rounded), title: Text(s.about), subtitle: Text(s.aboutBody)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label, required this.onTap});
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s16),
        child: Row(
          children: [
            Icon(icon, color: context.colors.secondary),
            const SizedBox(width: Tokens.s12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: context.text.titleLarge),
                Text(label, style: context.text.labelSmall),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
