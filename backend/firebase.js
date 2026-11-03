const fs = require('node:fs');

const {
  initializeApp,
  cert,
  getApps
} = require('firebase-admin/app');

const {
  getAuth
} = require('firebase-admin/auth');

const {
  getFirestore
} = require('firebase-admin/firestore');

const PROJECT_ID = 'sienna-app-f4bbd';

const keyPath =
  process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!keyPath) {
  throw new Error(
    'GOOGLE_APPLICATION_CREDENTIALS belum diatur.'
  );
}
if (!fs.existsSync(keyPath)) {
  throw new Error(
    'Firebase Admin key tidak ditemukan.'
  );
}

const serviceAccount = JSON.parse(
  fs.readFileSync(keyPath, 'utf8')
);

if (
  serviceAccount.project_id !== PROJECT_ID ||
  serviceAccount.type !== 'service_account' ||
  !serviceAccount.private_key ||
  !serviceAccount.client_email
) {
  throw new Error(
    'Firebase Admin credentials tidak valid.'
  );
}
if (getApps().length === 0) {
  initializeApp({
    credential: cert(serviceAccount),
    projectId: PROJECT_ID
  });
}

const auth = getAuth();
const db = getFirestore();

module.exports = {
  auth,
  db
};