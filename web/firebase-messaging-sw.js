importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyA9bOVhicwxSGzy7dlqhkONnTtla9Sh0YI",
  authDomain: "traemelopf-eb055.firebaseapp.com",
  projectId: "traemelopf-eb055",
  storageBucket: "traemelopf-eb055.firebasestorage.app",
  messagingSenderId: "599534815846",
  appId: "1:599534815846:web:0bc7d8ffba640f3670bba7",
  databaseURL: "https://traemelopf-eb055-default-rtdb.firebaseio.com",
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});