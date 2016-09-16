package com.cordova.plugins.webview;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.ai.cucom.opaas.app.R;

import org.json.JSONException;
import org.json.JSONObject;

public class WebViewActivity extends Activity {

    private final static String LOG_TAG = WebViewActivity.class.getName();

    private WebView webView;
    private LinearLayout headBar;
    private TextView title;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_view);

        webView = (WebView) findViewById(R.id.webView);
        headBar = (LinearLayout) findViewById(R.id.headBar);
        title = (TextView) findViewById(R.id.title);

        WebViewOptions options = parseOptions(getIntent().getStringExtra("options"));
        setStatusBarBackgroundColor(options);
        initWebView(options);
    }

    private void setStatusBarBackgroundColor(WebViewOptions options) {
        if (Build.VERSION.SDK_INT < 21) {
            return;
        }
        final Window window = this.getWindow();
        window.clearFlags(0x04000000); // SDK 19: WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        window.addFlags(0x80000000); // SDK 21: WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        try {
            window.getClass().getMethod("setStatusBarColor", int.class).invoke(window, options.getHeadBarBg());
        } catch (Exception e) {
            Log.w(LOG_TAG, "Method window.setStatusBarColor not found for SDK level " + Build.VERSION.SDK_INT, e);
        }
    }

    private void initWebView(WebViewOptions options) {
        headBar.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, options.getHeadBarHeight()));
        headBar.setBackgroundColor(options.getHeadBarBg());
        title.setTextColor(options.getTitleColor());

        webView.setWebViewClient(new WebViewClient() {
            public boolean shouldOverrideUrlLoading(WebView webView, String url) {
                if (url.startsWith(WebView.SCHEME_TEL)) {
                    try {
                        Intent intent = new Intent(Intent.ACTION_DIAL);
                        intent.setData(Uri.parse(url));
                        startActivity(intent);
                        return true;
                    } catch (android.content.ActivityNotFoundException e) {
                        Log.e(LOG_TAG, "Error dialing " + url + ": " + e.toString());
                    }
                } else if (url.startsWith("geo:") || url.startsWith(WebView.SCHEME_MAILTO) || url.startsWith("market:")) {
                    try {
                        Intent intent = new Intent(Intent.ACTION_VIEW);
                        intent.setData(Uri.parse(url));
                        startActivity(intent);
                        return true;
                    } catch (android.content.ActivityNotFoundException e) {
                        Log.e(LOG_TAG, "Error with " + url + ": " + e.toString());
                    }
                } else if (url.startsWith("sms:")) {
                    try {
                        Intent intent = new Intent(Intent.ACTION_VIEW);
                        String address;
                        int parAmIndex = url.indexOf('?');
                        if (parAmIndex == -1) {
                            address = url.substring(4);
                        } else {
                            address = url.substring(4, parAmIndex);
                            Uri uri = Uri.parse(url);
                            String query = uri.getQuery();
                            if (query != null) {
                                if (query.startsWith("body=")) {
                                    intent.putExtra("sms_body", query.substring(5));
                                }
                            }
                        }
                        intent.setData(Uri.parse("sms:" + address));
                        intent.putExtra("address", address);
                        intent.setType("vnd.android-dir/mms-sms");
                        startActivity(intent);
                        return true;
                    } catch (android.content.ActivityNotFoundException e) {
                        Log.e(LOG_TAG, "Error sending sms " + url + ":" + e.toString());
                    }
                }
                return false;
            }

            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
            }

            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                title.setText(view.getTitle());
            }

            public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                super.onReceivedError(view, request, error);
            }
        });

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setJavaScriptCanOpenWindowsAutomatically(true);
        settings.setBuiltInZoomControls(true);
        settings.setDisplayZoomControls(false);
        settings.setLoadWithOverviewMode(true);
        settings.setUseWideViewPort(true);
        webView.loadUrl(getIntent().getStringExtra("url"));
        webView.requestFocus();
        webView.requestFocusFromTouch();

    }

    private WebViewOptions parseOptions(String str) {
        WebViewOptions options = new WebViewOptions();
        try {
            JSONObject jsonObject = new JSONObject(str);
            if (jsonObject.has("headBarBg")) {
                options.setHeadBarBg(hexStringToColor(jsonObject.getString("headBarBg")));
            } else {
                options.setHeadBarBg(hexStringToColor(WebViewOptions.HEADBAR_DEF_BG));
            }

            if (jsonObject.has("headBarHeight")) {
                options.setHeadBarHeight(dpToPixels(jsonObject.getInt("headBarHeight")));
            } else {
                options.setHeadBarHeight(dpToPixels(WebViewOptions.HEADBAR_DEF_HEIGHT));
            }

            if (jsonObject.has("titleColor")) {
                options.setTitleColor(hexStringToColor(jsonObject.getString("titleColor")));
            } else {
                options.setTitleColor(hexStringToColor(WebViewOptions.TITLE_DEF_COLOR));
            }
        } catch (JSONException e) {
            Log.d(LOG_TAG, "解析参数失败", e);
            this.finish();
        }
        return options;
    }

    private int dpToPixels(int dipValue) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, (float) dipValue, this.getResources().getDisplayMetrics());
    }

    private int hexStringToColor(String hex) {
        int result = 0;
        if (hex != null && !hex.isEmpty()) {
            if (hex.charAt(0) == '#') {
                hex = hex.substring(1);
            }
            if (hex.length() < 8) {
                hex += "ff";
            }
            result = (int) Long.parseLong(hex, 16);
            int alpha = (result & 0xff) << 24;
            result = result >> 8 & 0xffffff | alpha;
        }
        return result;
    }

    public void goBack(View view) {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            this.finish();
        }
    }
}