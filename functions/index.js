const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.deleteUserData = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "ログイン必要");
  }

  const uid = context.auth.uid;
  const db = admin.firestore();
  const bucket = admin.storage().bucket();

  try {
    // =========================
    // ① users削除
    // =========================
    const userRef = db.collection("users").doc(uid);

    // users/{uid}/posts削除
    const userPosts = await userRef.collection("posts").get();
    const batch1 = db.batch();
    userPosts.forEach((doc) => batch1.delete(doc.ref));
    await batch1.commit();

    // users/{uid}削除
    await userRef.delete();

    // =========================
    // ② notes削除（自分のノート）
    // =========================
    const notesSnapshot = await db
      .collection("notes")
      .where("uid", "==", uid)
      .get();

    for (const noteDoc of notesSnapshot.docs) {
      const noteId = noteDoc.id;

      // posts削除
      const postsSnapshot = await db
        .collection("notes")
        .doc(noteId)
        .collection("posts")
        .get();

      const batch2 = db.batch();
      postsSnapshot.forEach((doc) => batch2.delete(doc.ref));
      await batch2.commit();

      // note削除
      await noteDoc.ref.delete();

      // Storage削除
      await bucket.deleteFiles({
        prefix: `notes/${noteId}/`,
      });
    }

    // =========================
    // ③ reports削除
    // =========================
    const reportsSnapshot = await db
      .collection("reports")
      .where("reportedBy", "==", uid)
      .get();

    const batch3 = db.batch();
    reportsSnapshot.forEach((doc) => batch3.delete(doc.ref));
    await batch3.commit();

    // =========================
    // ④ プロフィール画像削除
    // =========================
    await bucket.deleteFiles({
      prefix: `users/${uid}/`,
    });

    // =========================
    // ⑤ Auth削除
    // =========================
    await admin.auth().deleteUser(uid);

    return { success: true };

  } catch (error) {
    console.error(error);
    throw new functions.https.HttpsError("internal", "削除失敗");
  }
});