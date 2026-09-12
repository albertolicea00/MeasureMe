import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/measurement_units.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../domain/entities/measurement_type.dart';
import '../../../domain/entities/measurement_entry.dart';
import '../../../domain/entities/user_profile.dart';
import '../../providers/repository_providers.dart';

/// Short onboarding flow (§21): a few intro screens, then the minimum
/// information needed to make the app useful. Nothing here is required
/// except a unit preference.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  UnitSystem _unitSystem = UnitSystem.metric;
  bool _saving = false;

  static const _introPages = [
    (icon: Icons.straighten_outlined, title: 'Know your measurements.'),
    (icon: Icons.show_chart, title: 'Track your body over time.'),
    (icon: Icons.checkroom_outlined, title: 'Keep your clothing and shoe sizes organized.'),
    (icon: Icons.notifications_active_outlined, title: 'Get reminded when it\'s time to measure again.'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final profileRepo = ref.read(profileRepositoryProvider);
    final measurementRepo = ref.read(measurementRepositoryProvider);
    final now = DateTime.now();

    await profileRepo.updateProfile(UserProfile(
      nickname: _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      unitSystem: _unitSystem,
      onboardingComplete: true,
      createdAt: now,
      updatedAt: now,
    ));

    final height = double.tryParse(_heightController.text.trim());
    if (height != null) {
      await measurementRepo.addEntry(
        typeId: MeasurementTypeCatalog.height.id,
        valueCanonical: UnitConverter.toCanonical(height, CanonicalUnit.centimeters, _unitSystem),
        timestamp: now,
        source: MeasurementSource.manual,
      );
    }
    final weight = double.tryParse(_weightController.text.trim());
    if (weight != null) {
      await measurementRepo.addEntry(
        typeId: MeasurementTypeCatalog.weight.id,
        valueCanonical: UnitConverter.toCanonical(weight, CanonicalUnit.kilograms, _unitSystem),
        timestamp: now,
        source: MeasurementSource.manual,
      );
    }

    if (!mounted) return;
    context.go('/home');
  }

  void _next() {
    if (_page < _introPages.length) {
      _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final intro in _introPages) _IntroPage(icon: intro.icon, title: intro.title),
                  _ProfileFormPage(
                    nicknameController: _nicknameController,
                    ageController: _ageController,
                    heightController: _heightController,
                    weightController: _weightController,
                    unitSystem: _unitSystem,
                    onUnitSystemChanged: (v) => setState(() => _unitSystem = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(
                        _introPages.length + 1,
                        (i) => Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i <= _page
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving
                      ? null
                      : (_page < _introPages.length ? _next : _finish),
                  child: _saving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_page < _introPages.length ? 'Continue' : 'Get started'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

class _ProfileFormPage extends StatelessWidget {
  const _ProfileFormPage({
    required this.nicknameController,
    required this.ageController,
    required this.heightController,
    required this.weightController,
    required this.unitSystem,
    required this.onUnitSystemChanged,
  });

  final TextEditingController nicknameController;
  final TextEditingController ageController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final UnitSystem unitSystem;
  final ValueChanged<UnitSystem> onUnitSystemChanged;

  @override
  Widget build(BuildContext context) {
    final lengthUnit = unitSystem == UnitSystem.metric ? 'cm' : 'in';
    final massUnit = unitSystem == UnitSystem.metric ? 'kg' : 'lb';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('A little about you', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Everything here is optional except your unit preference.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          SegmentedButton<UnitSystem>(
            segments: const [
              ButtonSegment(value: UnitSystem.metric, label: Text('Metric')),
              ButtonSegment(value: UnitSystem.imperial, label: Text('Imperial')),
            ],
            selected: {unitSystem},
            onSelectionChanged: (s) => onUnitSystemChanged(s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nicknameController,
            decoration: const InputDecoration(labelText: 'Nickname (optional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Age (optional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: heightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Height (optional)', suffixText: lengthUnit),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Weight (optional)', suffixText: massUnit),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
