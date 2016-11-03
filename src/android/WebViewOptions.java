package com.cordova.plugins.webview;

public class WebViewOptions {

    public final static String HEADBAR_DEF_BG = "#000000";
    public final static int HEADBAR_DEF_HEIGHT = 44;
    public final static String TITLE_DEF_COLOR = "#FFFFFF";

    private int headBarBg;
    private int headBarHeight;
    private int titleColor;

    public int getHeadBarBg() {
        return headBarBg;
    }

    public void setHeadBarBg(int headBarBg) {
        this.headBarBg = headBarBg;
    }

    public int getHeadBarHeight() {
        return headBarHeight;
    }

    public void setHeadBarHeight(int headBarHeight) {
        this.headBarHeight = headBarHeight;
    }

    public int getTitleColor() {
        return titleColor;
    }

    public void setTitleColor(int titleColor) {
        this.titleColor = titleColor;
    }

}
