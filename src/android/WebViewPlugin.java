package com.cordova.plugins.webview;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.provider.Browser;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.Whitelist;
import org.json.JSONException;

public class WebViewPlugin extends CordovaPlugin {

    private static final String LOG_TAG = WebViewPlugin.class.getName();

    private static final String SELF = "_self";
    private static final String SYSTEM = "_system";

    private static final int REQUEST_CODE = 1000;


    private CallbackContext callbackContext;

    public boolean execute(String action, CordovaArgs args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("open")) {
            this.callbackContext = callbackContext;
            String url = args.optString(0);
            String target = args.optString(1);
            String options = args.getJSONObject(2) != null ? args.getJSONObject(2).toString() : "";

            if (SELF.equals(target)) {
                boolean allowNavigation = url.startsWith("javascript:") || new Whitelist().isUrlWhiteListed(url) || webView.getPluginManager().shouldAllowNavigation(url);

                if (allowNavigation) {
                    webView.loadUrl(url);
                } else {
                    showWebView(url, options);
                }
            } else if (SYSTEM.equals(target)) {
                try {
                    Intent intent = new Intent(Intent.ACTION_VIEW);
                    Uri uri = Uri.parse(url);
                    if ("file".equals(uri.getScheme())) {
                        intent.setDataAndType(uri, webView.getResourceApi().getMimeType(uri));
                    } else {
                        intent.setData(uri);
                    }
                    intent.putExtra(Browser.EXTRA_APPLICATION_ID, cordova.getActivity().getPackageName());
                    cordova.getActivity().startActivity(intent);
                } catch (Exception e) {
                    Log.d(LOG_TAG, "调用系统浏览器失败", e);
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, e.getMessage()));
                    return false;
                }
            } else {
                showWebView(url, options);
            }
            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
        }
        return true;
    }

    private void showWebView(final String url, final String options) {
        Context context = cordova.getActivity().getApplicationContext();
        Intent intent = new Intent(context, WebViewActivity.class);
        intent.putExtra("options", options);
        intent.putExtra("url", url);
        cordova.startActivityForResult(WebViewPlugin.this, intent, REQUEST_CODE);
    }
}