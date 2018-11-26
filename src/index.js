'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');

require('./index.html');

const {Elm} = require('./Main.elm');
const mountNode = document.getElementById('main');

const app = Elm.Main.init({node: mountNode});