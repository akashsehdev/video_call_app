// // File: tokenServer.js
// const express = require("express");
// const { RtcTokenBuilder, RtcRole } = require("agora-access-token");

// const app = express();
// const port = 3000;

// const APP_ID = '89a610dea8574006913576c8fe6536a8';
// const APP_CERTIFICATE = "7834a311e23946f59a11b037330879ba";

// app.get("/generateToken", (req, res) => {
//     const channelName = req.query.channelName;
//     const uid = req.query.uid;
//     const role = RtcRole.PUBLISHER;
//     const expireTime = 3600;

//     const token = RtcTokenBuilder.buildTokenWithUid(
//         APP_ID,
//         APP_CERTIFICATE,
//         channelName,
//         uid,
//         role,
//         Math.floor(Date.now() / 1000) + expireTime
//     );

//     return res.json({ token });
// });

// app.listen(port, () => {
//     console.log(`Agora Token Server listening at http://localhost:${port}`);
// });
