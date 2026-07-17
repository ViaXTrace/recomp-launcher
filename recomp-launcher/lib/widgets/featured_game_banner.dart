import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/game.dart';

class FeaturedGameBanner extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const FeaturedGameBanner({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _background(),
              _overlayGradient(),
              _content(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _background() {
    if (game.coverImagePath != null) {
      return Image.asset(game.coverImagePath!, fit: BoxFit.cover);
    }
    return _GeneratedBg(title: game.title);
  }

  Widget _overlayGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.transparent,
            AppColors.background.withOpacity(0.5),
            AppColors.background.withOpacity(0.9),
          ],
          stops: const [0.2, 0.55, 1.0],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label: 'Featured'),
          const SizedBox(height: 6),
          Text(
            game.title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              shadows: [const Shadow(color: Colors.black87, blurRadius: 16)],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (game.genre != null) ...[
                _Tag(label: game.genre!, color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              _Tag(label: game.fileExtension, color: AppColors.accent),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 12)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('Play',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        )),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.04, 1.04),
                  duration: 1200.ms,
                  curve: Curves.easeInOut,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;
  const _Label({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _GeneratedBg extends StatelessWidget {
  final String title;
  const _GeneratedBg({required this.title});

  @override
  Widget build(BuildContext context) {
    final hue = (title.codeUnits.fold(0, (a, b) => a + b) % 360).toDouble();
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.6, -0.4),
          radius: 1.4,
          colors: [
            HSLColor.fromAHSL(1, hue, 0.6, 0.2).toColor(),
            AppColors.background,
          ],
        ),
      ),
      child: Align(
        alignment: const Alignment(0.8, 0.0),
        child: Text(
          title.isNotEmpty ? title[0] : '?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.04),
            fontSize: 200,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
