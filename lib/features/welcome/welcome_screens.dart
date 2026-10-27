import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/photos.dart';
import '../../state/providers.dart';
import '../../widgets/product_art.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final arts = [
      (ArtKind.bottle, const Color(0xFF5A2E22), const Color(0xFFD4AF6A), productPhoto('p2')),
      (ArtKind.abaya, const Color(0xFF16161B), const Color(0xFFC9A35B), productPhoto('a1')),
      (ArtKind.datesBowl, const Color(0xFF5C2E1A), const Color(0xFFA7663A), productPhoto('d1')),
    ];
    return Scaffold(
      backgroundColor: Palette.oudDeep,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Palette.oud, Palette.oudDeep]),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Tokens.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Tokens.s16),
                  Row(
                    children: [
                      Text(s.appName, style: context.text.headlineSmall?.copyWith(color: Palette.gold)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => ref.read(settingsProvider.notifier).toggleLocale(),
                        child: Text(context.isAr ? 'English' : 'العربية', style: const TextStyle(color: Palette.goldSoft)),
                      ),
                    ],
                  ),
                  const SizedBox(height: Tokens.s24),
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        for (var i = 0; i < arts.length; i++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: i == 1 ? 0 : 36, left: 6, right: 6),
                              child: ProductArt(kind: arts[i].$1, color: arts[i].$2, accent: arts[i].$3, radius: 24, photo: arts[i].$4)
                                  .animate(onPlay: (c) => c.repeat(reverse: true))
                                  .moveY(begin: 0, end: -8, duration: (1600 + i * 300).ms, curve: Curves.easeInOut),
                            ).animate().fadeIn(delay: (120 * i).ms, duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Tokens.s32),
                  Text(s.welcomeTitle, style: context.text.headlineMedium?.copyWith(color: Colors.white)).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                  const SizedBox(height: Tokens.s12),
                  Text(s.welcomeBody, style: context.text.bodyLarge?.copyWith(color: Palette.goldSoft.withValues(alpha: 0.85))).animate().fadeIn(delay: 400.ms),
                  const Spacer(),
                  _RoleCard(
                    icon: Icons.shopping_bag_rounded,
                    title: s.shopAsCustomer,
                    body: s.shopAsCustomerBody,
                    primary: true,
                    onTap: () => context.push('/login'),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, curve: Curves.easeOutCubic),
                  const SizedBox(height: Tokens.s12),
                  _RoleCard(
                    icon: Icons.space_dashboard_rounded,
                    title: s.enterAsMerchant,
                    body: s.enterAsMerchantBody,
                    onTap: () => ref.read(settingsProvider.notifier).setRole(Role.merchant),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, curve: Curves.easeOutCubic),
                  const SizedBox(height: Tokens.s16),
                  Center(
                    child: Text(s.demoNote, style: context.text.labelMedium?.copyWith(color: Palette.goldSoft.withValues(alpha: 0.6))),
                  ),
                  const SizedBox(height: Tokens.s16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.icon, required this.title, required this.body, required this.onTap, this.primary = false});
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? Palette.oudDeep : Colors.white;
    return Material(
      color: primary ? Palette.gold : Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(Tokens.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: fg.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(Tokens.controlRadius)),
                child: Icon(icon, color: fg),
              ),
              const SizedBox(width: Tokens.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleMedium?.copyWith(color: fg)),
                    Text(body, style: context.text.bodySmall?.copyWith(color: fg.withValues(alpha: 0.75))),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: fg, textDirection: Directionality.of(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController(text: '551234567');
  final _otp = TextEditingController();
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _send() {
    final v = _phone.text.replaceAll(' ', '');
    if (!RegExp(r'^5\d{8}$').hasMatch(v)) {
      setState(() => _error = context.s.phoneInvalid);
      return;
    }
    setState(() {
      _error = null;
      _sent = true;
    });
  }

  void _verify() {
    ref.read(settingsProvider.notifier).login('+966 ${_phone.text}');
    ref.read(settingsProvider.notifier).setRole(Role.customer);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Tokens.s24),
          children: [
            Text(_sent ? s.otpTitle : s.loginTitle, style: context.text.headlineSmall),
            const SizedBox(height: Tokens.s8),
            Text(
              _sent ? s.otpHint('\u2066+966 ${_phone.text}\u2069') : s.loginSubtitle,
              style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: Tokens.s32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _sent
                  ? _OtpField(key: const ValueKey('otp'), controller: _otp, onDone: _verify)
                  : Directionality(
                      key: const ValueKey('phone'),
                      textDirection: TextDirection.ltr,
                      child: TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                        style: context.text.titleMedium,
                        decoration: InputDecoration(
                          labelText: s.phoneLabel,
                          errorText: _error,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            child: Text('+966', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: Tokens.s24),
            FilledButton(onPressed: _sent ? _verify : _send, child: Text(_sent ? s.verify : s.sendCode)),
            const SizedBox(height: Tokens.s12),
            TextButton(onPressed: () => ref.read(settingsProvider.notifier).setRole(Role.customer), child: Text(s.continueAsGuest)),
          ],
        ),
      ),
    );
  }
}

class _OtpField extends StatelessWidget {
  const _OtpField({super.key, required this.controller, required this.onDone});
  final TextEditingController controller;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, v, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 4; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 60,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(Tokens.controlRadius),
                      border: Border.all(color: i == v.text.length ? context.colors.primary : context.colors.outline, width: i == v.text.length ? 2 : 1),
                    ),
                    child: Text(i < v.text.length ? v.text[i] : '', style: context.text.headlineSmall),
                  ),
              ],
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                onChanged: (v) {
                  if (v.length == 4) onDone();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
