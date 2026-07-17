import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/game.dart';
import '../services/game_service.dart';
import '../widgets/game_card.dart';
import '../widgets/featured_game_banner.dart';
import 'game_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Game> _allGames = [];
  List<Game> _recentGames = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await GameService.instance.getAllGames();
    final recent = await GameService.instance.getRecentlyPlayed(limit: 6);
    if (mounted) {
      setState(() {
        _allGames = all;
        _recentGames = recent;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        backgroundColor: AppColors.card,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            if (_loading)
              const SliverFillRemaining(child: Center(child: _LoadingSpinner()))
            else if (_allGames.isEmpty)
              SliverFillRemaining(child: _EmptyState(onImport: () {}))
            else ...[
              if (_allGames.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: FeaturedGameBanner(
                    game: _allGames.first,
                    onTap: () => _openDetail(_allGames.first),
                  ).animate().fadeIn(duration: 400.ms),
                ),
              ],
              if (_recentGames.isNotEmpty) ...[
                _sectionHeader('Recently Played'),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _recentGames.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (ctx, i) => GameCard(
                        game: _recentGames[i],
                        width: 110,
                        onTap: () => _openDetail(_recentGames[i]),
                      ).animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.2),
                    ),
                  ),
                ),
              ],
              _sectionHeader('Your Library'),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => GameCard(
                      game: _allGames[i],
                      onTap: () => _openDetail(_allGames[i]),
                    ).animate(delay: (i * 40).ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
                    childCount: _allGames.length.clamp(0, 9),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      expandedHeight: 70,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 8, spreadRadius: 2)],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'RECOMP',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 3),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            '${_allGames.length} GAMES',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(width: 3, height: 16, color: AppColors.primary,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Text(title.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppColors.textSecondary,
                )),
          ],
        ),
      ),
    );
  }

  void _openDetail(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameDetailScreen(game: game)),
    ).then((_) => _load());
  }
}

class _LoadingSpinner extends StatelessWidget {
  const _LoadingSpinner();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text('Loading library...', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onImport;
  const _EmptyState({required this.onImport});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: const Icon(Icons.videogame_asset_off_outlined,
                  size: 36, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            Text('No games yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Import your legally-obtained Xbox 360 game files to get started.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Import Game'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
      ),
    );
  }
}
