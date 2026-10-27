# AIPC Membership App — Proof of Concept

> This is a proof of concept for demonstration purposes only. It uses sample data, a simulated login and a simulated payment screen. It is not production software and does not store or transmit any personal data.

## Overview

This proof of concept shows the membership journey for the All India Professionals' Congress (AIPC) on iPhone. A member sees an introduction, chooses a language, verifies a mobile number and completes a three-step application. A state representative reviews applications for their state. Once approved, the member chooses a membership, pays through a simulated payment screen and receives a membership card. Members receive in-app notices. The master login sees all states.

## What is simulated

- **Login:** a fixed demo code replaces SMS verification.
- **Payment:** the payment sheet is a demonstration. No money is charged.
- **Data:** all records are held in memory and reset when the app restarts.
- **Photo:** the camera is live where available; otherwise a demo capture is used.
- **Constituencies, districts and names:** sample data only. PIN code lookups use a small sample of the official directory.

## Running the app

Requirements: macOS, Xcode with the iOS Simulator, and Flutter (stable channel).

```bash
flutter pub get
open -a Simulator
flutter run
```

## Demo access

| Role | Sign-in |
|------|---------|
| Member | Mobile 9876543210 (new), OTP 123456 |
| Master admin | master@aipc.demo, password demo1234 |
| State representative | e.g. pb@aipc.demo (Punjab), password demo1234. Every state and union territory has one. |

## Suggested walkthrough

1. Open the app on the landing page and tap **Next**.
2. Choose a language (Hindi is the default).
3. Choose **Member**, enter the demo mobile number and the demo code.
4. Complete the three registration steps: identity and domain, location (try PIN 142026), and photo with one social profile link.
5. Sign in as a state representative (for example pb@aipc.demo) and approve the application.
6. Back in the member app, choose a membership, review and pay with **Simulate success**.
7. Sign in as master@aipc.demo to see all states, or open a state's dashboard.

### Mac webcam demo

The iOS Simulator cannot use a camera. To use your Mac's webcam, open `ios/Runner.xcworkspace` in Xcode, choose the destination **My Mac (Designed for iPad)** and run. Without a camera the app shows a demo capture button instead.

## Languages

Hindi is the default language. English is complete. Punjabi and Odia are partly translated in this proof of concept; untranslated text appears in English.

## Next steps

Production scope, integrations and timelines will be agreed separately.
