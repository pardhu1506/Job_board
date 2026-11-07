import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/job_application.dart';
import '../providers/application_provider.dart';
import '../services/date_formatter.dart';
import '../widgets/empty_view.dart';
import 'application_form_screen.dart';

/// Lists the applications the user has submitted (saved on the device).
class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    JobApplication application,
  ) async {
    final store = context.read<ApplicationProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete application?'),
        content: Text(
          'Your application for ${application.jobTitle} will be removed '
          'from this phone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await store.remove(application.id);
    }
  }

  Future<void> _editApplication(
    BuildContext context,
    JobApplication application,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ApplicationFormScreen(application: application),
      ),
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    JobApplication application,
    ApplicationStatus status,
  ) async {
    try {
      await context.read<ApplicationProvider>().update(
        application.copyWith(status: status),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the application status.'),
          ),
        );
      }
    }
  }

  Color _statusColor(BuildContext context, ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return Theme.of(context).colorScheme.primary;
      case ApplicationStatus.interview:
        return Theme.of(context).colorScheme.secondary;
      case ApplicationStatus.offer:
        return Theme.of(context).colorScheme.tertiary;
      case ApplicationStatus.rejected:
        return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final applications = context.watch<ApplicationProvider>().applications;

    return Scaffold(
      appBar: AppBar(title: const Text('My applications')),
      body: SafeArea(
        child: applications.isEmpty
            ? LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: const EmptyView(
                      icon: Icons.assignment_outlined,
                      title: 'No applications yet',
                      message: 'Jobs you apply for will appear here.',
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final application = applications[index];
                  return _buildItem(context, application);
                },
              ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, JobApplication application) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          application.jobTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${application.company} • ${formatDate(application.appliedAt)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            PopupMenuButton<ApplicationStatus>(
              tooltip: 'Change application status',
              onSelected: (status) =>
                  _changeStatus(context, application, status),
              itemBuilder: (context) => [
                for (final status in ApplicationStatus.values)
                  PopupMenuItem(value: status, child: Text(status.label)),
              ],
              child: Chip(
                label: Text(application.status.label),
                visualDensity: VisualDensity.compact,
                backgroundColor: _statusColor(
                  context,
                  application.status,
                ).withValues(alpha: 0.14),
                side: BorderSide.none,
                labelStyle: TextStyle(
                  color: _statusColor(context, application.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${application.fullName}'),
          const SizedBox(height: 4),
          Text('Email: ${application.email}'),
          const SizedBox(height: 4),
          Text('Mobile: ${application.phone}'),
          const SizedBox(height: 4),
          Text('Experience: ${application.experience}'),
          const SizedBox(height: 12),
          Text('Cover letter', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(application.coverLetter),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editApplication(context, application),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () => _confirmDelete(context, application),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
