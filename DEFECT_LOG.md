# Defect Log

Record every defect found while testing. Add a row for each one, including the
ones you fixed straight away. Replace the example rows with your own.

| ID | Test (GP 8) | Defect found | Steps to reproduce | Fixed? | Fix or note |
|---|---|---|---|---|---|
| D1 | No internet | EXAMPLE: app showed a blank screen | 1. Turn on airplane mode 2. Clear app data 3. Open the app | Yes | Added error message and Retry button |
| D2 | Very long text | EXAMPLE: long job title overflowed the card | 1. Find a job with a long title 2. Open the list | Yes | Added maxLines and ellipsis |
| D3 | Phone sideways | EXAMPLE: form fields hidden by keyboard | 1. Rotate to landscape 2. Open the form 3. Tap a field | Yes | Wrapped the form in a scroll view |

## Test checklist (GP 8)

Tick each one on a physical phone with the release APK, and log any defect.

- [ ] Empty input: submit the form with every field empty
- [ ] Empty input: search for text that matches nothing
- [ ] Very long text: type 100+ characters in name, email, search and cover letter
- [ ] No internet: airplane mode, clear app data, open the app (error + Retry)
- [ ] No internet: turn internet back on, tap Retry (data loads)
- [ ] Repeated fast taps: tap a job card quickly 5 times (one detail screen only)
- [ ] Repeated fast taps: tap Submit quickly 5 times (one application saved)
- [ ] Phone sideways: list, detail, form and My applications in landscape
- [ ] Restart: apply for a job, close the app completely, reopen (application is still there)
