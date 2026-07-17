import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/game.dart';
import '../services/game_service.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  late Game _game;
  bool _launching = false;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
  }

  Future<void> _toggleFavorite() async {
    HapticFeedback.lightImpact();
    await GameService.instance.toggleFavorite(_game.id, !_game.isFavorite);
    setState(() => _game = _game.copyWith(isFavorite: !_game.isFavorite));
  }

  Future<void> _launch() async {
    HapticFeedback.mediumImpact();
    setState(() => _launching = true);
    await GameService.instance.recordPlay(_game.id);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _launching = false);
      _showLaunchDialog();
    }
  }

  void _showLaunchDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder)),
        title: Text('Engine Not Integrated',
            style: Theme.of(context).textTheme.titleMedium),
        content: Text(
          'The static recompilation engine is not yet bundled with this build.\n\n'
          'Follow the RECOMP GitHub for updates on the engine integration.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: Icon(
                _game.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 20,
                color: _game.isFavorite ? AppColors.warning : Colors.white,
              ),
            ),
            onPressed: _toggleFavorite,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _game.coverImagePath != null
              ? Image.asset(_game.coverImagePath!, fit: BoxFit.cover)
              : _GradientCover(title: _game.title),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withOpacity(0.7),
                  AppColors.background,
                ],
                stops: const [0.4, 0.75, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_game.genre != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Text(
                      _game.genre!.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                    ),
                  ),
                Text(
                  _game.title,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(shadows: [
                    const Shadow(color: Colors.black, blurRadius: 12)
                  ]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLaunchButton(),
          const SizedBox(height: 28),
          _buildInfoGrid(),
          if (_game.description != null) ...[
            const SizedBox(height: 28),
            _SectionTitle(title: 'Overview'),
            const SizedBox(height: 10),
            Text(_game.description!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.6)),
          ],
          const SizedBox(height: 28),
          _SectionTitle(title: 'File Info'),
          const SizedBox(height: 10),
          _buildFileInfo(),
          const SizedBox(height: 28),
          _buildAdrenoWarning(),
        ].animate(interval: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05),
      ),
    );
  }

  Widget _buildLaunchButton() {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: 200.ms,
        child: FilledButton.icon(
          onPressed: _launching ? null : _launch,
          icon: _launching
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.play_arrow_rounded, size: 26),
          label: Text(_launching ? 'Launching...' : 'Play'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    final items = [
      if (_game.releaseYear != null)
        _InfoItem(label: 'Year', value: '${_game.releaseYear}'),
      if (_game.publisher != null)
        _InfoItem(label: 'Publisher', value: _game.publisher!),
      if (_game.rating != null)
        _InfoItem(label: 'Rating', value: _game.rating!),
      _InfoItem(label: 'Format', value: _game.fileExtension),
      _InfoItem(label: 'Size', value: _game.fileSizeFormatted),
      _InfoItem(label: 'Plays', value: '${_game.playCount}'),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Wrap(
        spacing: 0,
        runSpacing: 16,
        children: items.map((item) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 72) / 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 1,
                          color: AppColors.textTertiary,
                        )),
                const SizedBox(height: 4),
                Text(item.value,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFileInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_game.filePath.split('/').last,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace', color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                    'Added ${_formatDate(_game.addedAt)}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdrenoWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.memory_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Adreno GPU Required',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warning, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                    'This engine currently supports Qualcomm Adreno GPUs only. Mali and other GPU families are not supported.',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _GradientCover extends StatelessWidget {
  final String title;
  const _GradientCover({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = [
      [const Color(0xFF0D2137), const Color(0xFF07070F)],
      [const Color(0xFF1A0D2E), const Color(0xFF07070F)],
      [const Color(0xFF0D2920), const Color(0xFF07070F)],
      [const Color(0xFF2E1A0D), const Color(0xFF07070F)],
    ];
    final palette = colors[title.length % colors.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: palette,
        ),
      ),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : '?',
          style: TextStyle(
            color: AppColors.primary.withOpacity(0.3),
            fontSize: 120,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
