# Kids Scheduler - iPadOS App

A playdate scheduling app designed for kids to plan and coordinate activities with their friends, with parental oversight and approval.

## Overview

Kids Scheduler is like "Google Workspace for kids" - enabling children to create private groups, share calendars, and book playdates with friends. The app emphasizes safety, parental control, and a kid-friendly user experience.

## Features

### For Kids
- 📅 Visual calendar to see upcoming playdates
- 👥 Join friend groups (class, sports team, neighborhood)
- ➕ Create playdate invites with activity templates
- 🔔 Respond to invitations (Yes/Maybe/No)
- 🎨 Kid-friendly UI with emoji avatars and large buttons

### For Parents
- 🔐 Google OAuth sign-in
- 👶 Manage multiple child profiles
- ✅ Approve/decline playdate requests
- 📞 View parent contact information
- ⚙️ Configure group settings and permissions

### Safety & Privacy
- Parent approval required for all playdates
- Private, invite-only groups
- No direct messaging between kids
- COPPA compliance considerations
- All activity visible to parents

## Tech Stack

### Frontend
- **Swift** + **SwiftUI** - Native iPadOS development
- **EventKit** - Calendar integration
- **Google Sign-In SDK** - Authentication

### Backend
- **Firebase Auth** - Google OAuth authentication
- **Firestore** - Real-time NoSQL database
- **Cloud Functions** - Backend logic & notifications
- **Firebase Cloud Messaging** - Push notifications
- **Firebase Storage** - Avatar/photo storage

## Project Structure

```
KidsScheduler/
├── KidsSchedulerApp.swift          # App entry point
├── ContentView.swift               # Root view controller
├── Models/                         # Data models
│   ├── User.swift                  # Parent account
│   ├── Child.swift                 # Child profile
│   ├── Group.swift                 # Friend group
│   └── Playdate.swift              # Event/playdate
├── Views/                          # UI components
│   ├── WelcomeView.swift           # Login screen
│   ├── ChildProfileSetupView.swift # Onboarding
│   ├── MainTabView.swift           # Tab navigation
│   └── ...
├── ViewModels/                     # Business logic
│   └── AuthenticationViewModel.swift
├── Services/                       # Backend services
│   ├── AuthenticationService.swift
│   └── FirestoreService.swift
└── Resources/                      # Assets, configs
    └── GoogleService-Info.plist
```

## Getting Started

### Prerequisites

1. **Xcode 15+** with iPadOS 16+ SDK
2. **Firebase project** (see setup guide)
3. **Google Cloud Console** project (for OAuth)
4. **CocoaPods** or **Swift Package Manager**

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/kids-scheduler.git
cd kids-scheduler
```

2. Install dependencies:
```bash
# Using Swift Package Manager (recommended)
open KidsScheduler.xcodeproj
# Xcode will automatically resolve packages

# OR using CocoaPods
pod install
open KidsScheduler.xcworkspace
```

3. Configure Firebase:
   - Follow the guide in `config/firebase-setup-guide.md`
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add it to `KidsScheduler/Resources/`

4. Set up Google Sign-In:
   - Add `REVERSED_CLIENT_ID` to URL Types in Xcode
   - See `config/firebase-setup-guide.md` for details

5. Run the app:
   - Select iPad simulator or device
   - Press Cmd+R to build and run

## Documentation

- **[Wireframes](docs/wireframes.md)** - Complete UI/UX design specifications
- **[Data Models](docs/data-models-detailed.md)** - Detailed database schema
- **[Firebase Setup](config/firebase-setup-guide.md)** - Backend configuration guide

## Development Phases

### Phase 1: MVP (8-12 weeks)
- [x] Project structure and Firebase setup
- [ ] Google OAuth authentication
- [ ] Child profile management
- [ ] Create/join groups with invite codes
- [ ] Basic calendar view
- [ ] Create playdate events
- [ ] RSVP system
- [ ] Parent approval flow

### Phase 2: Enhanced Features (6-8 weeks)
- [ ] Push notifications
- [ ] Recurring events
- [ ] Location suggestions/favorites
- [ ] Activity templates
- [ ] Availability preferences
- [ ] Parent-approved photo sharing

### Phase 3: Polish (4-6 weeks)
- [ ] iPad split-view support
- [ ] Drag & drop calendar interactions
- [ ] Accessibility improvements
- [ ] Localization
- [ ] Advanced parental controls
- [ ] Analytics dashboard

## Security & Compliance

### COPPA Compliance
This app is designed for children and must comply with the Children's Online Privacy Protection Act (COPPA):

- Parental consent required for account creation
- Minimal data collection
- No behavioral tracking or advertising
- Parent can view/delete all child data
- Privacy policy clearly visible

See [FTC COPPA Guidelines](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions)

### Firebase Security
- Firestore security rules enforce parent-child relationships
- All writes require authentication
- Row-level security on sensitive data
- No public read access

## Testing

### Unit Tests
```bash
# Run unit tests
xcodebuild test -scheme KidsScheduler -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)'
```

### UI Tests
```bash
# Run UI tests
xcodebuild test -scheme KidsSchedulerUITests -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)'
```

## Contributing

This is a private project, but contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is proprietary. All rights reserved.

## Contact

For questions or feedback:
- Email: support@kidsscheduler.app
- Issues: [GitHub Issues](https://github.com/yourusername/kids-scheduler/issues)

## Acknowledgments

- Design inspired by kid-friendly apps like Epic! and Khan Academy Kids
- Firebase for backend infrastructure
- Apple Human Interface Guidelines for iPadOS design patterns

---

Built with ❤️ for kids and parents everywhere!
