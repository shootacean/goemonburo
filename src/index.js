'use strict';

import UIkit from 'uikit';
import Icons from 'uikit/dist/js/uikit-icons';

// loads the Icon plugin
UIkit.use(Icons);

require('uikit/dist/css/uikit.css');
require('font-awesome/css/font-awesome.css');

require('./goemonburo.css');
require('./index.html');


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
app.ports.openTodoDetail.subscribe( n => {
    const todoDetail = document.getElementById('todo-detail');
    if ( todoDetail.hasAttribute('hidden') ) {
        todoDetail.removeAttribute('hidden');
    } else {
        todoDetail.setAttribute('hidden', '');
    }
});

const database = {
    dbGtd: null,
    storeGtdInbox: null,
};
/**
 * データベースを初期化する
 */
database.init = function () {
    return new Promise(function (resolve, reject) {
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
            resolve('success!');
        };
        req.onsuccess = function (ev) {
            database.dbGtd = (ev.target) ? ev.target.result : ev.result;
            resolve('success!');
        };
        req.onerror = function (ev) {
            reject("Failed init!");
        }
    });
};
/**
 * データベースをロードする
 */
database.loadInbox = function () {
    return new Promise(function (resolve, reject) {
        const store = database.dbGtd.transaction('inbox', 'readwrite').objectStore('inbox');
        store.getAll().onsuccess = function () {
            resolve('success!');
            const rows = event.target.result;
            app.ports.loadInbox.send(rows);
        };
    });
};

database.init().then(function () {
    database.loadInbox();
}).catch(function (error) {
    console.log(error);
});