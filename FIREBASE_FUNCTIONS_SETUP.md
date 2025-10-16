# Firebase Cloud Functions Setup Guide

This guide walks you through setting up Firebase Cloud Functions for email invitations and push notifications.

## Overview

The functions handle:
1. **Email Invitations** - Sent when parent approves friend request
2. **Push Notifications** - Alert parents of approval requests
3. **Friendship Notifications** - Notify kids when friendships are approved
4. **Auto-Expiry** - Clean up old invitations daily
5. **Badge Counts** - Update pending approval counts

## Prerequisites

- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project set up (already done: kids-scheduler)
- Blaze (pay-as-you-go) plan for external API calls

## Initial Setup

### 1. Initialize Firebase Functions

```bash
cd /Users/rahulchhabria/Documents/GitHub/kids-scheduler

# Login to Firebase
firebase login

# Initialize functions (if not already done)
firebase init functions

# Choose:
# - Use existing project: kids-scheduler
# - Language: JavaScript
# - ESLint: Yes
# - Install dependencies: Yes
```

### 2. Install Dependencies

```bash
cd firebase/functions
npm install firebase-admin firebase-functions nodemailer
```

### 3. Configure Email Service

We're using SendGrid, but you can use any SMTP provider.

#### Option A: SendGrid (Recommended)

1. Sign up at https://sendgrid.com
2. Create an API key
3. Set Firebase config:

```bash
firebase functions:config:set sendgrid.key="YOUR_SENDGRID_API_KEY"
```

#### Option B: Gmail

```bash
firebase functions:config:set gmail.email="your-email@gmail.com"
firebase functions:config:set gmail.password="your-app-password"
```

Then update `firebase/functions/index.js`:

```javascript
const mailTransport = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: functions.config().gmail.email,
    pass: functions.config().gmail.password
  }
});
```

#### Option C: AWS SES

```bash
firebase functions:config:set aws.accesskey="YOUR_ACCESS_KEY"
firebase functions:config:set aws.secretkey="YOUR_SECRET_KEY"
```

### 4. Update App URL

Edit `firebase/functions/index.js` and update:

```javascript
const APP_URL = 'https://your-actual-domain.com';
```

## Deploy Functions

### Deploy All Functions

```bash
firebase deploy --only functions
```

### Deploy Specific Function

```bash
firebase deploy --only functions:sendFriendInvitationEmail
firebase deploy --only functions:sendParentApprovalNotification
```

## Test Functions Locally

### Start Emulators

```bash
cd firebase/functions
npm run serve
```

This starts local emulators for testing without deploying.

### Test Email Function

```bash
# In another terminal
firebase functions:shell

# Then in the shell:
sendFriendInvitationEmail({
  before: { status: 'pendingFromParentApproval' },
  after: {
    status: 'pendingRecipient',
    fromChildName: 'Alex',
    fromParentName: 'John Smith',
    fromParentEmail: 'john@example.com',
    toEmail: 'test@example.com',
    message: 'We met at soccer!'
  }
}, { params: { invitationId: 'test123' } })
```

## Set Up Push Notifications

### 1. Enable Firebase Cloud Messaging

1. Go to Firebase Console → Project Settings
2. Click "Cloud Messaging" tab
3. Note your Server Key (for testing)

### 2. Add FCM to iOS App

Already done in your Info.plist, but verify:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

### 3. Store FCM Tokens

Update `AuthenticationService.swift` to save tokens:

```swift
import FirebaseMessaging

func saveFCMToken() async {
    guard let token = await Messaging.messaging().token else { return }

    let userRef = Firestore.firestore().collection("users").document(userId)
    try? await userRef.updateData(["fcmToken": token])
}
```

### 4. Request Notification Permissions

Add to `KidsSchedulerApp.swift`:

```swift
import UserNotifications

init() {
    FirebaseApp.configure()

    // Request notification permissions
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
        if granted {
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
```

## Function Details

### 1. sendFriendInvitationEmail

**Trigger:** When `friendInvitations` document status changes to `pendingRecipient`

**What it does:**
- Sends HTML email to recipient's parent
- Includes child's name, message, and parent contact info
- Creates clickable link to accept invitation
- Logs email send status

**Email Template:** Beautiful HTML with gradient header and call-to-action button

### 2. sendParentApprovalNotification

**Trigger:** When new `parentApprovalRequests` document is created

**What it does:**
- Gets parent's FCM token from Firestore
- Sends push notification with approval details
- Updates badge count on iOS
- Logs notification status

**Notification Payload:**
```json
{
  "title": "Approval Needed",
  "body": "Alex wants to invite Sam to be friends",
  "data": {
    "type": "parent_approval",
    "requestId": "req123"
  }
}
```

### 3. sendFriendshipApprovedNotification

**Trigger:** When `friendInvitations` status changes to `accepted`

**What it does:**
- Sends success notification to both children
- Gets parent FCM tokens
- Celebratory message with emoji 🎉

### 4. expireOldInvitations

**Trigger:** Daily at midnight (Pacific Time)

**What it does:**
- Finds invitations older than 30 days
- Updates status to `expired`
- Cleans up pending approval requests
- Batch updates for efficiency

### 5. updateParentBadgeCount

**Trigger:** When `parentApprovalRequests` created/updated/deleted

**What it does:**
- Counts pending requests for parent
- Updates `users.pendingApprovalCount` field
- Used for badge display in app

## Monitoring

### View Logs

```bash
# Real-time logs
firebase functions:log

# Filter by function
firebase functions:log --only sendFriendInvitationEmail

# View in Firebase Console
# Go to Functions → Logs
```

### Check Email Logs

```javascript
// Query email logs in Firestore
db.collection('emailLogs')
  .where('sentAt', '>', yesterday)
  .where('status', '==', 'sent')
  .get()
```

### Check Notification Logs

```javascript
// Query notification logs
db.collection('notificationLogs')
  .where('type', '==', 'parent_approval')
  .where('status', '==', 'sent')
  .get()
```

## Cost Estimates

Firebase Functions pricing (Blaze plan):

**Free Tier (per month):**
- 2M invocations
- 400,000 GB-seconds compute time
- 200,000 CPU-seconds
- 5GB outbound networking

**After Free Tier:**
- $0.40 per million invocations
- $0.0000025 per GB-second
- $0.00001 per GHz-second

**Example:** 10,000 invitations/month
- Email function: ~$0.04
- Push notifications: ~$0.04
- Total: ~$0.08/month

**SendGrid Pricing:**
- Free tier: 100 emails/day
- Essentials: $19.95/month for 50,000 emails

## Troubleshooting

### "Permission denied" when deploying

```bash
firebase login --reauth
firebase use kids-scheduler
```

### Emails not sending

1. Check SendGrid API key is set:
```bash
firebase functions:config:get
```

2. Verify email is verified in SendGrid

3. Check logs:
```bash
firebase functions:log
```

### Push notifications not working

1. Verify FCM token is saved in Firestore
2. Check iOS app has notification permissions
3. Test with Firebase Console → Cloud Messaging
4. Ensure APNs certificates are configured

### Functions timeout

Increase timeout in functions (default is 60s):

```javascript
exports.sendEmail = functions
  .runWith({ timeoutSeconds: 120 })
  .firestore.document('...')
  .onCreate(...)
```

## Security

### Environment Variables

Never commit sensitive keys! Use Firebase config:

```bash
# Set config
firebase functions:config:set service.key="secret"

# Get config in function
functions.config().service.key
```

### Firestore Security Rules

Ensure functions have admin access (they do by default):

```javascript
admin.firestore() // Has full access, bypasses security rules
```

## Advanced Features

### Rate Limiting

Add rate limiting to prevent abuse:

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
```

### Email Templates with Variables

Use templating engine like Handlebars:

```javascript
const handlebars = require('handlebars');

const template = handlebars.compile(emailTemplate);
const html = template({ childName, message, ... });
```

### Batch Processing

Process multiple invitations efficiently:

```javascript
exports.processBatchInvitations = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async () => {
    const pending = await admin.firestore()
      .collection('friendInvitations')
      .where('emailSent', '==', false)
      .limit(100)
      .get();

    // Process in batches of 10
    const chunks = chunkArray(pending.docs, 10);
    for (const chunk of chunks) {
      await Promise.all(chunk.map(sendEmail));
    }
  });
```

## Next Steps

1. **Deploy functions:** `firebase deploy --only functions`
2. **Test email sending** with real invitation
3. **Set up monitoring** in Firebase Console
4. **Configure alerts** for function failures
5. **Test push notifications** on device

## Resources

- [Firebase Functions Docs](https://firebase.google.com/docs/functions)
- [SendGrid Setup Guide](https://sendgrid.com/docs/)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Nodemailer Documentation](https://nodemailer.com/)

---

**Functions are ready to deploy!** 🚀

Run `firebase deploy --only functions` to go live.
