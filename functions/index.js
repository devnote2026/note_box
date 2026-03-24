const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.deleteUserData = onCall(async (request) => {
  console.log("🔥 関数スタート");

  if (!request.auth) {
    console.error("❌ 未ログイン");
    throw new HttpsError("unauthenticated", "ログイン必要");
  }

  const uid = request.auth.uid;
  console.log("👤 uid:", uid);

  const db = admin.firestore();
  const bucket = admin.storage().bucket();

  try {
    // =========================
    // 🔧 共通削除関数
    // =========================
    const deleteCollection = async (snapshot) => {
      let batch = db.batch();
      let count = 0;

      for (const doc of snapshot.docs) {
        batch.delete(doc.ref);
        count++;

        if (count === 500) {
          await batch.commit();
          batch = db.batch();
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }
    };

    // =========================
    // ① users削除
    // =========================
    console.log("① users削除開始");

    const userRef = db.collection("users").doc(uid);

    const userPosts = await userRef.collection("posts").get();
    console.log("userPosts数:", userPosts.size);

    await deleteCollection(userPosts);

    await userRef.delete();
    console.log("users削除完了");

    // =========================
    // ② notes削除
    // =========================
    console.log("② notes削除開始");

    const notesSnapshot = await db
      .collection("notes")
      .where("uid", "==", uid)
      .get();

    console.log("notes数:", notesSnapshot.size);

    for (const noteDoc of notesSnapshot.docs) {
      const noteId = noteDoc.id;

      const postsSnapshot = await noteDoc.ref.collection("posts").get();

      await deleteCollection(postsSnapshot);
      await noteDoc.ref.delete();

      try {
        await bucket.deleteFiles({
          prefix: `notes/${noteId}/`,
        });
      } catch (e) {
        console.error("⚠️ storage削除失敗:", noteId, e);
      }
    }

    // =========================
    // ③ reports削除
    // =========================
    console.log("③ reports削除開始");

    const reportsSnapshot = await db
      .collection("reports")
      .where("reportedBy", "==", uid)
      .get();

    await deleteCollection(reportsSnapshot);

    // =========================
    // ④ profile削除
    // =========================
    console.log("④ profile削除開始");

    try {
      await bucket.deleteFiles({
        prefix: `users/${uid}/`,
      });
    } catch (e) {
      console.error("⚠️ profile削除失敗:", e);
    }

    // =========================
    // ⑤ Auth削除
    // =========================
    console.log("⑤ Auth削除開始");

    await admin.auth().deleteUser(uid);

    console.log("🎉 全削除完了");

    return { success: true };

  } catch (error) {
    console.error("💥 エラー発生:", error);

    throw new HttpsError(
      "internal",
      error.message || "削除失敗",
      {
        detail: error.toString(),
      }
    );
  }
});