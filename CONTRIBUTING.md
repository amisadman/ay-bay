# Contributing to AyBay

Thank you for your interest in contributing to AyBay! AyBay was created to provide a pristine, ad-free, and intelligent financial management experience. By contributing, you're helping maintain a tool built by users, for users.

## 🛠️ How to Contribute

Whether you're fixing bugs, adding new features, or improving documentation, we welcome your help. 

### 1. Setting up the Development Environment

AyBay is built with Flutter. To run it locally:
1. Ensure you have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed (version >=3.0.0).
2. Clone this repository: `git clone https://github.com/amisadman/ay-bay.git`
3. Fetch the dependencies: `flutter pub get`
4. Run the app on your emulator or connected device: `flutter run`

### 2. Finding Something to Work On
Check our GitHub Issues tab. Look for issues tagged with `good first issue`, `help wanted`, or `bug`. If you have a new feature idea, please open an issue first to discuss it before writing code!

### 3. Making Changes
1. Fork the repository on GitHub.
2. Create a new branch for your feature/bugfix: `git checkout -b feature/your-feature-name`
3. Make your changes in the codebase.
4. Ensure your code follows Flutter/Dart best practices and doesn't break existing functionality (especially local SQLite data models).
5. Commit your changes with a clear message: `git commit -m "feat: add amazing new tracker"`
6. Push to your fork: `git push origin feature/your-feature-name`
7. Open a Pull Request against the `main` branch of this repository.

## ⚠️ Important Rules

- **No Commercial Integrations:** AyBay is strictly non-commercial and ad-free. Do not submit PRs that add telemetry, advertisements, or paywalls.
- **Walleo AI Changes:** If you are contributing to `ai_provider.dart` (Walleo), ensure you do not expose any API keys. We use a Bring-Your-Own-Key (BYOK) architecture via `flutter_secure_storage`.
- **Code of Conduct:** Please read and adhere to our [Code of Conduct](CODE_OF_CONDUCT.md).

We're excited to review your Pull Request!
