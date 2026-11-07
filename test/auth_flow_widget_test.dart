import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/main.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/services/auth_service.dart';
import 'package:job_board/services/job_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryCredentialStore implements CredentialStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async {
    this.value = value;
  }

  @override
  Future<void> delete() async {
    value = null;
  }
}

class _EmptyJobApiService extends JobApiService {
  @override
  Future<List<Job>> fetchJobs() async => [];
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('creates profile, logs out, and logs in again', (tester) async {
    final authService = AuthService(credentialStore: _MemoryCredentialStore());
    await tester.pumpWidget(
      JobBoardApp(jobService: _EmptyJobApiService(), authService: authService),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create profile'), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ravi Kumar');
    await tester.enterText(fields.at(1), 'ravi@example.com');
    await tester.enterText(fields.at(2), 'a-strong-password');
    await tester.enterText(fields.at(3), 'a-strong-password');
    await tester.ensureVisible(find.text('Create profile'));
    await tester.tap(find.text('Create profile'));
    await tester.pumpAndSettle();

    expect(find.text('JobNest'), findsOneWidget);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Ravi Kumar'), findsOneWidget);
    expect(find.text('ravi@example.com'), findsOneWidget);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();
    expect(find.text('Log in'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'wrong-password');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Email or password is incorrect.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).last,
      'a-strong-password',
    );
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('No jobs available right now'), findsOneWidget);
  });
}
