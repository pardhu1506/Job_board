# Defect Log

No defects were found in the automated checks listed below. The release APK
was installed on an Android phone, but the remaining physical-device scenarios
have not yet been tested. Record each newly discovered defect here, including
reproduction steps and its fix status.

## Automated checks

| Check | Reproduction / test | Result |
|---|---|---|
| Empty application fields | Open a job, choose Apply now, and submit with every field blank (`flutter test`) | Each field shows its own validation message; no defect found |
| Long application entries | Enter over-limit name, email, phone, and cover-letter text (`flutter test`) | Input limits are enforced; no defect found |
| Long search and no matches | Enter over 60 characters of text that matches no job (`flutter test`) | Search is limited and the no-match view appears; no defect found |
| Landscape application form | Render the form at 900 × 600 and scroll to Submit (`flutter test`) | Form remains scrollable and Submit is reachable; no defect found |
| Repeated fast taps | Tap a job card six times while its route opens (`flutter test`) | Only one details screen opens; no defect found |
| Job-list states | Widget tests return jobs, no jobs, and a simulated API error | Data, empty, and retryable error states appear; no defect found |
| Regression suite | Run `flutter test` | Passed |
| Static analysis | Run `flutter analyze` | No issues found |
| Release build | Run `flutter build apk --release` | APK built successfully |

## Physical-device checks still to run

Use a test profile and test application data; do not clear personal app data.

- [ ] Turn on airplane mode and verify the error message and Retry action.
- [ ] Restore internet and verify Retry loads the jobs.
- [ ] Tap a job card rapidly several times and verify only one detail screen opens.
- [ ] Tap Submit rapidly several times and verify only one application is saved.
- [ ] Rotate the job list, details, application form, and My applications screens.
- [ ] Save an application, restart the app, and verify it remains saved.
