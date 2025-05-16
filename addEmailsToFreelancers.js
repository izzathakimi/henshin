const admin = require('firebase-admin');
const serviceAccount = require('./henshin-197b5-firebase-adminsdk-buww7-7a8fe213b3.json'); // <-- update this path

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function addEmailsToFreelancers() {
  const freelancersSnap = await db.collection('freelancers').get();
  for (const doc of freelancersSnap.docs) {
    // Try to get the email from the users collection
    const userSnap = await db.collection('users').doc(doc.id).get();
    if (userSnap.exists) {
      const email = userSnap.data().email;
      if (email) {
        await doc.ref.update({ email });
        console.log(`Updated ${doc.id} with email ${email}`);
      } else {
        console.log(`No email found for ${doc.id}`);
      }
    } else {
      console.log(`No user doc for ${doc.id}`);
    }
  }
  console.log('Done!');
}

addEmailsToFreelancers();
