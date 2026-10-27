import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import 'format.dart';
import 'theme.dart';

/// `?embed=1` drops the frame so the portfolio site can iframe the app in its own mockup.
final bool embedMode = () {
  final base = Uri.base;
  if (base.queryParameters['embed'] == '1') return true;
  final frag = base.fragment;
  final q = frag.indexOf('?');
  return q >= 0 && Uri.splitQueryString(frag.substring(q + 1))['embed'] == '1';
}();

const _phone = Size(390, 844);

/// On wide screens, shows the app inside a phone with a short pitch beside it.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (embedMode || mq.size.width < 900 || mq.size.height < 600) return child;

    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: dark ? const Color(0xFF0E0A08) : const Color(0xFFEFE5D6),
      child: Row(
        children: [
          // Keeps keyboard focus inside the phone; the panel's buttons still take clicks.
          const Expanded(child: ExcludeFocus(child: _SidePanel())),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: FittedBox(
                child: Container(
                  width: _phone.width + 24,
                  height: _phone.height + 24,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1411),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [BoxShadow(blurRadius: 60, offset: const Offset(0, 30), color: Colors.black.withValues(alpha: 0.35))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(48),
                    child: MediaQuery(
                      data: mq.copyWith(
                        size: _phone,
                        padding: const EdgeInsets.only(top: 50, bottom: 24),
                        viewPadding: const EdgeInsets.only(top: 50, bottom: 24),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(child: child),
                          const Positioned(top: 0, left: 0, right: 0, child: _StatusBar()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 34,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      Text(
                        '9:41',
                        style: TextStyle(fontFamily: Tokens.font, fontWeight: FontWeight.w700, fontSize: 15, color: color),
                      ),
                      const Spacer(),
                      Icon(Icons.signal_cellular_alt_rounded, size: 17, color: color),
                      const SizedBox(width: 4),
                      Icon(Icons.wifi_rounded, size: 17, color: color),
                      const SizedBox(width: 4),
                      Icon(Icons.battery_full_rounded, size: 19, color: color),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidePanel extends ConsumerWidget {
  const _SidePanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final settings = ref.watch(settingsProvider);
    final features = [
      (Icons.payments_rounded, s.sideF1),
      (Icons.receipt_long_rounded, s.sideF2),
      (Icons.local_shipping_rounded, s.sideF3),
      (Icons.space_dashboard_rounded, s.sideF4),
      (Icons.translate_rounded, s.sideF5),
    ];
    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: Palette.oud, borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      child: const Text(
                        'خ',
                        style: TextStyle(fontFamily: Tokens.font, fontSize: 28, fontWeight: FontWeight.w700, color: Palette.gold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(s.appName, style: context.text.headlineMedium),
                  ],
                ),
                const SizedBox(height: 20),
                Text(s.sideTitle, style: context.text.titleLarge),
                const SizedBox(height: 8),
                Text(s.sideBody, style: context.text.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant)),
                const SizedBox(height: 24),
                for (final (icon, label) in features)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: context.colors.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(label, style: context.text.bodyMedium)),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (settings.role != null)
                      FilledButton.tonalIcon(
                        onPressed: () => ref.read(settingsProvider.notifier).setRole(settings.role == Role.customer ? Role.merchant : Role.customer),
                        icon: const Icon(Icons.swap_horiz_rounded),
                        label: Text(settings.role == Role.customer ? s.switchToMerchant : s.switchToCustomer),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => ref.read(settingsProvider.notifier).toggleLocale(),
                      icon: const Icon(Icons.language_rounded),
                      label: Text(context.isAr ? 'English' : 'العربية'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => ref.read(settingsProvider.notifier).setTheme(settings.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
                      icon: Icon(settings.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                      label: Text(s.darkMode),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Flutter • Riverpod • go_router • fl_chart', style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
