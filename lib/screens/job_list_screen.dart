import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/application_provider.dart';
import '../providers/job_provider.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/filter_bar.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_view.dart';
import 'job_detail_screen.dart';
import 'my_applications_screen.dart';
import 'application_statistics_screen.dart';
import 'recently_viewed_screen.dart';
import 'settings_screen.dart';

/// Main screen: search, filters and the list of jobs.
/// Shows four states: loading, error with retry, empty, and data.
class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _navigating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Ignores repeated fast taps while a screen is already opening.
  Future<void> _open(Widget screen) async {
    if (_navigating) return;
    _navigating = true;
    try {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => screen));
    } finally {
      _navigating = false;
    }
  }

  void _clearFilters(JobProvider provider) {
    _searchController.clear();
    provider.clearFilters();
  }

  Future<void> _refresh(JobProvider provider) async {
    final success = await provider.refresh();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not refresh. Showing the jobs already loaded.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Board'),
        actions: [
          IconButton(
            tooltip: 'Recently viewed jobs',
            onPressed: () => _open(const RecentlyViewedScreen()),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Application statistics',
            onPressed: () => _open(const ApplicationStatisticsScreen()),
            icon: const Icon(Icons.bar_chart),
          ),
          Consumer<ApplicationProvider>(
            builder: (context, applications, _) {
              return IconButton(
                tooltip: 'My applications',
                onPressed: () => _open(const MyApplicationsScreen()),
                icon: Badge(
                  isLabelVisible: applications.count > 0,
                  label: Text('${applications.count}'),
                  child: const Icon(Icons.assignment_turned_in_outlined),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => _open(const SettingsScreen()),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(JobProvider provider) {
    switch (provider.status) {
      case LoadStatus.loading:
        return const LoadingView(message: 'Finding jobs for you…');
      case LoadStatus.error:
        return ErrorView(
          message: provider.errorMessage,
          onRetry: () => provider.load(force: true),
        );
      case LoadStatus.success:
        return _buildList(provider);
    }
  }

  Widget _buildList(JobProvider provider) {
    final jobs = provider.filteredJobs;
    final hasJobs = jobs.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () => _refresh(provider),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: hasJobs ? jobs.length + 2 : 2,
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeader(provider, jobs.length);

          if (!hasJobs) return _buildEmpty(provider);

          if (index == jobs.length + 1) return _buildCredit();

          final Job job = jobs[index - 1];
          return JobCard(job: job, onTap: () => _openJob(job));
        },
      ),
    );
  }

  Future<void> _openJob(Job job) async {
    try {
      await context.read<JobProvider>().recordViewed(job);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save recent job history.')),
        );
      }
    }
    await _open(JobDetailScreen(job: job));
  }

  Widget _buildHeader(JobProvider provider, int shown) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _searchController,
            inputFormatters: [LengthLimitingTextInputFormatter(60)],
            textInputAction: TextInputAction.search,
            onChanged: provider.setQuery,
            decoration: InputDecoration(
              hintText: 'Search by role or company',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.setQuery('');
                      },
                    ),
            ),
          ),
        ),
        const FilterBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            '$shown of ${provider.totalCount} jobs',
            style: theme.textTheme.labelLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(JobProvider provider) {
    if (provider.totalCount == 0) {
      return const EmptyView(
        icon: Icons.work_off_outlined,
        title: 'No jobs available right now',
        message: 'Pull down to refresh, or check back later.',
      );
    }
    return EmptyView(
      title: 'No jobs match your search',
      message: 'Try a different word, or remove some filters.',
      actionLabel: provider.hasActiveFilters ? 'Clear filters' : null,
      onAction: provider.hasActiveFilters
          ? () => _clearFilters(provider)
          : null,
    );
  }

  Widget _buildCredit() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        'Job data provided by Remotive (remotive.com)',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
