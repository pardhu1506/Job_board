import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/application_provider.dart';
import '../widgets/info_chip.dart';
import 'application_form_screen.dart';

/// Shows everything about one job and lets the user start an application.
class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.job});

  final Job job;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _navigating = false;

  Future<void> _apply() async {
    if (_navigating) return;
    _navigating = true;
    try {
      final submitted = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => ApplicationFormScreen(job: widget.job),
        ),
      );
      if (submitted == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application saved on this device')),
        );
      }
    } finally {
      _navigating = false;
    }
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.job.url));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Job link copied')));
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                SelectableText(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final theme = Theme.of(context);
    final applied = context.select<ApplicationProvider, bool>(
      (provider) => provider.hasApplied(job.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job details'),
        actions: [
          if (job.url.isNotEmpty)
            IconButton(
              tooltip: 'Copy job link',
              icon: const Icon(Icons.link),
              onPressed: _copyLink,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.company,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(icon: Icons.work_outline, label: job.typeLabel),
                  InfoChip(icon: Icons.place_outlined, label: job.location),
                  InfoChip(icon: Icons.category_outlined, label: job.category),
                ],
              ),
              const SizedBox(height: 20),
              _infoRow(
                Icons.payments_outlined,
                'Salary',
                job.salary.isEmpty ? 'Not specified' : job.salary,
              ),
              _infoRow(Icons.event_outlined, 'Posted', job.postedDate),
              if (job.url.isNotEmpty)
                _infoRow(
                  Icons.open_in_new,
                  'Original posting on Remotive',
                  job.url,
                ),
              if (job.tags.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Skills and tags', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final tag in job.tags.take(12))
                      Chip(
                        label: Text(tag, overflow: TextOverflow.ellipsis),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
              const Divider(height: 32),
              Text('About this role', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SelectableText(
                job.description.isEmpty
                    ? 'No description was provided for this job.'
                    : job.description,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: applied ? null : _apply,
            icon: Icon(applied ? Icons.check : Icons.send_outlined),
            label: Text(applied ? 'Already applied' : 'Apply now'),
          ),
        ),
      ),
    );
  }
}
