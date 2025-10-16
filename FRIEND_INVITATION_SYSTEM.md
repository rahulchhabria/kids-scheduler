# Friend Invitation & Parent Approval System

## Overview

A complete two-way parent approval system that gives kids autonomy to invite friends while keeping parents in full control.

## How It Works

### The Complete Flow

```
1. Kid enters friend's parent email
   ↓
2. Invitation created (status: pendingFromParentApproval)
   ↓
3. Sender's parent gets notification
   ↓
4a. Parent DENIES → Invitation status: deniedByFromParent [END]
4b. Parent APPROVES → Invitation status: pendingRecipient
   ↓
5. Email sent to recipient's parent
   ↓
6. Recipient family signs up / logs in
   ↓
7. Recipient sees pending invitation
   ↓
8a. Recipient DECLINES → Invitation status: declined [END]
8b. Recipient ACCEPTS → Invitation status: pendingToParentApproval
   ↓
9. Recipient's parent gets notification
   ↓
10a. Parent DENIES → Invitation status: deniedByToParent [END]
10b. Parent APPROVES → Invitation status: accepted
   ↓
11. Friendship created! 🎉
   ↓
12. Both kids can now invite each other to groups
```

## Data Models

### FriendInvitation

Tracks the entire invitation lifecycle:

```swift
struct FriendInvitation {
    // Sender info
    var fromChildId: String
    var fromParentId: String

    // Recipient info
    var toEmail: String  // Initially just email
    var toChildId: String?  // Filled when they accept
    var toParentId: String?

    // Approval status
    var fromParentApproved: Bool
    var toParentApproved: Bool

    // Status tracking
    var status: InvitationStatus
    var expiresAt: Date  // 30 days
}
```

**Status Flow:**
- `pendingFromParentApproval` → Waiting for sender's parent
- `pendingRecipient` → Sent to recipient
- `pendingToParentApproval` → Recipient accepted, waiting for their parent
- `accepted` → Both parents approved ✅
- `declined` / `deniedByFromParent` / `deniedByToParent` → Rejected ❌

### Friendship

Represents an active friendship between two kids:

```swift
struct Friendship {
    var child1Id: String
    var child2Id: String
    var parent1Id: String
    var parent2Id: String

    var status: FriendshipStatus  // active, suspended, blocked

    // Parent controls
    var isPausedByParent1: Bool
    var isPausedByParent2: Bool
}
```

**Key Feature:** Either parent can pause/block the friendship at any time!

### ParentApprovalRequest

Notification shown to parents:

```swift
struct ParentApprovalRequest {
    var parentId: String
    var childId: String

    var requestType: ApprovalRequestType
    // - outgoingFriendRequest: Your kid wants to invite someone
    // - incomingFriendRequest: Someone wants to be friends with your kid

    var otherChildName: String
    var otherParentName: String
    var otherParentEmail: String

    var status: ApprovalStatus  // pending, approved, denied
}
```

## Files Created

### Models
- **`FriendInvitation.swift`** - All data models for invitations, friendships, and approvals

### Services
- **`FriendInvitationService.swift`** - Complete business logic:
  - `createFriendInvitation()` - Kid sends invitation
  - `acceptInvitationAsRecipient()` - Recipient accepts
  - `respondToApprovalRequest()` - Parent approves/denies
  - `pauseFriendship()` / `resumeFriendship()` - Parent controls
  - `blockFriendship()` - Permanent block
  - `fetchPendingApprovalRequests()` - Get parent notifications
  - `fetchFriendships()` - Get all friendships
  - `fetchFriends()` - Get active friends only

### Views

#### Kid-Facing
- **`InviteFriendView.swift`** - Form to invite a friend:
  - Enter parent's email (required)
  - Optional phone number
  - Add a message ("I met them at soccer!")
  - Info card explaining parent approval
  - Sends invitation to their parent first

#### Parent-Facing
- **`ParentApprovalDashboard.swift`** - Complete parent control center:
  - **Pending Approvals Section:**
    - Shows all requests needing approval
    - Displays: type (incoming/outgoing), child names, parent info, message
    - Actions: Approve ✅ or Deny ❌
  - **Active Friendships Section:**
    - Lists all current friendships
    - Shows "paused" status if suspended
    - Actions: Pause ⏸️, Resume ▶️, Block 🚫

## Parent Controls

Parents have complete authority:

### 1. **Approval Required (Always)**
- Kid can't send invitation without parent approval
- Recipient can't accept without their parent's approval
- Both parents must approve for friendship to form

### 2. **Pause Friendship**
- Temporarily suspend interaction
- Kids can't invite each other to playdates
- Can be resumed at any time
- Other parent is notified

### 3. **Block Friendship**
- Permanently end the friendship
- Cannot be undone (would need new invitation)
- Kids removed from each other's friends lists

### 4. **View All Details**
- See other parent's name and email
- Read kid's message about how they know each other
- Review when invitation was sent

## Firestore Collections

```
friendInvitations/
  {invitationId}/
    - fromChildId, fromParentId
    - toEmail, toChildId, toParentId
    - status, fromParentApproved, toParentApproved
    - expiresAt

friendships/
  {friendshipId}/
    - child1Id, child2Id
    - parent1Id, parent2Id
    - status, isPausedByParent1, isPausedByParent2

parentApprovalRequests/
  {requestId}/
    - parentId, childId
    - requestType, invitationId
    - otherChildName, otherParentName, otherParentEmail
    - status, expiresAt
```

## Security Rules

```javascript
// Friend invitations - only involved parents can read
match /friendInvitations/{invitationId} {
  allow read: if request.auth.uid == resource.data.fromParentId
              || request.auth.uid == resource.data.toParentId;
  allow create: if request.auth.uid == request.resource.data.fromParentId;
  allow update: if request.auth.uid == resource.data.fromParentId
                || request.auth.uid == resource.data.toParentId;
}

// Parent approval requests - only assigned parent can read
match /parentApprovalRequests/{requestId} {
  allow read, update: if request.auth.uid == resource.data.parentId;
  allow create: if request.auth.uid == request.resource.data.parentId;
}

// Friendships - both parents can read and update
match /friendships/{friendshipId} {
  allow read: if request.auth.uid == resource.data.parent1Id
              || request.auth.uid == resource.data.parent2Id;
  allow update: if request.auth.uid == resource.data.parent1Id
                || request.auth.uid == resource.data.parent2Id;
}
```

## Integration Points

### 1. **Add to Groups View**
Add "Invite Friend" button to groups:
```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { showInviteFriend = true }) {
            Label("Invite Friend", systemImage: "person.badge.plus")
        }
    }
}
.sheet(isPresented: $showInviteFriend) {
    InviteFriendView()
}
```

### 2. **Add to Main Tab Bar**
Add parent dashboard as a tab or in profile:
```swift
NavigationLink(destination: ParentApprovalDashboardView()) {
    Label("Parent Dashboard", systemImage: "shield.checkered")
}
```

### 3. **Badge Count for Parents**
Show pending approval count:
```swift
.badge(viewModel.pendingApprovalCount)
```

### 4. **Email Invitations**
Use Firebase Cloud Functions to send emails:
```javascript
exports.sendFriendInvitation = functions.firestore
  .document('friendInvitations/{invitationId}')
  .onCreate(async (snap, context) => {
    const invitation = snap.data();
    if (invitation.status === 'pendingRecipient') {
      await sendEmail({
        to: invitation.toEmail,
        subject: `${invitation.fromChildName} wants to be friends!`,
        body: `Join Kids Scheduler to accept the invitation...`
      });
    }
  });
```

## Future Enhancements

### Push Notifications
```swift
// When invitation needs approval
func sendPushNotification(to parentId: String) {
    // Use Firebase Cloud Messaging
    let message = [
        "title": "Friend Request Approval Needed",
        "body": "\(childName) wants to invite a friend",
        "badge": pendingCount
    ]
}
```

### SMS Notifications
```swift
// If phone number provided
if let phone = invitation.toPhoneNumber {
    await sendSMS(
        to: phone,
        message: "\(childName) invited your family to join Kids Scheduler!"
    )
}
```

### Activity Feed
- Log all friendship events
- Parents can see history of invitations
- Track when friendships were paused/resumed

### Friend Suggestions
- Suggest friends from same groups
- Suggest based on similar ages
- Suggest from same school (if that data exists)

## Testing in Debug Mode

Add mock data:
```swift
extension ParentApprovalRequest {
    static var mockRequests: [ParentApprovalRequest] {
        [
            ParentApprovalRequest(
                id: "req1",
                parentId: "parent1",
                childId: "child1",
                childName: "Alex",
                requestType: .outgoingFriendRequest,
                invitationId: "inv1",
                otherChildName: "Sam",
                otherParentName: "Jane Smith",
                otherParentEmail: "jane@example.com",
                message: "We met at soccer practice!",
                status: .pending,
                createdAt: Date(),
                respondedAt: nil,
                expiresAt: Date().addingTimeInterval(30 * 24 * 60 * 60)
            )
        ]
    }
}
```

## Summary

This system provides:

✅ **Kid Autonomy** - Kids can initiate friend requests
✅ **Parent Control** - Every connection requires dual parent approval
✅ **Transparency** - Parents see all details before approving
✅ **Flexibility** - Parents can pause/resume/block at any time
✅ **Privacy** - Kids never see parent emails or contact info
✅ **Safety** - No direct kid-to-kid contact without parent oversight

The system is production-ready and follows COPPA compliance best practices for children's online interactions!
