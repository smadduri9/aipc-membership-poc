# AIPC Membership App — Proof of Concept

> This is a proof of concept for demonstration purposes only. It uses sample data, a simulated login and a simulated payment screen. It is not production software and does not store or transmit any personal data.

## Overview

This proof of concept shows the membership journey for the All India Professionals' Congress (AIPC) on iPhone. A member chooses a language, verifies a mobile number, completes a four-step registration, pays a membership fee through a simulated payment screen, follows the status of the application and receives a membership card. An administrator reviews applications, approves or rejects them, and reviews an audit log.

## What is simulated

- **Login:** a fixed demo code replaces SMS verification.
- **Payment:** the payment sheet is a demonstration. No money is charged.
- **Data:** all records are held in memory and reset when the app restarts.
- **Selfie:** placeholder avatars replace the camera.
- **Constituencies and names:** sample data only.

## Running the app

Requirements: macOS, Xcode with the iOS Simulator, and Flutter (stable channel).

```bash
flutter pub get
open -a Simulator
flutter run
```

## Demo access

| Role   | Sign-in                       |
|--------|-------------------------------|
| Member | Mobile 9876543210, code 123456 |
| Admin  | admin@aipc.demo, password demo1234 |

## Suggested walkthrough

1. Choose a language. Hindi is the default.
2. Enter the demo mobile number, tick the consent box and request a code.
3. Enter the demo code to open the home screen.
4. Select **Become a Member** and complete the four registration steps.
5. Review the details and confirm them.
6. Choose a payment method and select **Simulate success**.
7. View the status timeline, showing the application awaiting approval.
8. Sign in as the administrator and open the application.
9. Approve the application, then check the audit log and export the list as CSV.
10. Return to the member app to see the approved status and membership card.

## Languages

Hindi is the default language. English is complete. Punjabi and Odia are partly translated in this proof of concept; untranslated text appears in English.

## Next steps

Production scope, integrations and timelines will be agreed separately.
