const admin = require('firebase-admin');
const serviceAccount = require('./henshin-197b5-firebase-adminsdk-buww7-0ab2aa9f17.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Replace with your admin user's UID
const uid = 'SuVJb4mrseWZ4fwxKNveKSvNv0U2';

admin.auth().setCustomUserClaims(uid, { role: 'admin' })
  .then(() => {
    console.log('Custom claim set for admin!');
    process.exit();
  })
  .catch(console.error);
