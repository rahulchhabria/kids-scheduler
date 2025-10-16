# Quick Start Guide - Kids Scheduler

## Opening the Project

1. **Open Xcode project:**
   ```bash
   open KidsScheduler.xcodeproj
   ```

2. **Wait for package dependencies to resolve**
   - Xcode will automatically download Firebase SDK and Google Sign-In
   - This may take 2-5 minutes on first open
   - Watch the progress in the top center of Xcode

## Initial Configuration

### Step 1: Set Your Bundle Identifier

1. In Xcode, select the `KidsScheduler` project in the left sidebar
2. Select the `KidsScheduler` target
3. Go to "Signing & Capabilities" tab
4. Change `PRODUCT_BUNDLE_IDENTIFIER` from `com.yourcompany.KidsScheduler` to your own (e.g., `com.yourusername.KidsScheduler`)

### Step 2: Firebase Setup

**Follow the complete guide:** `config/firebase-setup-guide.md`

Quick steps:
1. Create Firebase project at https://console.firebase.google.com/
2. Add iOS app with your bundle identifier
3. Download `GoogleService-Info.plist`
4. Drag it into `KidsScheduler/Resources/` in Xcode
5. Enable Authentication → Google Sign-In
6. Enable Firestore Database

### Step 3: Configure Google Sign-In URL Scheme

1. Open the downloaded `GoogleService-Info.plist`
2. Find the `REVERSED_CLIENT_ID` value (looks like `com.googleusercontent.apps.123456789-abc...`)
3. In Xcode, go to `KidsScheduler/Info.plist`
4. Find `CFBundleURLTypes` → `CFBundleURLSchemes`
5. Replace `REPLACE_WITH_REVERSED_CLIENT_ID` with your actual reversed client ID

## Running the App

### Choose iPad Simulator

1. In Xcode toolbar, click the device selector (next to the scheme)
2. Select an iPad simulator:
   - **iPad Pro (12.9-inch) (6th generation)** - Recommended
   - **iPad Air (5th generation)**
   - Or any iPad simulator

### Build and Run

1. Press **⌘R** or click the Play button
2. First build will take 2-3 minutes (compiling Firebase)
3. The simulator will launch and show the Welcome screen

## Project Structure at a Glance

```
KidsScheduler/
├── KidsSchedulerApp.swift           # App entry point
├── ContentView.swift                # Root view router
├── Models/                          # Data models
│   ├── User.swift                   # Parent account
│   ├── Child.swift                  # Child profile
│   ├── Group.swift                  # Friend groups
│   └── Playdate.swift               # Events
├── Views/                           # UI screens
│   ├── WelcomeView.swift            # Login screen
│   ├── ChildProfileSetupView.swift  # Onboarding
│   └── MainTabView.swift            # Main navigation
├── ViewModels/                      # Business logic
│   └── AuthenticationViewModel.swift
├── Services/                        # Backend
│   ├── AuthenticationService.swift  # Google OAuth
│   └── FirestoreService.swift       # Database CRUD
└── Resources/                       # Add GoogleService-Info.plist here!
```

## Current Implementation Status

### ✅ Completed
- Project structure with MVVM architecture
- All data models (User, Child, Group, Playdate)
- Authentication service skeleton
- Firestore service with generic CRUD
- Welcome screen UI
- Child profile setup UI
- Main tab navigation

### 🚧 Next Steps (Not Yet Implemented)
- Complete Google Sign-In flow
- Firestore integration
- Calendar view implementation
- Create playdate flow
- RSVP system
- Parent dashboard
- Push notifications

## Testing Without Firebase

If you want to test the UI before setting up Firebase:

1. Comment out Firebase initialization in `KidsSchedulerApp.swift`:
   ```swift
   // FirebaseApp.configure()
   ```

2. Mock the authentication in `ContentView.swift`:
   ```swift
   // Change:
   if authViewModel.isAuthenticated {

   // To:
   if true {  // Force authenticated for UI testing
   ```

3. You'll see a placeholder "Main Tab View" - this is expected!

## Common Issues

### Issue: "No such module 'FirebaseAuth'"
**Solution:** Wait for Swift packages to finish downloading. Check File → Packages → Resolve Package Versions

### Issue: "GoogleService-Info.plist not found"
**Solution:** Make sure you've added it to `KidsScheduler/Resources/` and it's included in the target

### Issue: Google Sign-In fails
**Solution:** Verify the `REVERSED_CLIENT_ID` is correctly set in Info.plist

### Issue: Simulator crashes on launch
**Solution:** Check console for errors. Usually means Firebase isn't configured correctly.

## What to Build Next?

Based on priority, here's the recommended order:

1. **Complete Authentication Flow**
   - Finish Google Sign-In integration
   - Test with real Firebase project
   - Implement child profile creation

2. **Build Calendar View**
   - Week/month calendar UI
   - Fetch playdates from Firestore
   - Display events on calendar

3. **Create Playdate Flow**
   - Activity picker
   - Date/time selection
   - Friend invitation
   - Save to Firestore

4. **RSVP System**
   - Notification UI
   - Accept/decline buttons
   - Parent approval flow

5. **Groups Feature**
   - Create group
   - Join with invite code
   - Group member list

## Resources

- **Documentation:** `docs/wireframes.md` and `docs/data-models-detailed.md`
- **Firebase Setup:** `config/firebase-setup-guide.md`
- **Firebase Console:** https://console.firebase.google.com/
- **Apple Developer:** https://developer.apple.com/
- **SwiftUI Docs:** https://developer.apple.com/documentation/swiftui

## Getting Help

If you run into issues:
1. Check the Firebase Console for configuration errors
2. Review Xcode console output for error messages
3. Verify all files are included in the target (check File Inspector)
4. Make sure bundle identifier matches across Firebase and Xcode

---

Happy coding! 🚀 You're ready to build a great app for kids!
