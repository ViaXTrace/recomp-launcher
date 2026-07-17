import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/game.dart';
import '../services/game_service.dart';
import '../widgets/game_card.dart';
import 'game_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Game> _games = [];
  List<Game> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  _Filter _activeFilter = _Filter.all;
  bool _isGrid = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final games = await GameService.instance.getAllGames();
    if (mounted) {
      setState(() {
        _games = games;
        _loading = false;
        _filter();
      });
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      var list = _games.where((g) {
        switch (_activeFilter) {
          case _Filter.favorites:
            if (!g.isFavorite) return false;
          case _Filter.recent:
            if (g.lastPlayedAt == null) return false;
          case _Filter.all:
            break;
        }
        return q.isEmpty ||
            g.title.toLowerCase().contains(q) ||
            (g.genre?.toLowerCase().contains(q) ?? false);
      }).toList();

      if (_activeFilter == _Filter.recent) {
        list.sort((a, b) => (b.lastPlayedAt ?? DateTime(0))
            .compareTo(a.lastPlayedAt ?? DateTime(0)));
      }
      _filtered = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildFilters()),
          if (_loading)
            const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)))
          else if (_filtered.isEmpty)
            SliverFillRemaining(child: _EmptySearch(query: _searchCtrl.text))
          else if (_isGrid)
            _buildGrid()
          else
            _buildList(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      title: Text('Library'.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge),
      actions: [
        IconButton(
          icon: Icon(_isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppColors.textSecondary),
          onPressed: () => setState(() => _isGrid = !_isGrid),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search games...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textTertiary, size: 18),
                  onPressed: () => _searchCtrl.clear(),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: _Filter.values.map((f) {
          final selected = _activeFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _activeFilter = f);
                _filter();
              },
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.cardBorder,
                  ),
                ),
                child: Text(
                  f.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrid() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => GameCard(
            game: _filtered[i],
            onTap: () => _openDetail(_filtered[i]),
            onLongPress: () => _showOptions(_filtered[i]),
          ).animate(delay: (i * 30).ms).fadeIn().scale(begin: const Offset(0.92, 0.92)),
          childCount: _filtered.length,
        ),
      ),
    );
  }

  Widget _buildList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => _ListTile(
            game: _filtered[i],
            onTap: () => _openDetail(_filtered[i]),
            onLongPress: () => _showOptions(_filtered[i]),
          ).animate(delay: (i * 30).ms).fadeIn().slideX(begin: 0.1),
          childCount: _filtered.length,
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

  void _showOptions(Game game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _GameOptions(
        game: game,
        onDelete: () async {
          Navigator.pop(context);
          await GameService.instance.deleteGame(game.id);
          _load();
        },
        onFavorite: () async {
          Navigator.pop(context);
          await GameService.instance.toggleFavorite(game.id, !game.isFavorite);
          _load();
        },
      ),
    );
  }
}

enum _Filter {
  all('All Games'),
  recent('Recently Played'),
  favorites('Favorites');

  final String label;
  const _Filter(this.label);
}

class _ListTile extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ListTile(
      {required this.game, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 56,
                height: 56,
                color: AppColors.surface,
                child: game.coverImagePath != null
                    ? Image.asset(game.coverImagePath!, fit: BoxFit.cover)
                    : _PlaceholderCover(title: game.title, size: 56),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (game.genre != null) ...[
                        _Tag(label: game.genre!),
                        const SizedBox(width: 6),
                      ],
                      _Tag(label: game.fileExtension),
                      const SizedBox(width: 6),
                      _Tag(label: game.fileSizeFormatted),
                    ],
                  ),
                ],
              ),
            ),
            if (game.isFavorite)
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(label,
          style:
              Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, letterSpacing: 0.3)),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  final String title;
  final double size;
  const _PlaceholderCover({required this.title, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.card],
        ),
      ),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : '?',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'No games in this filter' : 'No results for "$query"',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _GameOptions extends StatelessWidget {
  final Game game;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;

  const _GameOptions(
      {required this.game, required this.onDelete, required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(game.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 20),
            _OptionTile(
              icon: game.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              label: game.isFavorite ? 'Remove from favorites' : 'Add to favorites',
              color: AppColors.warning,
              onTap: onFavorite,
            ),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Remove from library',
              color: AppColors.error,
              onTap: onDelete,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
