var exec = require('cordova/exec');
var channel = require('cordova/channel');

function WebView() {
    this.channels = {};
}

WebView.prototype = {

    _eventHandler: function (event) {
        if (event && (event.type in this.channels)) {
            this.channels[event.type].fire(event);
        }
    },

    close: function () {
        exec(null, null, 'WebView', 'close', []);
        return this;
    },

    show: function () {
        exec(null, null, 'WebView', 'show', []);
        return this;
    },

    reload: function () {
        exec(null, null, 'WebView', 'reload', []);
        return this;
    },

    addEventListener: function (eventName, f) {
        if (!(eventName in this.channels)) {
            this.channels[eventName] = channel.create(eventName);
        }
        this.channels[eventName].subscribe(f);
        return this;
    },

    removeEventListener: function (eventName, f) {
        if (eventName in this.channels) {
            this.channels[eventName].unsubscribe(f);
        }
        return this;
    }
};

exports.open = function (url, name, options, callbacks) {

    var webView = new WebView();
    callbacks = callbacks || {};
    for (var callbackName in callbacks) {
        if (!callbacks.hasOwnProperty(callbackName)) {
            return;
        }
        webView.addEventListener(callbackName, callbacks[callbackName]);
    }

    var cb = function (eventName) {
        webView._eventHandler(eventName);
    };

    setTimeout(function () {
        exec(cb, cb, 'WebView', 'open', [url, name, options || {}]);
    }, 0);
    return webView;
};

