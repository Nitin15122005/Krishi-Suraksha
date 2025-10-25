import { initializeApp } from "https://www.gstatic.com/firebasejs/11.0.1/firebase-app.js";
import { getAuth, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/11.0.1/firebase-auth.js";
import { getFirestore, collection, addDoc } from "https://www.gstatic.com/firebasejs/11.0.1/firebase-firestore.js";

const firebaseConfig = { 
  apiKey: "AIzaSyDOfITSFNWEqe3JNLKnLwXnTE62aQzV9TI",
  authDomain: "website-c577e.firebaseapp.com",
  projectId: "website-c577e",
  storageBucket: "website-c577e.firebasestorage.app",
  messagingSenderId: "1894221458",
  appId: "1:1894221458:web:193489156de57b9ecfc84b",
  measurementId: "G-739EQXGZBV"
};

// ✅ Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// 🔐 Require Login Redirect
export function requireLogin() {
  return new Promise((resolve) => {
    onAuthStateChanged(auth, (user) => {
      if (!user) {
        window.location.href = "login.html";
      } else {
        resolve(user);
      }
    });
  });
}

// 📝 Audit Log Function
export async function logAction(claimId, action, details, officerEmail) {
  try {
    await addDoc(collection(db, "auditLogs"), {
      claimId,
      action,
      details,
      officerEmail,
      timestamp: new Date()
    });
  } catch (error) {
    console.error("Error logging action:", error);
  }
}

export { auth, db };