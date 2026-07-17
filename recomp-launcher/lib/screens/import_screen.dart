import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../theme/app_theme.dart';
import '../models/game.dart';
import '../services/game_service.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final List<_ImportJob> _jobs = [];
  bool _picking = false;

  Future<void> _pickFiles() async {
    setState(() => _picking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (_isValidFormat(file.extension ?? '')) {
            _addJob(file);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Unsupported format: ${file.extension?.toUpperCase() ?? 'unknown'}'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ));
            }
          }
        }
        _processQueue();
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  bool _isValidFormat(String ext) {
    return ['xex', 'iso', 'god', 'xbla', 'xcp'].contains(ext.toLowerCase());
  }

  void _addJob(PlatformFile file) {
    final job = _ImportJob(
      id: '${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      fileName: file.name,
      filePath: file.path ?? '',
      fileSizeBytes: file.size,
    );
    setState(() => _jobs.insert(0, job));
  }

  Future<void> _processQueue() async {
    for (final job in _jobs.where((j) => j.status == _Status.pending)) {
      await _importGame(job);
    }
  }

  Future<void> _importGame(_ImportJob job) async {
    setState(() => job.status = _Status.importing);
    await Future.delayed(const Duration(milliseconds: 600));

    final title = _titleFromPath(job.filePath);
    final game = Game(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      filePath: job.filePath,
      fileSizeBytes: job.fileSizeBytes,
      addedAt: DateTime.now(),
    );

    try {
      await GameService.instance.addGame(game);
      if (mounted) {
        HapticFeedback.lightImpact();
        setState(() => job.status = _Status.done);
      }
    } catch (_) {
      if (mounted) setState(() => job.status = _Status.error);
    }
  }

  String _titleFromPath(String path) {
    final name = p.basenameWithoutExtension(path);
    return name
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: Text('Import'.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildDropZone(),
                  const SizedBox(height: 24),
                  _buildFormats(),
                  if (_jobs.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildQueue(),
                  ],
                  const SizedBox(height: 28),
                  _buildTips(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone() {
    return GestureDetector(
      onTap: _picking ? null : _pickFiles,
      child: AnimatedContainer(
        duration: 200.ms,
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: _picking ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _picking ? AppColors.primary : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_picking) ...[
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text('Selecting files...',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.primary)),
            ] else ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Icon(Icons.upload_file_rounded,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 14),
              Text('Tap to browse files',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text('Select your legally-obtained game files',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.97, 0.97)),
    );
  }

  Widget _buildFormats() {
    final formats = [
      _FormatItem('XEX', 'Xbox Executable', AppColors.primary),
      _FormatItem('ISO', 'Disc Image', AppColors.accent),
      _FormatItem('GOD', 'Games on Demand', const Color(0xFF9B59B6)),
      _FormatItem('XBLA', 'Arcade Title', AppColors.warning),
      _FormatItem('XCP', 'Content Package', AppColors.error),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Supported Formats'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: formats
              .map((f) => _FormatChip(item: f))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQueue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Import Queue'),
        const SizedBox(height: 12),
        ..._jobs.map((j) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _JobTile(job: j),
            )),
      ],
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text('Tips',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.accent, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'Only import games you legally own.',
            'XEX files extracted from original discs work best.',
            'Adreno GPU (Qualcomm Snapdragon) required for playback.',
            'Large ISO files may take a moment to verify.',
          ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('  •  ',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700)),
                    Expanded(
                        child: Text(tip,
                            style: Theme.of(context).textTheme.bodyMedium)),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AppColors.textSecondary)),
      ],
    );
  }
}

class _FormatItem {
  final String ext;
  final String label;
  final Color color;
  const _FormatItem(this.ext, this.label, this.color);
}

class _FormatChip extends StatelessWidget {
  final _FormatItem item;
  const _FormatChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: item.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(item.ext,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: item.color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(width: 6),
          Text(item.label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ImportJob {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSizeBytes;
  _Status status;

  _ImportJob({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSizeBytes,
    this.status = _Status.pending,
  });
}

enum _Status { pending, importing, done, error }

class _JobTile extends StatelessWidget {
  final _ImportJob job;
  const _JobTile({required this.job});

  @override
  Widget build(BuildContext context) {
    Widget trailing;
    switch (job.status) {
      case _Status.pending:
        trailing = const Icon(Icons.schedule_rounded,
            color: AppColors.textTertiary, size: 20);
      case _Status.importing:
        trailing = const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        );
      case _Status.done:
        trailing = const Icon(Icons.check_circle_rounded,
            color: AppColors.primary, size: 20);
      case _Status.error:
        trailing = const Icon(Icons.error_outline_rounded,
            color: AppColors.error, size: 20);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              color: AppColors.textTertiary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.fileName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(_formatSize(job.fileSizeBytes),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
