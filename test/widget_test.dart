import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/main.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/models/job_application.dart';
import 'package:job_board/models/user_profile.dart';
import 'package:job_board/services/auth_service.dart';
import 'package:job_board/services/job_api_exception.dart';
import 'package:job_board/services/job_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeJobApiService extends JobApiService {
  _FakeJobApiService(this._result);

  final Future<List<Job>> Function() _result;

  @override
  Future<List<Job>> fetchJobs() => _result();
}

class _FakeAuthService extends AuthService {
  _FakeAuthService();

  static const _profile = UserProfile(
    name: 'Test User',
    email: 'test@example.com',
  );

  @override
  Future<UserProfile?> savedProfile() async => _profile;

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    if (email.toLowerCase() != _profile.email || password != 'test-pass') {
      throw const AuthException('Email or password is incorrect.');
    }
    return _profile;
  }
}

Future<void> _pumpJobBoard(
  WidgetTester tester, {
  required JobApiService jobService,
}) async {
  await tester.pumpWidget(
    JobBoardApp(jobService: jobService, authService: _FakeAuthService()),
  );
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).last, 'test-pass');
  await tester.tap(find.text('Log in'));
  await tester.pumpAndSettle();
}

Job _sampleJob() => Job(
  id: 1,
  title: 'Flutter Developer',
  company: 'Acme Tech',
  category: 'Software Development',
  type: 'full_time',
  location: 'Worldwide',
  salary: '',
  description: 'Build mobile apps.',
  url: 'https://remotive.com/remote-jobs/software-dev/1',
  tags: const ['flutter', 'dart'],
  publishedAt: DateTime.now(),
);

JobApplication _sampleApplication() => JobApplication(
  id: 'application-1',
  jobId: 1,
  jobTitle: 'Flutter Developer',
  company: 'Acme Tech',
  fullName: 'Ravi Kumar',
  email: 'ravi@example.com',
  phone: '9876543210',
  experience: '1 to 2 years',
  coverLetter: 'I would love to apply for this Flutter Developer role.',
  appliedAt: DateTime.utc(2026, 11, 7),
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the job list after loading', (tester) async {
    await _pumpJobBoard(
      tester,
      jobService: _FakeJobApiService(() async => [_sampleJob()]),
    );

    expect(find.text('Flutter Developer'), findsOneWidget);
    expect(find.text('Acme Tech'), findsOneWidget);
  });

  testWidgets('settings changes and saves the app appearance', (tester) async {
    await _pumpJobBoard(
      tester,
      jobService: _FakeJobApiService(() async => [_sampleJob()]),
    );

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('System default'), findsOneWidget);
    expect(find.text('Light mode'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.text('Settings'))).brightness,
      Brightness.dark,
    );
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme_mode_v1'), 'dark');
  });

  testWidgets('shows an error message with a retry button', (tester) async {
    await tester.pumpWidget(
      JobBoardApp(
        jobService: _FakeJobApiService(
          () async => throw const JobApiException('No internet connection.'),
        ),
        authService: _FakeAuthService(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'test-pass');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('No internet connection.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows an empty message when there are no jobs', (tester) async {
    await _pumpJobBoard(
      tester,
      jobService: _FakeJobApiService(() async => <Job>[]),
    );

    expect(find.text('No jobs available right now'), findsOneWidget);
  });

  testWidgets('opens recently viewed and application statistics', (
    tester,
  ) async {
    await _pumpJobBoard(
      tester,
      jobService: _FakeJobApiService(() async => [_sampleJob()]),
    );

    expect(find.text('Salary range'), findsOneWidget);
    expect(
      find.textContaining('Undisclosed salaries are always included'),
      findsOneWidget,
    );
    await tester.tap(find.text('Flutter Developer').first);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Recently viewed jobs'));
    await tester.pumpAndSettle();
    expect(find.text('Recently viewed jobs'), findsOneWidget);
    expect(find.text('Flutter Developer'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Application statistics'));
    await tester.pumpAndSettle();
    expect(find.text('Application statistics'), findsOneWidget);
    expect(find.text('Applied'), findsOneWidget);
    expect(find.text('Interview'), findsOneWidget);
    expect(find.text('Offer'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
  });

  testWidgets('updates status and edits a saved application', (tester) async {
    SharedPreferences.setMockInitialValues({
      'applications_v1': jsonEncode([_sampleApplication().toJson()]),
    });
    await _pumpJobBoard(
      tester,
      jobService: _FakeJobApiService(() async => [_sampleJob()]),
    );

    await tester.tap(find.byTooltip('My applications'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Applied'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Interview').last);
    await tester.pumpAndSettle();
    expect(find.text('Interview'), findsOneWidget);

    await tester.tap(find.text('Flutter Developer').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit application'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'Ravi Kumar',
    );

    await tester.enterText(find.byType(TextFormField).first, 'Ravi Updated');
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Name: Ravi Updated'), findsOneWidget);
    expect(find.text('Interview'), findsOneWidget);
  });
}
