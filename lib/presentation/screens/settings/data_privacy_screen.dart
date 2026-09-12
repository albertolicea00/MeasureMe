import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/data_export_provider.dart';
import '../../providers/repository_providers.dart';

/// Privacy and data controls (§22): local-first by default, explicit
/// export/import, and an unambiguous full data-delete path.
class DataPrivacyScreen extends ConsumerStatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  ConsumerState<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends ConsumerState<DataPrivacyScreen> {
  bool _busy = false;

  Future<void> _exportJson() async {
    setState(() => _busy = true);
    try {
      final file = await ref.read(dataExportServiceProvider).exportJson();
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'MeasureMe data export'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _busy = true);
    try {
      final file = await ref.read(dataExportServiceProvider).exportMeasurementsCsv();
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'MeasureMe measurements (CSV)'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importJson() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = picked?.path;
    if (path == null) return;

    setState(() => _busy = true);
    try {
      await ref.read(dataExportServiceProvider).importJson(File(path));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import complete.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'This permanently deletes every measurement, clothing size, shoe size, reminder, and goal stored '
          'in MeasureMe on this device. This cannot be undone. Consider exporting a backup first.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete everything', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(profileRepositoryProvider).deleteAllData();
    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Data')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How your data is handled', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text(
                      'MeasureMe stores everything locally on this device by default. Nothing is sent to a '
                      'server. Apple Health and Health Connect sync is off unless you turn it on, and you can '
                      'disconnect either at any time from Health integrations. Measurement values are never '
                      'included in crash or analytics logs.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.ios_share),
                    title: const Text('Export as JSON'),
                    subtitle: const Text('Full backup of all your data'),
                    onTap: _busy ? null : _exportJson,
                  ),
                  ListTile(
                    leading: const Icon(Icons.table_chart_outlined),
                    title: const Text('Export measurements as CSV'),
                    onTap: _busy ? null : _exportCsv,
                  ),
                  ListTile(
                    leading: const Icon(Icons.file_upload_outlined),
                    title: const Text('Import from a JSON backup'),
                    onTap: _busy ? null : _importJson,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
                title: Text('Delete all data', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                subtitle: const Text('Permanently erase everything stored in MeasureMe'),
                onTap: _busy ? null : _deleteAllData,
              ),
            ),
            if (_busy) const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
