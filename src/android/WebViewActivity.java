package com.cordova.plugins.webview;

import android.app.Activity;
import android.os.Bundle;

import com.ai.cucom.opaas.app.R;

public class WebViewActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_view);
    }
}
