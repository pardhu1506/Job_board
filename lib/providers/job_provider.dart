import 'package:flutter/material.dart';

import '../models/job.dart';
import '../services/job_api_exception.dart';
import '../services/job_api_service.dart';
import '../services/salary_parser.dart';
import '../services/storage_service.dart';

enum LoadStatus { loading, error, success }

/// Holds the list of jobs, the loading state and the active filters.
/// Read by the list screen and the filter bar.
class JobProvider extends ChangeNotifier {
  JobProvider(this._service, this._storage);

  final JobApiService _service;
  final StorageService _storage;

  List<Job> _jobs = [];
  LoadStatus _status = LoadStatus.loading;
  String _errorMessage = '';
  String _query = '';
  String? _selectedType;
  String? _selectedLocation;
  RangeValues? _salaryRange;
  List<Job> _recentlyViewed = [];

  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;
  int get totalCount => _jobs.length;
  String? get selectedType => _selectedType;
  String? get selectedLocation => _selectedLocation;
  RangeValues? get salaryRange => _salaryRange;
  List<Job> get recentlyViewed => List.unmodifiable(_recentlyViewed);
  double get salarySliderMax {
    var maximum = 0.0;
    for (final job in _jobs) {
      final salary = SalaryParser.parse(job.salary);
      if (salary != null && salary.maximum > maximum) {
        maximum = salary.maximum;
      }
    }
    if (maximum <= 0) return 10000;
    return (maximum / 10000).ceil() * 10000;
  }

  bool get hasActiveFilters =>
      _query.trim().isNotEmpty ||
      _selectedType != null ||
      _selectedLocation != null ||
      _salaryRange != null;

  List<Job> get filteredJobs {
    final query = _query.trim().toLowerCase();
    return _jobs.where((job) {
      if (_selectedType != null && job.type != _selectedType) return false;
      if (_selectedLocation != null && job.location != _selectedLocation) {
        return false;
      }
      final salaryRange = _salaryRange;
      final jobSalary = SalaryParser.parse(job.salary);
      if (salaryRange != null &&
          jobSalary != null &&
          (jobSalary.maximum < salaryRange.start ||
              jobSalary.minimum > salaryRange.end)) {
        return false;
      }
      if (query.isNotEmpty &&
          !job.title.toLowerCase().contains(query) &&
          !job.company.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<String> get availableTypes {
    final types = _jobs.map((job) => job.type).toSet().toList()..sort();
    return types;
  }

  /// The most common locations, so the dropdown stays short.
  List<String> get availableLocations {
    final counts = <String, int>{};
    for (final job in _jobs) {
      counts[job.location] = (counts[job.location] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    final locations = entries.take(15).map((e) => e.key).toList();
    final selected = _selectedLocation;
    if (selected != null && !locations.contains(selected)) {
      locations.add(selected);
    }
    return locations;
  }

  /// Loads jobs. Uses jobs saved in the last hour unless [force] is true.
  Future<void> load({bool force = false}) async {
    _status = LoadStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _recentlyViewed = await _storage.loadRecentlyViewed();
      if (!force) {
        final cached = await _storage.loadJobsCache();
        if (cached != null && cached.isNotEmpty) {
          _jobs = cached;
          _status = LoadStatus.success;
          notifyListeners();
          return;
        }
      }

      final jobs = await _service.fetchJobs();
      _jobs = jobs;
      _status = LoadStatus.success;
      await _storage.saveJobsCache(jobs);
    } on JobApiException catch (error) {
      _status = LoadStatus.error;
      _errorMessage = error.message;
    } catch (_) {
      _status = LoadStatus.error;
      _errorMessage = 'Something went wrong. Please try again.';
    }
    notifyListeners();
  }

  /// Pull-to-refresh. Keeps the current list if the request fails.
  /// Returns true when new data was loaded.
  Future<bool> refresh() async {
    try {
      final jobs = await _service.fetchJobs();
      _jobs = jobs;
      _status = LoadStatus.success;
      notifyListeners();
      await _storage.saveJobsCache(jobs);
      return true;
    } catch (_) {
      return false;
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setType(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setLocation(String? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setSalaryRange(RangeValues? range) {
    _salaryRange = range;
    notifyListeners();
  }

  Future<void> recordViewed(Job job) async {
    _recentlyViewed = [
      job,
      ..._recentlyViewed.where((saved) => saved.id != job.id),
    ].take(10).toList();
    notifyListeners();
    await _storage.saveRecentlyViewed(_recentlyViewed);
  }

  void clearFilters() {
    _query = '';
    _selectedType = null;
    _selectedLocation = null;
    _salaryRange = null;
    notifyListeners();
  }
}
