import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/main.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/models/job_application.dart';
import 'package:job_board/models/user_profile.dart';
import 'package:job_board/services/auth_service.dart';
import 'package:job_board/services/form_validators.dart';
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

  testWidgets('limits long searches and shows the no-match state', (
    tester,
  ) async {
    await _pumpJobBoard(
      tester,
      jobService: _FakeJobApiService(() async => [_sampleJob()]),
    );

    final search = find.byType(TextField).first;
    await tester.enterText(search, 'x' * 100);
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(search).controller!.text.length, 60);
    expect(find.text('No jobs match your search'), findsOneWidget);
  });

  testWidgets('repeated fast taps open only one job details screen', (
    tester,
  ) async {
    await _pumpJobBoard(
      tester,
      jobService: _FakeJobApiService(() async => [_sampleJob()]),
    );

    final job = find.text('Flutter Developer').first;
    await tester.tap(job);
    for (var tap = 0; tap < 5; tap++) {
      await tester.tap(job, warnIfMissed: false);
    }
    await tester.pumpAndSettle();

    expect(find.text('Job details'), findsOneWidget);
  });

  testWidgets('rejects an empty application with a message for each field', (
    tester,
  ) async {
    await _pumpJobBoard(
      tester,
      jobService: _FakeJobApiService(() async => [_sampleJob()]),
    );

    await tester.ensureVisible(find.text('Flutter Developer').first);
    await tester.tap(find.text('Flutter Developer').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply now'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Submit application'));
    await tester.tap(find.text('Submit application'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name'), findsOneWidget);
    expect(find.text('Please enter your email address'), findsOneWidget);
    expect(find.text('Please enter your mobile number'), findsOneWidget);
    expect(find.text('Please select your experience level'), findsOneWidget);
    expect(find.text('Please write a short cover letter'), findsOneWidget);
  });

  testWidgets(
    'limits long application entries and remains usable in landscape',
    (tester) async {
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpJobBoard(
        tester,
        jobService: _FakeJobApiService(() async => [_sampleJob()]),
      );

      await tester.ensureVisible(find.text('Flutter Developer').first);
      await tester.tap(find.text('Flutter Developer').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply now'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'A' * 100);
      await tester.enterText(fields.at(1), 'a' * 100);
      await tester.enterText(fields.at(2), '98765432109876543210');
      await tester.enterText(fields.at(3), 'A' * 700);
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextFormField>(fields.at(0)).controller!.text.length,
        60,
      );
      expect(
        tester.widget<TextFormField>(fields.at(1)).controller!.text.length,
        80,
      );
      expect(
        tester.widget<TextFormField>(fields.at(2)).controller!.text.length,
        10,
      );
      expect(
        tester.widget<TextFormField>(fields.at(3)).controller!.text.length,
        FormValidators.coverLetterMax,
      );

      await tester.ensureVisible(find.text('Submit application'));
      expect(tester.takeException(), isNull);
    },
  );

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
