# AICP membership app

Flutter app. All data is sample data held in memory; login and payment are simulated. No backend, keys or accounts are needed to run it.

## Starting the app

When asked to start, run or open the app:

1. Check Flutter: `flutter --version`. If it is missing, tell the user to install the stable channel from https://docs.flutter.dev/get-started/install (on macOS: `brew install --cask flutter`), then continue.
2. From the repository root run `./scripts/start.sh`. It runs `flutter pub get` and opens the app in Chrome.
   - On Windows without Git Bash, run `flutter pub get` then `flutter run -d chrome` instead.
   - For the iPhone simulator on macOS with Xcode, run `./scripts/start.sh ios`.
3. `flutter run` stays in the foreground while the app is open; run it in the background or in a terminal tab and tell the user the app is open in Chrome.
4. If `flutter doctor` reports Chrome missing, ask the user to install Google Chrome.

Then share the demo access from `README.md` (member mobile 9876543210, code 123456; master@aipc.demo / demo1234).

## Checks

- `flutter analyze` and `flutter test` must pass before a change is done.
- The app's user-facing name is AICP (All India Congress Party).
