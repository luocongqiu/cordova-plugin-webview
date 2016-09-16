var exec = require('cordova/exec');

/**
 *
 * @param url 本地或远程地址
 * @param name 可取值 - '_self' 在当前窗口打开,'_system' 调用系统浏览器打开，其他在新窗口打开
 * @param options 参数 可以设置标题头背景颜色，字体颜色，状态栏颜色默认为标题头颜色
 * @param successCallback 成功回调
 * @param errorCallback 失败回调
 */
exports.open = function (url, name, options, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'WebView', 'open', [url, name, options || {}]);
};

