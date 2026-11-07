import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/job_provider.dart';
import '../widgets/empty_view.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';

class RecentlyViewedScreen extends StatelessWidget {
  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobProvider>().recentlyViewed;
    return Scaffold(
      appBar: AppBar(title: const Text('Recently viewed jobs')),
      body: jobs.isEmpty
          ? const EmptyView(
              icon: Icons.history,
              title: 'No recently viewed jobs',
              message: 'Jobs you open will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final Job job = jobs[index];
                return JobCard(
                  job: job,
                  onTap: () async {
                    try {
                      await context.read<JobProvider>().recordViewed(job);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not save recent job history.'),
                          ),
                        );
                      }
                    }
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => JobDetailScreen(job: job),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
