import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/job.dart';
import '../models/job_application.dart';

/// Saves data on the device so it survives an app restart.
class StorageService {
  const StorageService();

  static const String _applicationsKey = 'applications_v1';
  static const String _jobsKey = 'jobs_cache_v1';
  static const String _jobsTimeKey = 'jobs_cache_time_v1';
  static const String _recentJobsKey = 'recently_viewed_jobs_v1';

  Future<List<JobApplication>> loadApplications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_applicationsKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(JobApplication.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveApplications(List<JobApplication> applications) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(applications.map((a) => a.toJson()).toList());
    await prefs.setString(_applicationsKey, encoded);
  }

  Future<List<Job>> loadRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_recentJobsKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(Job.fromJson)
          .take(10)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecentlyViewed(List<Job> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _recentJobsKey,
      jsonEncode(jobs.take(10).map((job) => job.toJson()).toList()),
    );
  }

  /// Returns cached jobs only if they are newer than [maxAge].
  Future<List<Job>?> loadJobsCache({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAt = prefs.getInt(_jobsTimeKey);
      final raw = prefs.getString(_jobsKey);
      if (savedAt == null || raw == null) return null;

      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(savedAt),
      );
      if (age.isNegative || age > maxAge) return null;

      final list = jsonDecode(raw) as List<dynamic>;
      return list.whereType<Map<String, dynamic>>().map(Job.fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  /// Never throws: a failed cache write must not break the screen.
  Future<void> saveJobsCache(List<Job> jobs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _jobsKey,
        jsonEncode(jobs.map((j) => j.toJson()).toList()),
      );
      await prefs.setInt(_jobsTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      // Ignored on purpose.
    }
  }
}
