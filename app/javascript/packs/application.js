// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import '@fortawesome/fontawesome-free/js/all'

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// if ('serviceWorker' in navigator) {
//     console.log('Service Worker is supported');
//     navigator.serviceWorker.register('/service-worker.js')
//         .then(function(registration) {
//             console.log('Successfully registered!', ':^)', registration);
//             registration.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: 'BEWrjXKrN7b4hUiqIV-cLYJvUjTI_ntQXV3kz7ZIWgBnbzSl-jvG8hzamjK71cKsBaSrF0pwwdl6TOEH9Lguk4Q'})
//                 .then(function(subscription) {
//                     console.log('endpoint:', subscription.toJSON());
//                 });
//         }).catch(function(error) {
//         console.log('Registration failed', ':^(', error);
//     });
// }

const requestNotificationPermission = async () => {

}

requestNotificationPermission();
