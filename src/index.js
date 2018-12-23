'use strict';

import UIkit from 'uikit';
import Icons from 'uikit/dist/js/uikit-icons';

// loads the Icon plugin
UIkit.use(Icons);

require('uikit/dist/css/uikit.css');
require('font-awesome/css/font-awesome.css');

require('./index.html');

const database = {
    dbGtd: null,
    storeGtdInbox: null,
};
database.init = function () {
    const req = window.indexedDB.open('gtd', 1);
    req.onupgradeneeded = function (ev) {
        database.dbGtd = ev.target.result;
        ev.target.transaction.onerror = function (err) {
            console.log("XXX0", err);
        };
        if (database.dbGtd.objectStoreNames.contains('inbox')) {
            database.dbGtd.deleteObjectStore('inbox');
        }
        database.storeGtdInbox = database.dbGtd.createObjectStore('inbox', {keyPath: 'id'});
    };
    req.onsuccess = function (ev) {
        database.dbGtd = (ev.target) ? ev.target.result : ev.result;
    };
};
database.init();

const Main = require('./Main.elm');
const app = Main.Elm.Main.init({
    node: document.getElementById('main'),
    flags: 6
});

app.ports.saveInbox.subscribe(model => {
    if (!model.todoList) return false;

    const reqClear = database.dbGtd.transaction('inbox', 'readwrite').objectStore('inbox').clear();
    reqClear.onsuccess = function (event) {
        const store = database.dbGtd.transaction('inbox', 'readwrite').objectStore('inbox');
        model.todoList.forEach((todo) => {
            const req = store.put(todo);
            req.onsuccess = function (e) {
            };
            req.onerror = function (e) {
                console.error('failed save store!');
            };
        });
    };
    reqClear.onerror = function (e) {
        console.error('failed clear store!');
    };


});

