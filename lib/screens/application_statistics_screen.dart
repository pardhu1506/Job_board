import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/job_application.dart';
import '../providers/application_provider.dart';

class ApplicationStatisticsScreen extends StatelessWidget {
  const ApplicationStatisticsScreen({super.key});

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
      appBar: AppBar(title: const Text('Application statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Total applications'),
              trailing: Text(
                '${applications.length}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final status in ApplicationStatus.values)
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.circle,
                  color: _statusColor(context, status),
                  size: 16,
                ),
                title: Text(status.label),
                trailing: Text(
                  '${applications.where((a) => a.status == status).length}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
