import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/game.dart';

class GameCard extends StatefulWidget {
  final Game game;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double? width;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.onLongPress,
    this.width,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onLongPress: widget.onLongPress != null
          ? () {
              HapticFeedback.mediumImpact();
              widget.onLongPress!();
            }
          : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: _CardBody(game: widget.game, width: widget.width),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  final Game game;
  final double? width;

  const _CardBody({required this.game, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _coverArt(),
                  _gradient(),
                  if (game.isFavorite) _favBadge(),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: _FormatBadge(ext: game.fileExtension),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            game.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (game.genre != null)
            Text(
              game.genre!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 10, color: AppColors.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _coverArt() {
    if (game.coverImagePath != null) {
      return Image.asset(game.coverImagePath!, fit: BoxFit.cover);
    }
    return _PlaceholderCover(title: game.title);
  }

  Widget _gradient() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.5),
          ],
          stops: const [0.6, 1.0],
        ),
      ),
    );
  }

  Widget _favBadge() {
    return Positioned(
      top: 6,
      right: 6,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.star_rounded,
            size: 13, color: AppColors.warning),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  final String title;
  const _PlaceholderCover({required this.title});

  static const _palettes = [
    [Color(0xFF0D1F37), Color(0xFF0A2E1A)],
    [Color(0xFF1F0D37), Color(0xFF2E0A1A)],
    [Color(0xFF0D370D), Color(0xFF0A2E2E)],
    [Color(0xFF370D0D), Color(0xFF2E1A0A)],
    [Color(0xFF0D2E2E), Color(0xFF0D0D37)],
  ];

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[title.length % _palettes.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -10,
            right: -10,
            child: Text(
              title.isNotEmpty ? title[0].toUpperCase() : '?',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.12),
                fontSize: 80,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videogame_asset_rounded,
                    size: 28, color: AppColors.textTertiary),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  final String ext;
  const _FormatBadge({required this.ext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 0.5),
      ),
      child: Text(
        ext,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
