# Firebase Real-Time Messaging Setup Guide

## What's Been Implemented

### 🔥 Firebase Firestore Integration
The app now uses Firebase Firestore for real-time group messaging. Messages are synchronized instantly across all users in real-time.

### ✅ Features Implemented

1. **Real-Time Messaging**
   - Messages sync instantly across all devices
   - No more mock data - all messages are stored in Firebase
   - Users can see each other's messages live

2. **@Mentions System**
   - Type `@` to see a dropdown of group members
   - Select a member to mention them
   - Mentioned names are highlighted in messages
   - Admin members show a verified badge

3. **Reply to Messages**
   - Long-press any message to reply
   - Reply preview shows above input field
   - Replied messages show the original message context

4. **Admin Privileges**
   - Group admins have a verified badge
   - Admins can manage group settings
   - Admins can add/remove members
   - Admins can promote/demote other members

5. **Auto-Scroll**
   - New messages automatically scroll to bottom
   - Floating action button appears when scrolled up
   - Tap button to jump to latest messages

## Firebase Structure

### Collections

```
groups/
  {groupId}/
    - name: string
    - description: string
    - memberIds: array[string]
    - adminIds: array[string]
    - createdAt: timestamp
    - updatedAt: timestamp
    
    messages/
      {messageId}/
        - senderId: string
        - senderName: string
        - text: string
        - timestamp: timestamp
        - attachments: array[string] (optional)
        - replyToMessageId: string (optional)
        - replyToText: string (optional)
        - replyToSenderName: string (optional)
        - mentionedUserIds: array[string] (optional)
        - mentionedUserNames: array[string] (optional)

users/
  {userId}/
    - name: string
    - email: string
    - createdAt: timestamp
```

## Setup Instructions

### 1. Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Enable **Cloud Firestore** from the Build menu
4. Start in **production mode** or **test mode** (test mode for development)

### 2. Firestore Security Rules (Development)

For development/testing, use these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all reads and writes (DEVELOPMENT ONLY)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### 3. Firestore Security Rules (Production)

For production, use secure rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Group access
    match /groups/{groupId} {
      allow read: if request.auth != null && 
                     request.auth.uid in resource.data.memberIds;
      allow write: if request.auth != null && 
                      request.auth.uid in resource.data.adminIds;
      
      // Messages in groups
      match /messages/{messageId} {
        allow read: if request.auth != null && 
                       request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.memberIds;
        allow create: if request.auth != null && 
                         request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.memberIds &&
                         request.resource.data.senderId == request.auth.uid;
        allow update, delete: if request.auth != null && 
                                 request.auth.uid == resource.data.senderId;
      }
    }
  }
}
```

### 4. Firebase Indexes

Create composite indexes for efficient querying:

1. Go to Firebase Console > Firestore > Indexes
2. Create index:
   - Collection: `groups/{groupId}/messages`
   - Fields: `timestamp` (Ascending)
   - Query scope: Collection

## How It Works

### User Authentication

The app uses Firebase Authentication. Current user info comes from:
- `FirebaseAuth.instance.currentUser?.uid` - User ID
- `FirebaseAuth.instance.currentUser?.displayName` - User name

For testing without auth, it falls back to:
- User ID: `'guest_user'`
- User name: `'Guest User'`

### Sending Messages

When you send a message:
1. Message is written to `groups/{groupId}/messages` collection
2. Firebase timestamp is added automatically
3. All connected clients receive the update instantly via StreamBuilder
4. Messages appear for all users in real-time

### @Mentions

1. Type `@` in the input field
2. Dropdown shows group members
3. Select a member to insert `@MemberName`
4. On send, the app extracts mentioned names
5. Matched names are stored in `mentionedUserIds` and `mentionedUserNames`
6. Messages highlight mentions in blue

### Replies

1. Long-press any message
2. Tap "Reply"
3. Reply preview appears above input
4. Message is sent with `replyToMessageId`, `replyToText`, `replyToSenderName`
5. Replied messages show original message above

## Testing

### Test on Multiple Devices

1. Build the APK:
   ```bash
   flutter build apk --release
   ```

2. Install on multiple Android devices:
   - Device 1: User A
   - Device 2: User B

3. Both users join the same group

4. Send messages from Device 1 - they appear instantly on Device 2

5. Test @mentions by typing `@` and selecting the other user

6. Test replies by long-pressing a message

### Check Firebase Console

1. Go to Firebase Console > Firestore
2. Browse to `groups/{groupId}/messages`
3. You'll see all messages appear in real-time as users send them

## Troubleshooting

### Messages not syncing?

1. Check Firebase Console logs for errors
2. Verify internet connection on devices
3. Check Firestore security rules allow read/write
4. Ensure Firebase app is properly initialized in `main.dart`

### "Permission denied" errors?

1. Update Firestore security rules to allow access
2. For testing, use test mode rules (allow all)
3. For production, ensure user is authenticated

### Mentions not working?

1. Check that members exist in `_groupMembers` list
2. Verify `_loadGroupData()` is called in `initState()`
3. Check Firebase `groups/{groupId}` document has `memberIds` array

### Images not showing?

Currently, images are stored as local paths. To fix:
1. Implement Firebase Storage for images
2. Upload images before sending message
3. Store download URLs in `attachments` array

## Next Steps

### Recommended Enhancements

1. **Firebase Storage for Images**
   - Upload images to Firebase Storage
   - Store download URLs in messages
   - Display images from URLs

2. **Push Notifications**
   - Send notification when user is mentioned
   - Notify on new messages when app is closed
   - Use Firebase Cloud Messaging (FCM)

3. **Read Receipts**
   - Track which users have read each message
   - Show read indicators

4. **Typing Indicators**
   - Show when other users are typing
   - Update in real-time

5. **Message Reactions**
   - Add emoji reactions to messages
   - Show reaction counts

## Code References

- **Firebase Service**: `lib/core/services/firebase_messaging_service.dart`
- **Group Chat Screen**: `lib/features/community/group_chat_screen.dart`
- **Message Model**: `lib/data/models/community_model.dart`
- **Dependencies**: `pubspec.yaml` (cloud_firestore: ^6.1.2)

---

**Note**: This implementation assumes Firebase is already initialized in your app. If not, add Firebase initialization in `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```
