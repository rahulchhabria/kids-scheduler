# Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `kids-scheduler` (or your preferred name)
4. Disable Google Analytics (or enable if you want analytics)
5. Click "Create project"

## Step 2: Add iOS App to Firebase

1. In Firebase Console, click the iOS icon to add an iOS app
2. Register your app:
   - **iOS bundle ID**: `com.yourcompany.KidsScheduler`
   - **App nickname**: Kids Scheduler
   - Leave App Store ID blank for now
3. Click "Register app"

## Step 3: Download Configuration File

1. Download `GoogleService-Info.plist`
2. Move it to: `KidsScheduler/Resources/GoogleService-Info.plist`
3. Add it to your Xcode project (DO NOT add the template file)

## Step 4: Enable Google Sign-In

1. In Firebase Console, go to Authentication → Sign-in method
2. Enable "Google" provider
3. Set support email
4. Save

## Step 5: Configure Google Sign-In in Xcode

1. Open `GoogleService-Info.plist`
2. Find `REVERSED_CLIENT_ID` value
3. In Xcode, go to your target → Info → URL Types
4. Add new URL Type:
   - **Identifier**: `com.google.gid`
   - **URL Schemes**: Paste the `REVERSED_CLIENT_ID` value

## Step 6: Enable Firestore Database

1. In Firebase Console, go to Firestore Database
2. Click "Create database"
3. Start in **Test mode** (for development)
4. Choose location (select closest to your users)
5. Click "Enable"

## Step 7: Set Up Firestore Security Rules

Once you're ready for production, update your Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - only the user can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Children collection - only the parent can read/write
    match /children/{childId} {
      allow read, write: if request.auth != null &&
        get(/databases/$(database)/documents/children/$(childId)).data.parentId == request.auth.uid;
    }

    // Groups collection - members can read, creator can write
    match /groups/{groupId} {
      allow read: if request.auth != null &&
        request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.members;
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/groups/$(groupId)).data.createdBy == request.auth.uid;
    }

    // Playdates collection - group members can read, creator can write
    match /playdates/{playdateId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## Step 8: Enable Cloud Messaging (for Push Notifications)

1. In Firebase Console, go to Cloud Messaging
2. Upload your APNs authentication key:
   - Go to Apple Developer Portal
   - Create an APNs key
   - Download and upload to Firebase
3. Configure in Xcode:
   - Enable Push Notifications capability
   - Enable Background Modes → Remote notifications

## Step 9: Test Configuration

Run the app and test:
- Google Sign-In works
- User data saves to Firestore
- No console errors

## Environment Variables (Optional)

For CI/CD, store these securely:
- `FIREBASE_API_KEY`
- `FIREBASE_PROJECT_ID`
- `GOOGLE_CLIENT_ID`

## COPPA Compliance Notes

Since this app is for children:
1. Disable Firebase Analytics or get parental consent
2. Don't collect personal information without consent
3. Implement parental controls
4. Review [COPPA compliance guide](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions)
