# Kids Scheduler - UI/UX Wireframes

## Design Principles
- **Large touch targets** (minimum 60x60 points)
- **Bright, friendly colors**
- **Icon-based navigation** with text labels
- **Minimal text input** (prefer pickers and presets)
- **Visual feedback** for all interactions
- **Kid-friendly language** (simple, encouraging)

---

## 1. Welcome Screen (Parent Login)

```
┌─────────────────────────────────────────────┐
│                                             │
│                                             │
│              🗓️                             │
│                                             │
│         Kids Scheduler                      │
│                                             │
│      Plan playdates with friends!           │
│                                             │
│                                             │
│                                             │
│    ┌──────────────────────────────────┐    │
│    │  👤 Sign in with Google          │    │
│    └──────────────────────────────────┘    │
│                                             │
│    Parents sign in to create kid profiles  │
│                                             │
└─────────────────────────────────────────────┘
```

**Features:**
- Large, centered logo
- Single sign-in button
- Clear explanation for parents

---

## 2. Child Profile Setup

```
┌─────────────────────────────────────────────┐
│  ← Back                          Skip       │
├─────────────────────────────────────────────┤
│                                             │
│   Let's create a profile for your child     │
│                                             │
│           Choose an avatar:                 │
│                                             │
│    ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │
│    │ 🦁  │ │ 🐯  │ │ 🐻  │ │ 🐼  │        │
│    └─────┘ └─────┘ └─────┘ └─────┘        │
│    ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │
│    │ 🐨  │ │ 🐸  │ │ 🦊  │ │ 🐙  │        │
│    └─────┘ └─────┘ └─────┘ └─────┘        │
│                                             │
│           Child's name:                     │
│    ┌──────────────────────────────────┐    │
│    │  Alex                            │    │
│    └──────────────────────────────────┘    │
│                                             │
│           Age:                              │
│           ┌────────┐                        │
│           │ 8 years│  [Wheel Picker]        │
│           └────────┘                        │
│                                             │
│              [Create Profile]               │
│                                             │
└─────────────────────────────────────────────┘
```

**Features:**
- Emoji avatars (no photo upload needed)
- Large text input fields
- Age picker (4-17)
- Skip option for later

---

## 3. Main Tab Navigation

```
┌─────────────────────────────────────────────┐
│                                             │
│                                             │
│            [Main Content Area]              │
│                                             │
│                                             │
│                                             │
│                                             │
├─────────────────────────────────────────────┤
│  📅      👥       ➕       🔔       👤     │
│Calendar  Groups  Create  Invites  Profile   │
└─────────────────────────────────────────────┘
```

**Features:**
- 5 main tabs with icons
- Large tab icons (SF Symbols)
- Clear labels

---

## 4. Calendar View (Week View for Kids)

```
┌─────────────────────────────────────────────┐
│  📅 My Calendar            [Month View] 👤  │
├─────────────────────────────────────────────┤
│                                             │
│    ← October 2024 →                         │
│                                             │
│  Mon 14  Tue 15  Wed 16  Thu 17  Fri 18    │
│ ┌──────┐┌──────┐┌──────┐┌──────┐┌──────┐  │
│ │      ││      ││      ││      ││      │  │
│ │      ││  ⚽  ││      ││  🎨  ││      │  │
│ │      ││ 3PM  ││      ││ 4PM  ││      │  │
│ └──────┘└──────┘└──────┘└──────┘└──────┘  │
│                                             │
│  Sat 19  Sun 20                             │
│ ┌──────┐┌──────┐                            │
│ │  🏞️  ││      │                            │
│ │ 10AM ││      │                            │
│ └──────┘└──────┘                            │
│                                             │
│              Today's Playdates              │
│    ┌──────────────────────────────────┐    │
│    │ ⚽ Soccer Practice                │    │
│    │ 3:00 PM - 5:00 PM                │    │
│    │ 🦁 Alex, 🐯 Sam, 🐻 Jordan       │    │
│    │ Central Park                     │    │
│    └──────────────────────────────────┘    │
│                                             │
└─────────────────────────────────────────────┘
```

**Features:**
- Week view (simplified for kids)
- Emoji icons for event types
- Friend avatars shown on events
- Tap day to see all events
- Color coding by group

---

## 5. Groups View

```
┌─────────────────────────────────────────────┐
│  👥 My Groups                    [+ New]    │
├─────────────────────────────────────────────┤
│                                             │
│    ┌──────────────────────────────────┐    │
│    │ ⚽ Soccer Team                   │    │
│    │ 8 friends                        │    │
│    │ 🦁 🐯 🐻 🐼 🐨 🐸 🦊 🐙          │    │
│    └──────────────────────────────────┘    │
│                                             │
│    ┌──────────────────────────────────┐    │
│    │ 🏫 Mrs. Johnson's Class          │    │
│    │ 12 friends                       │    │
│    │ 🦁 🐯 🐻 🐼 🐨 🐸 +6             │    │
│    └──────────────────────────────────┘    │
│                                             │
│    ┌──────────────────────────────────┐    │
│    │ 🏡 Neighborhood Kids             │    │
│    │ 5 friends                        │    │
│    │ 🦁 🐯 🐻 🐼 🐨                   │    │
│    └──────────────────────────────────┘    │
│                                             │
│                                             │
│         [Join Group with Code]              │
│                                             │
└─────────────────────────────────────────────┘
```

**Features:**
- Card-based group list
- Group emoji/icon
- Member count with avatars
- Quick join with code
- Tap to see group calendar

---

## 6. Create Playdate

```
┌─────────────────────────────────────────────┐
│  ← Back          Create Playdate     [?]    │
├─────────────────────────────────────────────┤
│                                             │
│    What do you want to do?                  │
│    ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │
│    │ 🏞️  │ │ ⚽  │ │ 🎨  │ │ 🎮  │        │
│    │Park │ │Sport│ │Craft│ │Game│        │
│    └─────┘ └─────┘ └─────┘ └─────┘        │
│    ┌─────┐ ┌─────┐                          │
│    │ 🎬  │ │ ➕  │                          │
│    │Movie│ │Other│                          │
│    └─────┘ └─────┘                          │
│                                             │
│    Title:                                   │
│    ┌──────────────────────────────────┐    │
│    │ Park Playdate                    │    │
│    └──────────────────────────────────┘    │
│                                             │
│    When?                                    │
│    ┌──────────────┐  ┌──────────────┐      │
│    │ Oct 16, 2024 │  │ 3:00 PM      │      │
│    └──────────────┘  └──────────────┘      │
│                                             │
│    How long?                                │
│    [1 hour] [2 hours] [3 hours] [Custom]   │
│                                             │
│    Where?                                   │
│    ┌──────────────────────────────────┐    │
│    │ 📍 Central Park                  │    │
│    └──────────────────────────────────┘    │
│                                             │
│    Invite from:  [Soccer Team ▾]           │
│                                             │
│    Who to invite?                           │
│    ┌────┐ ┌────┐ ┌────┐ ┌────┐            │
│    │ 🐯 │ │ 🐻 │ │ 🐼 │ │ 🐨 │            │
│    │Sam │ │Joe │ │Mia │ │Zoe │            │
│    │ ✓  │ │ ✓  │ │    │ │    │            │
│    └────┘ └────┘ └────┘ └────┘            │
│                                             │
│         [Send Invites]                      │
│                                             │
└─────────────────────────────────────────────┘
```

**Features:**
- Activity templates with emojis
- Date/time pickers
- Duration presets
- Location picker (saved favorites)
- Visual friend selector
- Large send button

---

## 7. Invites/Notifications View

```
┌─────────────────────────────────────────────┐
│  🔔 Invites                                  │
├─────────────────────────────────────────────┤
│                                             │
│    NEW                                      │
│    ┌──────────────────────────────────┐    │
│    │ 🏞️ Park Playdate                 │    │
│    │ 🐯 Sam invited you               │    │
│    │ Tomorrow, Oct 16 at 3:00 PM      │    │
│    │ Central Park                     │    │
│    │                                  │    │
│    │  [✓ Yes!]  [? Maybe]  [✗ No]    │    │
│    │                                  │    │
│    │  ⏳ Waiting for parent approval  │    │
│    └──────────────────────────────────┘    │
│                                             │
│    ┌──────────────────────────────────┐    │
│    │ ⚽ Soccer Practice                │    │
│    │ 🐻 Jordan invited you            │    │
│    │ Friday, Oct 18 at 4:00 PM        │    │
│    │ Soccer Field                     │    │
│    │                                  │    │
│    │  [✓ Yes!]  [? Maybe]  [✗ No]    │    │
│    └──────────────────────────────────┘    │
│                                             │
│    CONFIRMED                                │
│    ┌──────────────────────────────────┐    │
│    │ ✅ Art Class                      │    │
│    │ Thursday, Oct 17 at 4:00 PM      │    │
│    │ Community Center                 │    │
│    │ You + 3 friends confirmed        │    │
│    └──────────────────────────────────┘    │
│                                             │
└─────────────────────────────────────────────┘
```

**Features:**
- Clear NEW vs CONFIRMED sections
- Large RSVP buttons with emojis
- Shows parent approval status
- Event details at a glance
- Friend who sent invite

---

## 8. Profile View (Kid Mode)

```
┌─────────────────────────────────────────────┐
│  👤 Profile                     [⚙️ Parent] │
├─────────────────────────────────────────────┤
│                                             │
│              🦁                             │
│                                             │
│            Alex                             │
│          8 years old                        │
│                                             │
│    ┌──────────────────────────────────┐    │
│    │  My Groups                       │    │
│    │  3 groups                     →  │    │
│    └──────────────────────────────────┘    │
│                                             │
│    ┌──────────────────────────────────┐    │
│    │  My Playdates                    │    │
│    │  5 upcoming                   →  │    │
│    └──────────────────────────────────┘    │
│                                             │
│    ┌──────────────────────────────────┐    │
│    │  Favorite Places                 │    │
│    │  Central Park, Soccer Field   →  │    │
│    └──────────────────────────────────┘    │
│                                             │
│    ┌──────────────────────────────────┐    │
│    │  Switch Profile                  │    │
│    │  🐯 Sam (10 years old)        →  │    │
│    └──────────────────────────────────┘    │
│                                             │
│                                             │
└─────────────────────────────────────────────┘
```

**Features:**
- Large avatar display
- Stats and quick links
- Switch between child profiles
- Parent mode button (requires auth)

---

## 9. Parent Dashboard

```
┌─────────────────────────────────────────────┐
│  ← Back to Kid Mode    Parent Dashboard    │
├─────────────────────────────────────────────┤
│                                             │
│    PENDING APPROVAL (3)                     │
│    ┌──────────────────────────────────┐    │
│    │ 🏞️ Park Playdate                 │    │
│    │ Alex wants to go                 │    │
│    │ Tomorrow at 3:00 PM              │    │
│    │ With: Sam, Jordan                │    │
│    │ Location: Central Park           │    │
│    │                                  │    │
│    │  [✓ Approve]     [✗ Decline]    │    │
│    └──────────────────────────────────┘    │
│                                             │
│    UPCOMING PLAYDATES                       │
│    ┌──────────────────────────────────┐    │
│    │ ⚽ Soccer Practice                │    │
│    │ Alex - Friday 4:00 PM            │    │
│    │ Parent contact: Mary J.          │    │
│    │ 📞 (555) 123-4567                │    │
│    └──────────────────────────────────┘    │
│                                             │
│    QUICK ACTIONS                            │
│    ┌─────────────┐ ┌─────────────┐         │
│    │Add Child    │ │Manage Groups│         │
│    └─────────────┘ └─────────────┘         │
│    ┌─────────────┐ ┌─────────────┐         │
│    │Settings     │ │View Calendar│         │
│    └─────────────┘ └─────────────┘         │
│                                             │
└─────────────────────────────────────────────┘
```

**Features:**
- Approval queue front and center
- Parent contact info visible
- Quick action tiles
- Easy switch back to kid mode

---

## 10. Group Detail View

```
┌─────────────────────────────────────────────┐
│  ← Back        Soccer Team          [...]   │
├─────────────────────────────────────────────┤
│                                             │
│              ⚽                              │
│         Soccer Team                         │
│         8 friends                           │
│                                             │
│    [View Calendar]    [Create Playdate]     │
│                                             │
│    MEMBERS                                  │
│    ┌────┐ ┌────┐ ┌────┐ ┌────┐            │
│    │ 🦁 │ │ 🐯 │ │ 🐻 │ │ 🐼 │            │
│    │Alex│ │Sam │ │Joe │ │Mia │            │
│    └────┘ └────┘ └────┘ └────┘            │
│    ┌────┐ ┌────┐ ┌────┐ ┌────┐            │
│    │ 🐨 │ │ 🐸 │ │ 🦊 │ │ 🐙 │            │
│    │Zoe │ │Max │ │Lily│ │Ben │            │
│    └────┘ └────┘ └────┘ └────┘            │
│                                             │
│    UPCOMING PLAYDATES                       │
│    ┌──────────────────────────────────┐    │
│    │ ⚽ Soccer Practice                │    │
│    │ Friday, Oct 18 at 4:00 PM        │    │
│    │ 6 friends coming                 │    │
│    └──────────────────────────────────┘    │
│                                             │
│    GROUP CODE                               │
│    Share this code to invite friends        │
│    ┌──────────────────────────────────┐    │
│    │        SOCCER2024                │    │
│    │          [Share]                 │    │
│    └──────────────────────────────────┘    │
│                                             │
└─────────────────────────────────────────────┘
```

**Features:**
- Group info at top
- Quick actions
- Visual member grid
- Group calendar preview
- Easy invite code sharing

---

## Design System

### Colors
- **Primary**: Blue (#007AFF)
- **Success**: Green (#34C759)
- **Warning**: Orange (#FF9500)
- **Danger**: Red (#FF3B30)
- **Background**: Light gray (#F2F2F7)
- **Cards**: White (#FFFFFF)

### Typography
- **Large Title**: 34pt, Bold
- **Title**: 28pt, Bold
- **Headline**: 17pt, Semibold
- **Body**: 17pt, Regular
- **Caption**: 12pt, Regular

### Spacing
- **Card padding**: 20pt
- **Element spacing**: 16pt
- **Button height**: 60pt
- **Corner radius**: 12pt

### Accessibility
- Support Dynamic Type
- VoiceOver labels on all interactive elements
- High contrast mode support
- Minimum touch target: 44x44pt

---

## User Flows

### Flow 1: First Time User (Parent)
1. Welcome screen → Sign in with Google
2. Child profile setup → Add avatar, name, age
3. Main app → See empty state with prompts
4. Join or create first group
5. View calendar and create first playdate

### Flow 2: Create Playdate
1. Tap "Create" tab
2. Select activity type (template)
3. Set date/time with pickers
4. Choose location from favorites
5. Select group and friends
6. Review and send invites
7. See confirmation

### Flow 3: Respond to Invite
1. See notification badge on Invites tab
2. Open invite card
3. Tap Yes/Maybe/No button
4. See "Waiting for parent approval" message
5. Parent approves in their dashboard
6. Kid sees confirmation

### Flow 4: Parent Approval
1. Parent opens parent dashboard
2. See pending requests
3. Review playdate details
4. Approve or decline
5. Optional: Contact other parents
6. Kid is notified

---

## Responsive Design Notes

### iPad-Specific Features
- Split view support (calendar + detail)
- Drag and drop playdates between days
- Keyboard shortcuts for navigation
- Larger layout for 12.9" display
- Master-detail pattern for lists

### Orientation Support
- Portrait and landscape
- Calendar adjusts columns in landscape
- Side-by-side layouts in landscape

---

This wireframe document provides a comprehensive visual guide for building the Kids Scheduler app!
