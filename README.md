# AI-Powered Crop Diagnostic Mobile Application

A comprehensive Flutter-based mobile application designed to revolutionize agricultural practices through AI-powered crop diagnosis, real-time market access, and community collaboration.

## Features

### Core Features
- 🤖 **AI-Powered Image Recognition**: Instant crop disease diagnosis using advanced ML models
- 💬 **WhatsApp-Style Chat Interface**: Familiar, intuitive conversational UI
- 🌍 **Multilingual Support**: 27+ languages including English, Swahili, Kikuyu
- 📡 **Offline Functionality**: Works seamlessly without internet connection
- 🌤️ **Weather Integration**: Hyper-local weather data and climate-smart advisories
- 📊 **Smart Record Keeping**: Farm management and analytics
- 🏪 **Market Access**: Real-time pricing and marketplace integration
- 👥 **Expert Consultation**: Connect with agronomists and farming community
- 🎓 **Educational Content**: Interactive learning modules and best practices

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode
- Firebase account (for backend services)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd crop_diagnostic
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Add `google-services.json` (Android) to `android/app/`
- Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`

4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── services/
├── data/
│   ├── models/
│   ├── repositories/
│   └── data_sources/
├── features/
│   ├── authentication/
│   ├── chat/
│   ├── diagnosis/
│   ├── weather/
│   ├── market/
│   ├── community/
│   ├── education/
│   └── profile/
├── providers/
└── main.dart
```

## Architecture

This app follows Clean Architecture principles with:
- **Presentation Layer**: UI components and state management
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Repositories and data sources

## Key Technologies

- **Flutter**: Cross-platform mobile framework
- **Provider/Riverpod**: State management
- **TFLite**: On-device machine learning
- **Hive/SQLite**: Local database
- **Firebase**: Backend services
- **Dio**: Network requests

## Development Phases

### Phase 1 - MVP (Months 1-3)
- [x] Project setup
- [ ] Chat interface
- [ ] AI image recognition
- [ ] Multilingual support
- [ ] Offline functionality
- [ ] Weather integration

### Phase 2 - Core Features (Months 4-6)
- [ ] Expert consultation
- [ ] Community forums
- [ ] Market prices
- [ ] Record keeping
- [ ] Voice support

### Phase 3 - Advanced Features (Months 7-12)
- [ ] Marketplace
- [ ] Satellite imagery
- [ ] Financial services
- [ ] IoT integration

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

This project is licensed under the MIT License.

## Support

For support, email support@cropdiagnostic.app or join our Slack channel.
