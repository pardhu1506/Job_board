import 'package:flutter/foundation.dart';

import '../models/job_application.dart';
import '../services/storage_service.dart';

/// Holds the applications the user has submitted and saves them on the
/// device. Read by the job card, detail screen and applications screen.
class ApplicationProvider extends ChangeNotifier {
  ApplicationProvider(this._storage);

  final StorageService _storage;

  List<JobApplication> _applications = [];

  List<JobApplication> get applications => List.unmodifiable(_applications);

  int get count => _applications.length;

  bool hasApplied(int jobId) => _applications.any((a) => a.jobId == jobId);

  Future<void> load() async {
    _applications = await _storage.loadApplications();
    notifyListeners();
  }

  Future<void> add(JobApplication application) async {
    _applications = [application, ..._applications];
    notifyListeners();
    await _storage.saveApplications(_applications);
  }

  Future<void> update(JobApplication application) async {
    _applications = [
      for (final saved in _applications)
        if (saved.id == application.id) application else saved,
    ];
    notifyListeners();
    await _storage.saveApplications(_applications);
  }

  Future<void> remove(String id) async {
    _applications = _applications.where((a) => a.id != id).toList();
    notifyListeners();
    await _storage.saveApplications(_applications);
  }
}
