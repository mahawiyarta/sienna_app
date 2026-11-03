const express = require('express');
const { rateLimit } = require('express-rate-limit');
const { auth, db } = require('./firebase');
const app = express();
const PORT = 3000;
const FIREBASE_WEB_API_KEY =
  process.env.FIREBASE_WEB_API_KEY;
const usernamePattern = /^[a-z0-9_]{3,20}$/;

app.disable('x-powered-by');
app.use(express.json({ limit: '4kb' }));

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 8,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Terlalu banyak percobaan login. Coba lagi nanti.'
  }
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    service: 'SIENNA Local Backend',
    message: 'Backend is running successfully'
  });
});

app.get('/firebase-status', async (req, res) => {
  try {
    await db
      .collection('usernames')
      .doc('sienna_connection_test')
      .get();
    await auth.listUsers(1);
    res.status(200).json({
      status: 'connected',
      project: 'sienna-app-f4bbd',
      authentication: 'connected',
      firestore: 'connected'
    });
  } catch (error) {
    console.error(
      'Firebase connection error:',
      error.code,
      error.message
    );
    res.status(503).json({
      status: 'error',
      message: 'Firebase connection failed'
    });
  }
});

function invalidCredentials(res) {
  return res.status(401).json({
    success: false,
    message: 'Username atau password salah.'
  });
}

app.post('/auth/login', loginLimiter, async (req, res) => {
  res.set('Cache-Control', 'no-store');
  const {
    username: inputUsername,
    password
  } = req.body || {};
  if (
    typeof inputUsername !== 'string' ||
    typeof password !== 'string'
  ) {
    return res.status(400).json({
      success: false,
      message: 'Username dan password wajib diisi.'
    });
  }
  const username = inputUsername.trim().toLowerCase();
  if (
    !usernamePattern.test(username) ||
    password.length === 0 ||
    password.length > 256
  ) {
    return res.status(400).json({
      success: false,
      message: 'Format username atau password tidak valid.'
    });
  }
  if (!FIREBASE_WEB_API_KEY) {
    return res.status(503).json({
      success: false,
      message: 'Konfigurasi backend belum lengkap.'
    });
  }
  try {
    const snapshot = await db
      .collection('users')
      .where('username', '==', username)
      .limit(1)
      .get();
    if (snapshot.empty) {
      return invalidCredentials(res);
    }
    const userDocument = snapshot.docs[0];
    const uid = userDocument.id;
    let userRecord;
    try {
      userRecord = await auth.getUser(uid);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        return invalidCredentials(res);
      }
      throw error;
    }
    if (!userRecord.email || userRecord.disabled) {
      return invalidCredentials(res);
    }

    const endpoint =
      'https://identitytoolkit.googleapis.com/v1/' +
      'accounts:signInWithPassword?key=' +
      encodeURIComponent(FIREBASE_WEB_API_KEY);

    const firebaseResponse = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: userRecord.email,
        password: password,
        returnSecureToken: true
      }),
      signal: AbortSignal.timeout(10000)
    });

    const firebaseResult =
      await firebaseResponse.json().catch(() => ({}));
    if (!firebaseResponse.ok) {
      const errorCode =
        firebaseResult.error?.message || '';
      const credentialErrors = [
        'INVALID_LOGIN_CREDENTIALS',
        'INVALID_PASSWORD',
        'EMAIL_NOT_FOUND',
        'INVALID_EMAIL',
        'USER_DISABLED'
      ];
      if (credentialErrors.includes(errorCode)) {
        return invalidCredentials(res);
      }
      if (errorCode === 'TOO_MANY_ATTEMPTS_TRY_LATER') {
        return res.status(429).json({
          success: false,
          message: 'Terlalu banyak percobaan. Coba lagi nanti.'
        });
      }
      console.error(
        'Firebase REST authentication failed:',
        firebaseResponse.status,
        errorCode
      );
      return res.status(502).json({
        success: false,
        message: 'Layanan verifikasi password sedang bermasalah.'
      });
    }
    if (
      firebaseResult.localId !== uid ||
      !firebaseResult.idToken
    ) {
      throw new Error(
        'Authenticated UID does not match Firestore profile'
      );
    }

    const customToken =
      await auth.createCustomToken(uid);
    return res.status(200).json({
      success: true,
      username: username,
      customToken: customToken
    });
  } catch (error) {
      console.error('========== LOGIN ERROR ==========');
      console.error('Error name:', error.name);
      console.error('Error code:', error.code);
      console.error('Error message:', error.message);
      console.error('=================================');
    return res.status(503).json({
      success: false,
      message: 'Layanan login belum tersedia. Silakan coba lagi.'
    });
  }
});

app.listen(PORT, '127.0.0.1', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Health: http://127.0.0.1:${PORT}/health`);
  console.log(`Firebase: http://127.0.0.1:${PORT}/firebase-status`);
  console.log('POST /auth/login');
});