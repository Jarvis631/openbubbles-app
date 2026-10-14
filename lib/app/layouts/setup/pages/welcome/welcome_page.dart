import 'package:bluebubbles/app/layouts/setup/pages/page_template.dart';
import 'package:bluebubbles/app/wrappers/stateful_boilerplate.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Premium welcome screen for the experimental OpenBubbles Alpha build.
// This file only changes onboarding presentation. It does not modify
// iMessage registration, account handling, or the conversation database.
const Color _background = Color(0xFF000000);
const Color _surface = Color(0xFF101722);
const Color _accent = Color(0xFF4099FF);
const Color _textPrimary = Color(0xFFF7F9FF);
const Color _textSecondary = Color(0xFFA5B2C5);

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends OptimizedState<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final CurvedAnimation _heroCurve;
  late final CurvedAnimation _copyCurve;
  late final Animation<double> _heroOpacity;
  late final Animation<double> _copyOpacity;
  late final Animation<Offset> _heroOffset;
  late final Animation<Offset> _copyOffset;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _heroCurve = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.70, curve: Curves.easeOutCubic),
    );
    _copyCurve = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.20, 1.0, curve: Curves.easeOutCubic),
    );
    _heroOpacity = _heroCurve;
    _copyOpacity = _copyCurve;
    _heroOffset = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(_heroCurve);
    _copyOffset = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(_copyCurve);
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 450),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
        _entranceController.value = 1.0;
      } else {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _heroCurve.dispose();
    _copyCurve.dispose();
    _entranceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _playConfetti() {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return;
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final existingTheme = Theme.of(context);
    final premiumScheme = existingTheme.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: _accent,
      onPrimary: Colors.white,
      secondary: const Color(0xFF8ABEFF),
      surface: _surface,
      onSurface: _textPrimary,
      background: _background,
      onBackground: _textPrimary,
      outline: _textSecondary,
    );

    return Theme(
      data: existingTheme.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: premiumScheme,
      ),
      child: ColoredBox(
        color: _background,
        child: SetupPageTemplate(
          // Keep this exact title so PageButtons knows this is the first page.
          title: 'Welcome to OpenBubbles',
          subtitle: 'Send and receive iMessages from your Android.',
          aboveTitle: FadeTransition(
            opacity: _heroOpacity,
            child: SlideTransition(
              position: _heroOffset,
              child: _WelcomePreview(
                onConfetti: _playConfetti,
                confettiController: _confettiController,
              ),
            ),
          ),
          customTitle: FadeTransition(
            opacity: _copyOpacity,
            child: SlideTransition(
              position: _copyOffset,
              child: const _PremiumTitle(),
            ),
          ),
          customSubtitle: FadeTransition(
            opacity: _copyOpacity,
            child: SlideTransition(
              position: _copyOffset,
              child: const _PremiumSubtitle(),
            ),
          ),
          // Reuse the original Next button and page-controller navigation.
          // Only the original notification-permission prompt is retained.
          onNextPressed: () async {
            if ((fs.androidInfo?.version.sdkInt ?? 0) >= 33) {
              await Permission.notification.request();
            }
            return true;
          },
        ),
      ),
    );
  }
}

class _WelcomePreview extends StatelessWidget {
  const _WelcomePreview({
    required this.onConfetti,
    required this.confettiController,
  });

  final VoidCallback onConfetti;
  final ConfettiController confettiController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172641), Color(0xFF0D1624), Color(0xFF0B0D14)],
        ),
        border: Border.all(color: const Color(0xFF2C4364), width: 1),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          children: [
            Positioned(
              right: -52,
              top: -74,
              child: Container(
                height: 188,
                width: 188,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _accent.withOpacity(0.22),
                      _accent.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 37,
                        height: 37,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF58AEFF), Color(0xFF2872E9)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'A better way to connect',
                          maxLines: 2,
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'PREVIEW',
                        style: TextStyle(
                          color: Color(0xFF89BDF7),
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _PreviewBubble(
                    fromMe: false,
                    message: 'Hey! What are you up to?',
                  ),
                  const SizedBox(height: 12),
                  _PreviewBubble(
                    fromMe: true,
                    message: 'Making messages better 💙',
                    onTap: onConfetti,
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Tap the blue bubble ✨',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.center,
                  child: ConfettiWidget(
                    confettiController: confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.07,
                    numberOfParticles: 12,
                    gravity: 0.20,
                    colors: const [
                      _accent,
                      Color(0xFF9ACFFF),
                      Color(0xFFD0EAFF),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBubble extends StatelessWidget {
  const _PreviewBubble({
    required this.fromMe,
    required this.message,
    this.onTap,
  });

  final bool fromMe;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: fromMe ? _accent : const Color(0xFF293241),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(19),
          topRight: const Radius.circular(19),
          bottomLeft: Radius.circular(fromMe ? 19 : 6),
          bottomRight: Radius.circular(fromMe ? 6 : 19),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    return Row(
      mainAxisAlignment:
          fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!fromMe) ...[
          Container(
            width: 31,
            height: 31,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF354763),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFFD7E4FA),
              size: 18,
            ),
          ),
          const SizedBox(width: 9),
        ],
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 265),
            child: onTap == null
                ? bubble
                : Semantics(
                    button: true,
                    label: 'Play a sample confetti effect',
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(19),
                      child: bubble,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PremiumTitle extends StatelessWidget {
  const _PremiumTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WELCOME TO OPENBUBBLES',
              style: TextStyle(
                color: _accent,
                fontSize: 11,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                children: const [
                  TextSpan(text: 'Messaging,\n'),
                  TextSpan(
                    text: 'reimagined.',
                    style: TextStyle(color: _accent),
                  ),
                ],
              ),
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 37,
                height: 1.11,
                letterSpacing: -1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumSubtitle extends StatelessWidget {
  const _PremiumSubtitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 15, 8, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bring the conversations that matter to your Android. '
            'A familiar experience with a fresh look.',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 16,
              height: 1.48,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FeatureTag(icon: Icons.dark_mode_rounded, label: 'AMOLED style'),
              _FeatureTag(icon: Icons.chat_outlined, label: 'Blue bubbles'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  const _FeatureTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111824),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFF27374F)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF86BCFC)),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD5E2F6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
