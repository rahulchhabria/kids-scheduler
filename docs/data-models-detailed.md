# Kids Scheduler - Detailed Data Models

## Database: Firestore

### Collections Structure

```
kids-scheduler (Firebase Project)
├── users/
├── children/
├── groups/
├── playdates/
├── notifications/
└── inviteCodes/
```

---

## 1. Users Collection

**Path**: `/users/{userId}`

Stores parent account information.

### Schema

```typescript
interface User {
  id: string;                    // Firebase Auth UID
  email: string;                 // From Google OAuth
  parentName: string;            // Display name
  linkedChildren: string[];      // Array of child document IDs
  phoneNumber?: string;          // Optional for parent contact
  notificationPreferences: {
    email: boolean;
    push: boolean;
    sms: boolean;
  };
  createdAt: Timestamp;
  updatedAt: Timestamp;
  lastLoginAt: Timestamp;
}
```

### Example Document

```json
{
  "id": "user_abc123",
  "email": "jane.smith@example.com",
  "parentName": "Jane Smith",
  "linkedChildren": ["child_xyz789", "child_def456"],
  "phoneNumber": "+15551234567",
  "notificationPreferences": {
    "email": true,
    "push": true,
    "sms": false
  },
  "createdAt": "2024-10-15T10:00:00Z",
  "updatedAt": "2024-10-15T10:00:00Z",
  "lastLoginAt": "2024-10-15T10:00:00Z"
}
```

### Indexes

- `email` (for lookups)
- `linkedChildren` (array-contains)

---

## 2. Children Collection

**Path**: `/children/{childId}`

Stores child profile information.

### Schema

```typescript
interface Child {
  id: string;
  parentId: string;              // Reference to users collection
  childName: string;
  age: number;                   // 4-17
  dateOfBirth?: Date;            // Optional for more precise age
  avatarUrl?: string;            // Cloud Storage URL if photo uploaded
  avatarEmoji: string;           // Default emoji avatar
  groups: string[];              // Array of group IDs child belongs to
  preferences: {
    favoriteActivities: string[];
    favoritePlaces: Location[];
  };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

interface Location {
  name: string;
  address?: string;
  latitude?: number;
  longitude?: number;
}
```

### Example Document

```json
{
  "id": "child_xyz789",
  "parentId": "user_abc123",
  "childName": "Alex",
  "age": 8,
  "dateOfBirth": "2016-05-12",
  "avatarUrl": null,
  "avatarEmoji": "🦁",
  "groups": ["group_soccer123", "group_school456"],
  "preferences": {
    "favoriteActivities": ["park", "soccer", "art"],
    "favoritePlaces": [
      {
        "name": "Central Park",
        "address": "123 Park Ave",
        "latitude": 40.7829,
        "longitude": -73.9654
      }
    ]
  },
  "createdAt": "2024-10-15T10:05:00Z",
  "updatedAt": "2024-10-15T10:05:00Z"
}
```

### Indexes

- `parentId` (for queries)
- `groups` (array-contains for membership queries)

---

## 3. Groups Collection

**Path**: `/groups/{groupId}`

Stores friend group information.

### Schema

```typescript
interface Group {
  id: string;
  groupName: string;
  groupDescription?: string;
  groupEmoji: string;            // Visual identifier
  createdBy: string;             // Parent user ID
  adminIds: string[];            // Array of parent IDs with admin access
  members: GroupMember[];        // Array of children in group
  inviteCode: string;            // Unique 8-character code
  settings: GroupSettings;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

interface GroupMember {
  childId: string;
  joinedAt: Timestamp;
  invitedBy: string;             // Child or parent ID who invited
}

interface GroupSettings {
  requireParentApproval: boolean;
  allowMembersToInvite: boolean;
  maxMembers: number;            // Default 20
  visibility: 'private' | 'inviteOnly';
  ageRange?: {
    min: number;
    max: number;
  };
}
```

### Example Document

```json
{
  "id": "group_soccer123",
  "groupName": "Soccer Team",
  "groupDescription": "Weekend soccer practice and games",
  "groupEmoji": "⚽",
  "createdBy": "user_abc123",
  "adminIds": ["user_abc123", "user_parent2"],
  "members": [
    {
      "childId": "child_xyz789",
      "joinedAt": "2024-10-01T10:00:00Z",
      "invitedBy": "user_abc123"
    },
    {
      "childId": "child_def456",
      "joinedAt": "2024-10-02T14:30:00Z",
      "invitedBy": "child_xyz789"
    }
  ],
  "inviteCode": "SOCCER24",
  "settings": {
    "requireParentApproval": true,
    "allowMembersToInvite": true,
    "maxMembers": 20,
    "visibility": "inviteOnly",
    "ageRange": {
      "min": 7,
      "max": 10
    }
  },
  "createdAt": "2024-10-01T10:00:00Z",
  "updatedAt": "2024-10-15T09:00:00Z"
}
```

### Indexes

- `inviteCode` (unique)
- `members.childId` (array-contains)
- `createdBy` (for creator queries)

---

## 4. Playdates Collection

**Path**: `/playdates/{playdateId}`

Stores playdate event information.

### Schema

```typescript
interface Playdate {
  id: string;
  groupId: string;
  createdBy: string;             // Child ID who created it
  createdByParentId: string;     // Parent ID for contact
  title: string;
  description?: string;
  activityType: ActivityType;
  startTime: Timestamp;
  endTime: Timestamp;
  location: PlaydateLocation;
  invitedChildren: string[];     // Array of child IDs
  rsvps: RSVP[];
  status: PlaydateStatus;
  isRecurring: boolean;
  recurrenceRule?: RecurrenceRule;
  parentNotes?: string;          // Notes visible only to parents
  createdAt: Timestamp;
  updatedAt: Timestamp;
  cancelledAt?: Timestamp;
  cancellationReason?: string;
}

enum ActivityType {
  PARK = 'park',
  SPORTS = 'sports',
  ART = 'art',
  GAMING = 'gaming',
  MOVIE = 'movie',
  STUDY = 'study',
  BIRTHDAY = 'birthday',
  OTHER = 'other'
}

interface PlaydateLocation {
  name: string;
  address?: string;
  latitude?: number;
  longitude?: number;
  notes?: string;                // e.g., "Meet at the big oak tree"
}

interface RSVP {
  childId: string;
  parentId: string;
  status: RSVPStatus;
  parentApproved: boolean;
  respondedAt?: Timestamp;
  approvedAt?: Timestamp;
  parentNotes?: string;
}

enum RSVPStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  DECLINED = 'declined',
  MAYBE = 'maybe'
}

enum PlaydateStatus {
  PENDING = 'pending',           // Waiting for RSVPs
  CONFIRMED = 'confirmed',       // Enough confirmations
  CANCELLED = 'cancelled',
  COMPLETED = 'completed'        // Past date
}

interface RecurrenceRule {
  frequency: 'daily' | 'weekly' | 'monthly';
  interval: number;              // e.g., every 2 weeks
  daysOfWeek?: number[];         // 0-6 (Sun-Sat)
  endDate?: Timestamp;
  occurrences?: number;          // Max number of occurrences
}
```

### Example Document

```json
{
  "id": "playdate_park001",
  "groupId": "group_soccer123",
  "createdBy": "child_xyz789",
  "createdByParentId": "user_abc123",
  "title": "Park Playdate",
  "description": "Let's play soccer at the park!",
  "activityType": "park",
  "startTime": "2024-10-16T15:00:00Z",
  "endTime": "2024-10-16T17:00:00Z",
  "location": {
    "name": "Central Park",
    "address": "123 Park Ave, City, State 12345",
    "latitude": 40.7829,
    "longitude": -73.9654,
    "notes": "Meet at the soccer field entrance"
  },
  "invitedChildren": ["child_xyz789", "child_def456", "child_ghi789"],
  "rsvps": [
    {
      "childId": "child_xyz789",
      "parentId": "user_abc123",
      "status": "accepted",
      "parentApproved": true,
      "respondedAt": "2024-10-15T10:30:00Z",
      "approvedAt": "2024-10-15T10:31:00Z",
      "parentNotes": "I'll drop off and pick up"
    },
    {
      "childId": "child_def456",
      "parentId": "user_parent2",
      "status": "accepted",
      "parentApproved": true,
      "respondedAt": "2024-10-15T11:00:00Z",
      "approvedAt": "2024-10-15T11:05:00Z"
    },
    {
      "childId": "child_ghi789",
      "parentId": "user_parent3",
      "status": "pending",
      "parentApproved": false
    }
  ],
  "status": "confirmed",
  "isRecurring": false,
  "recurrenceRule": null,
  "parentNotes": null,
  "createdAt": "2024-10-15T10:00:00Z",
  "updatedAt": "2024-10-15T11:05:00Z"
}
```

### Indexes

- `groupId` (for group queries)
- `invitedChildren` (array-contains)
- `startTime` (for calendar queries)
- Composite: `groupId` + `startTime` (for group calendar)
- Composite: `status` + `startTime` (for active playdates)

---

## 5. Notifications Collection

**Path**: `/notifications/{notificationId}`

Stores in-app notifications and push notification logs.

### Schema

```typescript
interface Notification {
  id: string;
  recipientId: string;           // User or child ID
  recipientType: 'parent' | 'child';
  type: NotificationType;
  title: string;
  body: string;
  data: NotificationData;        // Type-specific data
  read: boolean;
  actionTaken?: string;          // e.g., "approved", "declined"
  createdAt: Timestamp;
  readAt?: Timestamp;
  expiresAt?: Timestamp;
}

enum NotificationType {
  PLAYDATE_INVITE = 'playdate_invite',
  PLAYDATE_APPROVED = 'playdate_approved',
  PLAYDATE_DECLINED = 'playdate_declined',
  PLAYDATE_CANCELLED = 'playdate_cancelled',
  PLAYDATE_UPDATED = 'playdate_updated',
  PLAYDATE_REMINDER = 'playdate_reminder',
  GROUP_INVITE = 'group_invite',
  RSVP_RESPONSE = 'rsvp_response',
  APPROVAL_REQUEST = 'approval_request'
}

interface NotificationData {
  playdateId?: string;
  groupId?: string;
  childId?: string;
  actionUrl?: string;            // Deep link to relevant screen
}
```

### Example Document

```json
{
  "id": "notif_001",
  "recipientId": "child_xyz789",
  "recipientType": "child",
  "type": "playdate_invite",
  "title": "New Playdate Invite! 🎉",
  "body": "Sam invited you to Soccer Practice on Friday at 4:00 PM",
  "data": {
    "playdateId": "playdate_park001",
    "groupId": "group_soccer123",
    "childId": "child_def456",
    "actionUrl": "kidsscheduler://playdate/playdate_park001"
  },
  "read": false,
  "createdAt": "2024-10-15T10:00:00Z",
  "expiresAt": "2024-10-16T15:00:00Z"
}
```

### Indexes

- `recipientId` + `createdAt` (for timeline)
- `recipientId` + `read` (for unread count)

---

## 6. Invite Codes Collection

**Path**: `/inviteCodes/{code}`

Stores group invite codes for validation and tracking.

### Schema

```typescript
interface InviteCode {
  code: string;                  // 8-character unique code
  groupId: string;
  createdBy: string;             // User ID
  expiresAt?: Timestamp;
  maxUses?: number;
  currentUses: number;
  active: boolean;
  createdAt: Timestamp;
}
```

### Example Document

```json
{
  "code": "SOCCER24",
  "groupId": "group_soccer123",
  "createdBy": "user_abc123",
  "expiresAt": null,
  "maxUses": null,
  "currentUses": 8,
  "active": true,
  "createdAt": "2024-10-01T10:00:00Z"
}
```

---

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isParentOfChild(childId) {
      return isAuthenticated() &&
        get(/databases/$(database)/documents/children/$(childId)).data.parentId == request.auth.uid;
    }

    function isGroupMember(groupId, childId) {
      let group = get(/databases/$(database)/documents/groups/$(groupId)).data;
      return childId in group.members;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
    }

    // Children collection
    match /children/{childId} {
      allow read: if isAuthenticated() && (
        isParentOfChild(childId) ||
        exists(/databases/$(database)/documents/groups/$(request.resource.data.groups[0]))
      );
      allow create: if isAuthenticated();
      allow update, delete: if isParentOfChild(childId);
    }

    // Groups collection
    match /groups/{groupId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
        request.auth.uid in resource.data.adminIds;
      allow delete: if isAuthenticated() &&
        request.auth.uid == resource.data.createdBy;
    }

    // Playdates collection
    match /playdates/{playdateId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && (
        request.auth.uid == resource.data.createdByParentId ||
        isParentOfChild(resource.data.createdBy)
      );
      allow delete: if isAuthenticated() &&
        request.auth.uid == resource.data.createdByParentId;
    }

    // Notifications collection
    match /notifications/{notifId} {
      allow read: if isAuthenticated() &&
        request.auth.uid == resource.data.recipientId;
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
        request.auth.uid == resource.data.recipientId;
    }

    // Invite codes collection
    match /inviteCodes/{code} {
      allow read: if isAuthenticated();
      allow write: if false; // Only via Cloud Functions
    }
  }
}
```

---

## Queries Examples

### Get all children for a parent

```swift
db.collection("children")
  .whereField("parentId", isEqualTo: currentUserId)
  .getDocuments()
```

### Get all playdates for a child

```swift
db.collection("playdates")
  .whereField("invitedChildren", arrayContains: childId)
  .whereField("startTime", isGreaterThan: Date())
  .order(by: "startTime")
  .getDocuments()
```

### Get all pending approval requests for a parent

```swift
db.collection("playdates")
  .whereField("rsvps", arrayContains: ["parentId": currentUserId, "parentApproved": false])
  .whereField("status", isEqualTo: "pending")
  .getDocuments()
```

### Get group members

```swift
let group = try await db.collection("groups").document(groupId).getDocument()
let memberIds = group.data()?["members"] as? [String] ?? []

// Then fetch children
db.collection("children")
  .whereField(FieldPath.documentID(), in: memberIds)
  .getDocuments()
```

### Real-time listener for new invites

```swift
db.collection("notifications")
  .whereField("recipientId", isEqualTo: childId)
  .whereField("type", isEqualTo: "playdate_invite")
  .whereField("read", isEqualTo: false)
  .addSnapshotListener { snapshot, error in
    // Handle new notifications
  }
```

---

## Cloud Functions (Backend Logic)

### Suggested Cloud Functions

1. **onPlaydateCreated** - Send notifications to invited children
2. **onRSVPUpdated** - Notify creator of responses
3. **onParentApproval** - Update playdate status, notify child
4. **checkPlaydateStatus** - Auto-update status based on RSVPs
5. **sendPlaydateReminders** - 24-hour reminder notifications
6. **cleanupExpiredNotifications** - Delete old notifications
7. **generateInviteCode** - Create unique group codes
8. **validateInviteCode** - Check code validity before use

---

## Storage Structure (Firebase Storage)

```
/avatars/
  /{childId}/
    /profile.jpg

/group-images/
  /{groupId}/
    /cover.jpg

/playdate-photos/
  /{playdateId}/
    /{photoId}.jpg
```

---

This detailed data model provides a robust foundation for the Kids Scheduler app!
