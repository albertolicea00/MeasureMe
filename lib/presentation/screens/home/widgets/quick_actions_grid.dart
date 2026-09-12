import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key, required this.onViewProgress});

  final VoidCallback onViewProgress;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.add_circle_outline,
        label: 'Add measurement',
        onTap: () => context.push('/session'),
      ),
      _QuickAction(
        icon: Icons.show_chart,
        label: 'View progress',
        onTap: onViewProgress,
      ),
      _QuickAction(
        icon: Icons.checkroom_outlined,
        label: 'Clothing & suits',
        onTap: () => context.push('/clothing'),
      ),
      _QuickAction(
        icon: Icons.snowshoeing_outlined,
        label: 'Shoe sizes',
        onTap: () => context.push('/shoes'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: actions,
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
