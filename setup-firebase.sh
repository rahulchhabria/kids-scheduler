#!/bin/bash

# Firebase Setup Script for Kids Scheduler
# This script will guide you through setting up Firebase

set -e

echo "🔥 Firebase Setup for Kids Scheduler"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}➜${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    print_warning "Firebase CLI not found. Would you like to install it? (y/n)"
    read -r install_firebase
    if [ "$install_firebase" = "y" ]; then
        print_step "Installing Firebase CLI..."
        npm install -g firebase-tools
        print_success "Firebase CLI installed!"
    else
        print_warning "You can install it later with: npm install -g firebase-tools"
    fi
fi

echo ""
print_step "Step 1: Create Firebase Project"
echo "   1. Go to https://console.firebase.google.com/"
echo "   2. Click 'Add project'"
echo "   3. Enter project name: kids-scheduler (or your preferred name)"
echo "   4. Disable Google Analytics (or enable if you want)"
echo "   5. Click 'Create project'"
echo ""
read -p "Press ENTER when you've created your Firebase project..."

echo ""
print_step "Step 2: Add iOS App to Firebase"
echo "   1. In Firebase Console, click the iOS icon"
echo "   2. Enter iOS bundle ID (we'll use): com.yourcompany.KidsScheduler"
echo "   3. App nickname: Kids Scheduler"
echo "   4. Click 'Register app'"
echo ""

print_warning "What bundle identifier do you want to use?"
echo "   (Press ENTER for default: com.yourcompany.KidsScheduler)"
read -r bundle_id
if [ -z "$bundle_id" ]; then
    bundle_id="com.yourcompany.KidsScheduler"
fi

print_success "Using bundle ID: $bundle_id"
echo ""
read -p "Press ENTER when you've registered the iOS app..."

echo ""
print_step "Step 3: Download GoogleService-Info.plist"
echo "   1. Download the GoogleService-Info.plist file from Firebase Console"
echo "   2. Save it to your Downloads folder"
echo ""
read -p "Press ENTER when you've downloaded the file..."

# Check if file exists in Downloads
GOOGLE_SERVICE_FILE="$HOME/Downloads/GoogleService-Info.plist"
if [ -f "$GOOGLE_SERVICE_FILE" ]; then
    print_success "Found GoogleService-Info.plist in Downloads!"

    # Copy to project
    cp "$GOOGLE_SERVICE_FILE" "KidsScheduler/Resources/GoogleService-Info.plist"
    print_success "Copied GoogleService-Info.plist to KidsScheduler/Resources/"

    # Extract REVERSED_CLIENT_ID
    REVERSED_CLIENT_ID=$(/usr/libexec/PlistBuddy -c "Print :REVERSED_CLIENT_ID" "$GOOGLE_SERVICE_FILE" 2>/dev/null || echo "")

    if [ -n "$REVERSED_CLIENT_ID" ]; then
        print_success "Found REVERSED_CLIENT_ID: $REVERSED_CLIENT_ID"

        # Update Info.plist with REVERSED_CLIENT_ID
        /usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 $REVERSED_CLIENT_ID" "KidsScheduler/Info.plist" 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string $REVERSED_CLIENT_ID" "KidsScheduler/Info.plist"

        print_success "Updated Info.plist with REVERSED_CLIENT_ID"
    fi
else
    print_error "GoogleService-Info.plist not found in Downloads folder"
    print_warning "Please manually copy it to: KidsScheduler/Resources/GoogleService-Info.plist"
fi

# Update bundle identifier in project.pbxproj
print_step "Updating bundle identifier in Xcode project..."
sed -i '' "s/com\.yourcompany\.KidsScheduler/$bundle_id/g" "KidsScheduler.xcodeproj/project.pbxproj"
print_success "Bundle identifier updated to: $bundle_id"

echo ""
print_step "Step 4: Enable Google Sign-In"
echo "   1. In Firebase Console, go to Authentication → Sign-in method"
echo "   2. Click on 'Google' provider"
echo "   3. Toggle 'Enable'"
echo "   4. Set support email"
echo "   5. Click 'Save'"
echo ""
read -p "Press ENTER when you've enabled Google Sign-In..."

echo ""
print_step "Step 5: Enable Firestore Database"
echo "   1. In Firebase Console, go to Firestore Database"
echo "   2. Click 'Create database'"
echo "   3. Start in 'Test mode' (for development)"
echo "   4. Choose location closest to your users"
echo "   5. Click 'Enable'"
echo ""
read -p "Press ENTER when you've enabled Firestore..."

echo ""
echo "================================================"
print_success "Firebase setup complete! 🎉"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Open the project: open KidsScheduler.xcodeproj"
echo "  2. Wait for Swift packages to download"
echo "  3. Select an iPad simulator"
echo "  4. Press ⌘R to build and run"
echo ""
echo "Bundle ID: $bundle_id"
if [ -n "$REVERSED_CLIENT_ID" ]; then
    echo "REVERSED_CLIENT_ID: $REVERSED_CLIENT_ID"
fi
echo ""
print_warning "Remember: Update Firestore security rules when ready for production!"
echo "         See: config/firebase-setup-guide.md"
echo ""
