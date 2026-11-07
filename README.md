# JobNest

**Topic:** Job Board  
**Programme:** Flutter Application Development, KHIT Guntur (IITM Pravartak and BodhBridge Flutter Lab)

## Description

JobNest helps job seekers browse remote job openings, search and filter them,
read the full details of a role, and fill in a validated application form.
Applications are saved on the phone and can be reviewed later.

<!-- TODO: replace with 2 or 3 sentences in your own words about who the app is for -->

## Screenshots

| Job list | Job detail | Application form | My applications |
|---|---|---|---|
| ![List](screenshots/list.png) | ![Detail](screenshots/detail.png) | ![Form](screenshots/form.png) | ![Applications](screenshots/applications.png) |

<!-- TODO: take at least 3 screenshots from the phone, put them in a screenshots/ folder -->

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

- Job list with loading, error with retry, empty, and data states
- Search by role or company, filter by job type and location
- Pull down to refresh
- Detail screen with description, salary, tags, date and original link
- Salary range filter that keeps jobs with undisclosed salaries visible
- Application form with validation on every field
- My applications screen with editable applications and Applied, Interview,
  Offer, and Rejected status chips
- Application statistics grouped by status
- Recently viewed jobs (last 10, saved on the device)
- Settings screen with persistent system, light, and dark appearance options
- Local profile creation and login, with password verifiers stored in Android
  secure storage and app access gated by login
- Light and dark theme generated from one seed colour

## Project structure

```
lib/
  main.dart
  models/       Job, JobApplication
  services/     API, storage, local authentication, validators, date formatting
  providers/    JobProvider, ApplicationProvider, AuthProvider (ChangeNotifier)
  screens/      login, list, detail, form, my applications, settings
  widgets/      job card, filter bar, loading / error / empty views, chip
  theme/        AppTheme (the only place a colour is defined)
test/           widget tests and validator tests
```

## How to run

Requirements: Flutter 3.35 or newer (stable), JDK 17, Android Studio with the
Flutter and Dart plugins.

```bash
git clone <YOUR-REPOSITORY-URL>
cd job_board
flutter pub get
flutter run                      # emulator or connected phone
flutter test                     # run the tests
flutter build apk --release      # release APK
```

The release APK is created at `build/app/outputs/flutter-apk/app-release.apk`.

## Team

| Member | Parts built |
|---|---|
| <!-- Name 1 --> | <!-- e.g. Data layer: Job model, JobApiService, StorageService, JobProvider --> |
| <!-- Name 2 --> | <!-- e.g. List screen, filter bar, job card, loading / error / empty views --> |
| <!-- Name 3 --> | <!-- e.g. Detail screen, application form, validators, My applications --> |

## Credits

Job data by [Remotive](https://remotive.com).
