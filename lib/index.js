// const functions = require('firebase-functions');
// const admin = require('firebase-admin');
// admin.initializeApp();

// exports.sendCallNotification = functions.firestore
//     .document('calls/{callId}')
//     .onCreate(async (snap, context) => {
//         const callData = snap.data();
//         const receiverDoc = await admin.firestore().collection('users').doc(callData.receiverId).get();
//         const fcmToken = receiverDoc.data().fcmToken;

//         const message = {
//             token: fcmToken,
//             data: {
//                 type: 'incoming_call',
//                 channelId: callData.channelId,
//                 callerId: callData.callerId,
//             },
//         };

//         await admin.messaging().send(message);
//     });
