/**
 * Firebase Cloud Functions for Kids Scheduler
 *
 * Handles:
 * - Email invitations when friend requests are approved
 * - Push notifications for parent approval requests
 * - Automated invitation expiry
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Configure email transport (using SendGrid as example)
// You can also use Gmail, AWS SES, or any SMTP provider
const mailTransport = nodemailer.createTransport({
  host: 'smtp.sendgrid.net',
  port: 587,
  auth: {
    user: 'apikey',
    pass: functions.config().sendgrid?.key || process.env.SENDGRID_API_KEY
  }
});

// Email templates
const APP_NAME = 'Kids Scheduler';
const APP_URL = 'https://kidsscheduler.app'; // Replace with your actual URL

/**
 * Send email invitation when sender's parent approves
 * Triggered when invitation status changes to 'pendingRecipient'
 */
exports.sendFriendInvitationEmail = functions.firestore
  .document('friendInvitations/{invitationId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only send email when status changes to pendingRecipient
    if (before.status !== 'pendingRecipient' && after.status === 'pendingRecipient') {
      const { fromChildName, fromParentName, fromParentEmail, toEmail, message } = after;

      const emailContent = {
        from: `${APP_NAME} <noreply@kidsscheduler.app>`,
        to: toEmail,
        subject: `${fromChildName} wants to be friends on ${APP_NAME}!`,
        html: `
          <!DOCTYPE html>
          <html>
          <head>
            <style>
              body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
              .container { max-width: 600px; margin: 0 auto; padding: 20px; }
              .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
              .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
              .button { display: inline-block; background: #667eea; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; margin: 20px 0; font-weight: bold; }
              .message-box { background: white; padding: 20px; border-left: 4px solid #667eea; margin: 20px 0; }
              .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>🎉 Friend Request!</h1>
              </div>
              <div class="content">
                <p>Hello!</p>

                <p><strong>${fromChildName}</strong> wants to connect with your child on ${APP_NAME}!</p>

                ${message ? `
                  <div class="message-box">
                    <p><strong>Message from ${fromChildName}:</strong></p>
                    <p><em>"${message}"</em></p>
                  </div>
                ` : ''}

                <p><strong>Parent Contact:</strong></p>
                <ul>
                  <li>Name: ${fromParentName}</li>
                  <li>Email: ${fromParentEmail}</li>
                </ul>

                <p>To accept this invitation, sign up or log in to ${APP_NAME}:</p>

                <center>
                  <a href="${APP_URL}/accept-invitation?code=${context.params.invitationId}" class="button">
                    View Invitation
                  </a>
                </center>

                <p><small>This invitation will expire in 30 days.</small></p>
              </div>

              <div class="footer">
                <p>You're receiving this email because someone wants to connect with your family on ${APP_NAME}.</p>
                <p>© 2025 ${APP_NAME}. All rights reserved.</p>
              </div>
            </div>
          </body>
          </html>
        `
      };

      try {
        await mailTransport.sendMail(emailContent);
        console.log(`✅ Invitation email sent to ${toEmail}`);

        // Log the email send in Firestore
        await admin.firestore()
          .collection('emailLogs')
          .add({
            invitationId: context.params.invitationId,
            to: toEmail,
            type: 'friend_invitation',
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            status: 'sent'
          });
      } catch (error) {
        console.error('❌ Error sending email:', error);

        // Log the error
        await admin.firestore()
          .collection('emailLogs')
          .add({
            invitationId: context.params.invitationId,
            to: toEmail,
            type: 'friend_invitation',
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            status: 'failed',
            error: error.message
          });
      }
    }
  });

/**
 * Send push notification when parent approval is needed
 * Triggered when a new parent approval request is created
 */
exports.sendParentApprovalNotification = functions.firestore
  .document('parentApprovalRequests/{requestId}')
  .onCreate(async (snap, context) => {
    const request = snap.data();
    const { parentId, childName, requestType, otherChildName, message } = request;

    // Get parent's FCM token
    const parentDoc = await admin.firestore()
      .collection('users')
      .doc(parentId)
      .get();

    if (!parentDoc.exists) {
      console.log('Parent not found:', parentId);
      return;
    }

    const fcmToken = parentDoc.data().fcmToken;
    if (!fcmToken) {
      console.log('No FCM token for parent:', parentId);
      return;
    }

    // Build notification message
    let notificationTitle, notificationBody;

    if (requestType === 'outgoingFriendRequest') {
      notificationTitle = 'Approval Needed';
      notificationBody = `${childName} wants to invite ${otherChildName} to be friends`;
    } else {
      notificationTitle = 'New Friend Request';
      notificationBody = `${otherChildName} wants to be friends with ${childName}`;
    }

    const notificationMessage = {
      token: fcmToken,
      notification: {
        title: notificationTitle,
        body: notificationBody,
        imageUrl: 'https://kidsscheduler.app/images/notification-icon.png' // Optional
      },
      data: {
        type: 'parent_approval',
        requestId: context.params.requestId,
        requestType: requestType,
        childName: childName,
        otherChildName: otherChildName
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: 'default'
          }
        }
      }
    };

    try {
      await admin.messaging().send(notificationMessage);
      console.log(`✅ Push notification sent to parent ${parentId}`);

      // Log the notification
      await admin.firestore()
        .collection('notificationLogs')
        .add({
          parentId: parentId,
          requestId: context.params.requestId,
          type: 'parent_approval',
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          status: 'sent'
        });
    } catch (error) {
      console.error('❌ Error sending push notification:', error);

      // Log the error
      await admin.firestore()
        .collection('notificationLogs')
        .add({
          parentId: parentId,
          requestId: context.params.requestId,
          type: 'parent_approval',
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          status: 'failed',
          error: error.message
        });
    }
  });

/**
 * Send notification when friendship is approved
 * Triggered when invitation status changes to 'accepted'
 */
exports.sendFriendshipApprovedNotification = functions.firestore
  .document('friendInvitations/{invitationId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only notify when status changes to accepted
    if (before.status !== 'accepted' && after.status === 'accepted') {
      const { fromChildId, toChildId, fromChildName, toChildName } = after;

      // Send notifications to both children (via their parents' devices)
      const notifications = [
        {
          childId: fromChildId,
          message: `You're now friends with ${toChildName}! 🎉`
        },
        {
          childId: toChildId,
          message: `You're now friends with ${fromChildName}! 🎉`
        }
      ];

      for (const notif of notifications) {
        try {
          // Get child's parent
          const childDoc = await admin.firestore()
            .collection('children')
            .doc(notif.childId)
            .get();

          if (!childDoc.exists) continue;

          const parentId = childDoc.data().parentId;

          // Get parent's FCM token
          const parentDoc = await admin.firestore()
            .collection('users')
            .doc(parentId)
            .get();

          if (!parentDoc.exists) continue;

          const fcmToken = parentDoc.data().fcmToken;
          if (!fcmToken) continue;

          // Send notification
          await admin.messaging().send({
            token: fcmToken,
            notification: {
              title: 'New Friend! 🎉',
              body: notif.message
            },
            data: {
              type: 'friendship_approved',
              invitationId: context.params.invitationId
            }
          });

          console.log(`✅ Friendship notification sent for child ${notif.childId}`);
        } catch (error) {
          console.error(`❌ Error sending friendship notification for child ${notif.childId}:`, error);
        }
      }
    }
  });

/**
 * Expire old invitations
 * Runs daily at midnight
 */
exports.expireOldInvitations = functions.pubsub
  .schedule('0 0 * * *')
  .timeZone('America/Los_Angeles')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();

    // Find expired invitations
    const expiredInvitations = await admin.firestore()
      .collection('friendInvitations')
      .where('expiresAt', '<', now.toDate())
      .where('status', 'in', ['pendingFromParentApproval', 'pendingRecipient', 'pendingToParentApproval'])
      .get();

    const batch = admin.firestore().batch();

    expiredInvitations.forEach((doc) => {
      batch.update(doc.ref, {
        status: 'expired',
        updatedAt: now
      });
    });

    await batch.commit();

    console.log(`✅ Expired ${expiredInvitations.size} old invitations`);

    // Also expire old approval requests
    const expiredRequests = await admin.firestore()
      .collection('parentApprovalRequests')
      .where('expiresAt', '<', now.toDate())
      .where('status', '==', 'pending')
      .get();

    const requestBatch = admin.firestore().batch();

    expiredRequests.forEach((doc) => {
      requestBatch.update(doc.ref, {
        status: 'expired'
      });
    });

    await requestBatch.commit();

    console.log(`✅ Expired ${expiredRequests.size} old approval requests`);
  });

/**
 * Update badge count for parents
 * Triggered when approval requests are created or updated
 */
exports.updateParentBadgeCount = functions.firestore
  .document('parentApprovalRequests/{requestId}')
  .onWrite(async (change, context) => {
    const parentId = change.after.exists
      ? change.after.data().parentId
      : change.before.data().parentId;

    // Count pending requests
    const pendingRequests = await admin.firestore()
      .collection('parentApprovalRequests')
      .where('parentId', '==', parentId)
      .where('status', '==', 'pending')
      .get();

    const count = pendingRequests.size;

    // Update user document with badge count
    await admin.firestore()
      .collection('users')
      .doc(parentId)
      .update({
        pendingApprovalCount: count
      });

    console.log(`✅ Updated badge count for parent ${parentId}: ${count}`);
  });
