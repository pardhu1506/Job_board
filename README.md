# JobNest

## Description

JobNest helps job seekers browse remote job openings, search and filter them,
read the full details of a role, and fill in a validated application form.
Applications and appearance preferences are saved on the device. Users can
also create a local account to protect access to their application data.

## Data source

- **Job listings:** [Remotive public API](https://github.com/remotive-com/remote-jobs-api)
  (`https://remotive.com/api/remote-jobs`). No API key is needed, so nothing
  secret is stored in this repository. Remotive is credited in the app and
  each job links back to its Remotive page.
- **Applications:** created by the user and saved on the device with
  `shared_preferences`, so they survive a restart.
- **Account:** one local profile per device. The password itself is never
  stored; a salted verifier is kept in Android secure storage. This demo
  profile does not sync or authenticate against an online service.
- **Cache:** job listings are kept on the device for one hour to avoid calling
  the API too often (Remotive asks apps to fetch only a few times a day).

## Features

- Browse remote jobs with search, job-type, location, and salary filters
- View job descriptions, salary details, tags, and links to the original listing
- Create and edit applications and track their status
- View application statistics and recently viewed jobs
- Create a local profile and sign in; password verifiers use secure storage
- Choose system, light, or dark appearance in Settings
- Refresh job listings from the Remotive API, with a one-hour local cache

## Project structure

```
lib/
  main.dart
  models/       Job, JobApplication, UserProfile
  services/     API, storage, local authentication, validators, date formatting
  providers/    JobProvider, ApplicationProvider, AuthProvider (ChangeNotifier)
  screens/      login, job list/detail, applications, statistics, settings
  widgets/      job card, filter bar, loading / error / empty views, chip
  theme/        AppTheme (the only place a colour is defined)
test/           widget tests and validator tests
```

## How to run

Requirements: Flutter 3.35 or newer (stable), JDK 17, and Android Studio with
the Flutter and Dart plugins.

```bash
git clone https://github.com/pardhu1506/Job_board.git
cd Job_board
flutter pub get
flutter run
flutter test
flutter build apk --release
```

The release APK is created at `build/app/outputs/flutter-apk/app-release.apk`.

## Credits

Job data by [Remotive](https://remotive.com).
