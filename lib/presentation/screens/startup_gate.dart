import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/profile_providers.dart';

/// Decides, once, whether to land on onboarding or the main app — kept as
/// a tiny separate screen so [RootShell] never has to think about it.
class StartupGate extends ConsumerWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);

    return profileAsync.when(
      data: (profile) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.go(profile.onboardingComplete ? '/home' : '/onboarding');
        });
        return const _Splash();
      },
      loading: () => const _Splash(),
      error: (e, st) => const Scaffold(
        body: Center(child: Text('Something went wrong loading MeasureMe.')),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
