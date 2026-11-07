import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/application_provider.dart';
import 'info_chip.dart';

/// One row in the job list.
class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, required this.onTap});

  final Job job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final applied = context.select<ApplicationProvider, bool>(
      (provider) => provider.hasApplied(job.id),
    );
    final initial = String.fromCharCode(job.company.runes.first).toUpperCase();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(initial),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        InfoChip(
                          icon: Icons.work_outline,
                          label: job.typeLabel,
                        ),
                        InfoChip(
                          icon: Icons.place_outlined,
                          label: job.location,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.postedLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (applied)
                Tooltip(
                  message: 'Applied',
                  child: Icon(Icons.check_circle, color: scheme.primary),
                )
              else
                Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
