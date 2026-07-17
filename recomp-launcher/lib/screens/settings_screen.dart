import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vsync = true;
  bool _highPerformance = false;
  bool _skipIntros = true;
  String _resolution = '1x';
  String _frameTarget = '60';
  bool _hdr = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vsync = prefs.getBool('vsync') ?? true;
      _highPerformance = prefs.getBool('highPerformance') ?? false;
      _skipIntros = prefs.getBool('skipIntros') ?? true;
      _resolution = prefs.getString('resolution') ?? '1x';
      _frameTarget = prefs.getString('frameTarget') ?? '60';
      _hdr = prefs.getBool('hdr') ?? false;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vsync', _vsync);
    await prefs.setBool('highPerformance', _highPerformance);
    await prefs.setBool('skipIntros', _skipIntros);
    await prefs.setString('resolution', _resolution);
    await prefs.setString('frameTarget', _frameTarget);
    await prefs.setBool('hdr', _hdr);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Settings saved'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
    }
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
            title: Text('Settings'.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge),
            actions: [
              if (_loaded)
                TextButton(
                  onPressed: _save,
                  child: Text('Save',
                      style: TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              const SizedBox(width: 8),
            ],
          ),
          if (!_loaded)
            const SliverFillRemaining(
                child:
                    Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _Section(
                    title: 'Graphics',
                    children: [
                      _SegmentedRow(
                        label: 'Resolution Scale',
                        sublabel: 'Internal render resolution multiplier',
                        options: const ['0.5x', '1x', '1.5x', '2x'],
                        value: _resolution,
                        onChanged: (v) => setState(() => _resolution = v),
                      ),
                      _Divider(),
                      _SegmentedRow(
                        label: 'Frame Target',
                        sublabel: 'Target frames per second',
                        options: const ['30', '60'],
                        value: _frameTarget,
                        onChanged: (v) => setState(() => _frameTarget = v),
                      ),
                      _Divider(),
                      _ToggleRow(
                        label: 'VSync',
                        sublabel: 'Prevents screen tearing',
                        value: _vsync,
                        onChanged: (v) => setState(() => _vsync = v),
                      ),
                      _Divider(),
                      _ToggleRow(
                        label: 'HDR Output',
                        sublabel: 'Requires HDR-capable display',
                        value: _hdr,
                        onChanged: (v) => setState(() => _hdr = v),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'Engine',
                    children: [
                      _ToggleRow(
                        label: 'High Performance Mode',
                        sublabel: 'Disables power-saving; increases heat',
                        value: _highPerformance,
                        onChanged: (v) => setState(() => _highPerformance = v),
                        iconColor: AppColors.warning,
                      ),
                      _Divider(),
                      _ToggleRow(
                        label: 'Skip Intros',
                        sublabel: 'Skip publisher logos at startup',
                        value: _skipIntros,
                        onChanged: (v) => setState(() => _skipIntros = v),
                      ),
                    ],
                  ).animate().fadeIn(delay: 160.ms),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'GPU',
                    children: [
                      _InfoRow(
                        label: 'Backend',
                        value: 'Vulkan',
                        icon: Icons.memory_rounded,
                      ),
                      _Divider(),
                      _InfoRow(
                        label: 'Supported Families',
                        value: 'Adreno (Qualcomm)',
                        icon: Icons.developer_board_rounded,
                      ),
                      _Divider(),
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.warning.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.warning, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Mali, PowerVR, and Xclipse GPUs are not supported in this build.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 220.ms),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'About',
                    children: [
                      _AboutRow(label: 'App Version', value: '1.0.0'),
                      _Divider(),
                      _AboutRow(label: 'Engine', value: 'UnleashedRecomp-Android'),
                      _Divider(),
                      _AboutRow(label: 'Base Project', value: 'hedge-dev/UnleashedRecomp'),
                      _Divider(),
                      _AboutRow(label: 'Built With', value: 'Anthropic Fable 5 AI'),
                      _Divider(),
                      _LinkRow(
                        label: 'GitHub',
                        icon: Icons.open_in_new_rounded,
                        onTap: () {},
                      ),
                      _Divider(),
                      _LinkRow(
                        label: 'Report Issue',
                        icon: Icons.bug_report_outlined,
                        onTap: () {},
                      ),
                    ],
                  ).animate().fadeIn(delay: 280.ms),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'RECOMP • Xbox 360 Static Recompilation\nFor Android • Adreno GPU Required',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary, height: 1.7),
                    ),
                  ).animate().fadeIn(delay: 340.ms),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                    color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Text(title.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16);
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;

  const _ToggleRow({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(sublabel, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeColor: iconColor ?? AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SegmentedRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const _SegmentedRow({
    required this.label,
    required this.sublabel,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 2),
          Text(sublabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          Row(
            children: options.map((opt) {
              final selected = opt == value;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(opt);
                  },
                  child: AnimatedContainer(
                    duration: 150.ms,
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      opt,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: selected ? Colors.white : AppColors.textSecondary,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _LinkRow({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.accent)),
            const Spacer(),
            Icon(icon, size: 16, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
