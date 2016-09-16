package com.cordova.plugins.webview;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONException;

public class WebViewPlugin extends CordovaPlugin {

    private static final String LOG_TAG = WebViewPlugin.class.getName();

    private static final String SELF = "_self";
    private static final String SYSTEM = "_system";


    private CallbackContext callbackContext;

    public boolean execute(String action, CordovaArgs args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("open")) {
            this.callbackContext = callbackContext;
            String t = args.optString(1);
            if (t == null || "".equals(t) || "null".equals(t)) {
                t = SELF;
            }
            final String target = t;
        }
        return false;

    }
}
