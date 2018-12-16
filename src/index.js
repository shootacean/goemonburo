'use strict';

import UIkit from 'uikit';
import Icons from 'uikit/dist/js/uikit-icons';

// loads the Icon plugin
UIkit.use(Icons);

// components can be called from the imported UIkit reference
UIkit.notification('Hello world.');

require('uikit/dist/css/uikit.css');
require('font-awesome/css/font-awesome.css');

require('./index.html');
require('./gtd.html');

const {Elm} = require('./Main.elm');
const mountNode = document.getElementById('main');

const app = Elm.Main.init({node: mountNode});