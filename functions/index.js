const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.getUserById = functions.https.onRequest(async (req, res) => {
  if (req.method !== "GET") {
    return res.status(405).send({ error: "Method not allowed" });
  }

  const uid = req.query.uid; // Retrieve UID from query parameters

  if (!uid) {
    return res.status(400).send({ error: "UID must be provided." });
  }

  try {
    const userRecord = await admin.auth().getUser(uid);

    return res.status(200).send({
      uid: userRecord.uid,
      name: userRecord.displayName || null,
      email: userRecord.email || null,
      imageUrl: userRecord.photoURL || null,
    });
  } catch (error) {
    console.error("Error fetching user data:", error);
    return res.status(500).send({ error: "Error fetching user data." });
  }
});
