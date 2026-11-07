import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/models/job_application.dart';

void main() {
  final appliedAt = DateTime.utc(2026, 11, 7);
  final application = JobApplication(
    id: 'app-1',
    jobId: 1,
    jobTitle: 'Flutter Developer',
    company: 'Acme',
    fullName: 'Ravi Kumar',
    email: 'ravi@example.com',
    phone: '9876543210',
    experience: '1 to 2 years',
    coverLetter: 'I would love to apply for this role.',
    appliedAt: appliedAt,
  );

  test('legacy saved applications default to Applied status', () {
    final json = application.toJson()..remove('status');

    expect(JobApplication.fromJson(json).status, ApplicationStatus.applied);
  });

  test('status and edited fields survive serialization', () {
    final updated = application.copyWith(
      fullName: 'Ravi K',
      status: ApplicationStatus.interview,
    );
    final restored = JobApplication.fromJson(updated.toJson());

    expect(restored.id, application.id);
    expect(restored.appliedAt, appliedAt);
    expect(restored.fullName, 'Ravi K');
    expect(restored.status, ApplicationStatus.interview);
  });
}
