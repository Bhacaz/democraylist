
const NOTIFICATION_OPTION_NAMES = [
    'actions', 'badge', 'body', 'data', 'dir', 'icon', 'image', 'lang', 'renotify',
    'requireInteraction', 'silent', 'tag', 'timestamp', 'title', 'vibrate'
];

function onPush(event) {
    console.log(event.data.json().notification);

    const data = event.data.json()
    const desc = data.notification;
    let options = {};
    NOTIFICATION_OPTION_NAMES.filter(name => desc.hasOwnProperty(name))
        .forEach(name => options[name] = desc[name]);
    event.waitUntil(
        self.registration.showNotification(desc['title'], options),
    )
}

self.addEventListener('fetch',() => {});
self.addEventListener("push", onPush);
self.addEventListener('notificationclick', (event) => {
    if (clients.openWindow && event.notification.data.url) {
        event.waitUntil(clients.openWindow(event.notification.data.url));
    }
});
