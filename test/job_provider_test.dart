import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/providers/job_provider.dart';
import 'package:job_board/services/job_api_service.dart';
import 'package:job_board/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeJobApiService extends JobApiService {
  _FakeJobApiService(this._jobs);

  final List<Job> _jobs;

  @override
  Future<List<Job>> fetchJobs() async => _jobs;
}

Job _job(int id, {String salary = ''}) => Job(
  id: id,
  title: 'Role $id',
  company: 'Company $id',
  category: 'General',
  type: 'full_time',
  location: 'Anywhere',
  salary: salary,
  description: '',
  url: '',
  tags: const [],
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('salary filter keeps jobs with undisclosed salary', () async {
    final provider = JobProvider(
      _FakeJobApiService([
        _job(1, salary: '\$40k - \$50k'),
        _job(2, salary: '\$80k - \$100k'),
        _job(3),
      ]),
      const StorageService(),
    );
    await provider.load();

    provider.setSalaryRange(const RangeValues(70000, 110000));

    expect(provider.filteredJobs.map((job) => job.id), [2, 3]);
  });

  test('recent history is deduplicated, capped and persisted', () async {
    final provider = JobProvider(
      _FakeJobApiService([]),
      const StorageService(),
    );
    await provider.load();
    for (var id = 1; id <= 12; id++) {
      await provider.recordViewed(_job(id));
    }

    expect(provider.recentlyViewed, hasLength(10));
    expect(provider.recentlyViewed.first.id, 12);
    expect(provider.recentlyViewed.last.id, 3);

    await provider.recordViewed(_job(8));
    expect(provider.recentlyViewed.first.id, 8);
    expect(provider.recentlyViewed, hasLength(10));

    final restored = JobProvider(
      _FakeJobApiService([]),
      const StorageService(),
    );
    await restored.load();
    expect(restored.recentlyViewed.first.id, 8);
    expect(restored.recentlyViewed, hasLength(10));
  });
}
