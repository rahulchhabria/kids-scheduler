# Setting Up Development Team in Xcode

You're seeing the error: "Signing for 'KidsScheduler' requires a development team."

## Quick Fix (2 options):

### Option 1: Sign in with Apple ID (Recommended)

1. In Xcode, go to **Xcode → Settings** (or Preferences)
2. Click the **Accounts** tab
3. Click the **+** button to add an Apple ID
4. Sign in with your Apple ID
5. Close the Settings window
6. In your project:
   - Select **KidsScheduler** project in the left sidebar
   - Select the **KidsScheduler** target
   - Go to **Signing & Capabilities** tab
   - Check **"Automatically manage signing"**
   - From the **Team** dropdown, select your Apple ID

### Option 2: Use Personal Team (If already signed in)

1. Select **KidsScheduler** project in the Navigator (left sidebar)
2. Select the **KidsScheduler** target (under Targets)
3. Click the **Signing & Capabilities** tab
4. Check **"Automatically manage signing"**
5. From the **Team** dropdown, select:
   - Your Apple ID (Personal Team) - appears as "Your Name (Personal Team)"

## No Apple Developer Account Required

You don't need a paid Apple Developer account ($99/year) for:
- Running on simulator ✅
- Testing on your own device ✅
- Development and debugging ✅

You only need a paid account if you want to:
- Publish to the App Store
- Use advanced capabilities (push notifications in production, etc.)

## After Selecting Team

Once you select a team:
1. Xcode will automatically create a provisioning profile
2. The error will disappear
3. You can build and run the app

Press **⌘B** to build, or **⌘R** to build and run!
