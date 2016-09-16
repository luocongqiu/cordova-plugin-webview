# cordova-plugin-webview
打开远程或本地html5页面
## 安装
`cordova plugin add https://github.com/luocongqiu/cordova-plugin-webview.git`
## 示例
    window.WebView.open('http://www.baidu.com', '_blank', {
        'headBarBg': '#FF7902',
        'titleColor': '#FFFFFF'
    });

## 方法 

    window.WebView.open(url, name, options, successCallback, errorCallback);

### 参数说明
- `url` 需要打开的连接地址，远程地址或本地地址
- `name` 窗口名字，`_self` 在本页面打开, `_system` 调用系统浏览器打开，其他打开新窗口
- `options` 配置参数
    {
        'headBarBg': '#FF7902', //标题头背景色
        'headBarHeight': 44,    //标题头高度，默认44
        'titleColor': '#FFFFFF' //标题字体颜色 用于显示页面标题
    }
- `successCallback` 成功加载页面回调函数
- `errorCallback` 打开失败回调函数