import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:torn_pda/providers/settings_provider.dart';
import 'package:torn_pda/providers/shortcuts_provider.dart';
import 'package:torn_pda/providers/theme_provider.dart';
import 'package:torn_pda/providers/webview_provider.dart';

class WebViewStackView extends StatefulWidget {
  final String initUrl;
  final bool dialog;

  const WebViewStackView({
    this.initUrl = "https://www.torn.com",
    this.dialog = false,
    Key key,
  }) : super(key: key);

  @override
  _WebViewStackViewState createState() => _WebViewStackViewState();
}

class _WebViewStackViewState extends State<WebViewStackView> {
  ThemeProvider _themeProvider;
  WebViewProvider _webViewProvider;
  SettingsProvider _settingsProvider;

  bool _useTabs = false;

  Future providerInitialised;

  @override
  void initState() {
    super.initState();

    // Assess if we need to use tabs based on the combination
    _settingsProvider = context.read<SettingsProvider>();
    if ((widget.dialog && _settingsProvider.useTabsBrowserDialog) ||
        (!widget.dialog && _settingsProvider.useTabsFullBrowser)) {
      _useTabs = true;
    }

    // Initialise WebViewProvider
    providerInitialised = Provider.of<WebViewProvider>(context, listen: false).initialise(
      initUrl: widget.initUrl,
      useTabs: _useTabs,
      dialog: widget.dialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    _webViewProvider = Provider.of<WebViewProvider>(context, listen: true);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    var allWebViews = <Widget>[];
    for (var tab in _webViewProvider.tabList) {
      allWebViews.add(tab.webView);
    }

    return Scaffold(
      body: FutureBuilder(
        future: providerInitialised,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_useTabs) {
              return IndexedStack(
                index: _webViewProvider.currentTab,
                children: allWebViews,
              );
            } else {
              return IndexedStack(
                index: 0,
                children: [
                  allWebViews[0],
                ],
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: FutureBuilder(
        future: providerInitialised,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done && _useTabs) {
            return _bottomNavBar();
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  @override
  Future dispose() async {
    _webViewProvider.clearOnDispose();
    super.dispose();
  }

  Widget _bottomNavBar() {
    var mainTab = GestureDetector(
      key: UniqueKey(),
      onTap: () {
        _webViewProvider.activateTab(0);
      },
      onLongPress: () {
        _webViewProvider.addTab(
          url: _webViewProvider.tabList[0].currentUrl,
          chatRemovalActive: _webViewProvider.tabList[0].chatRemovalActiveTab,
          historyBack: _webViewProvider.tabList[0].historyBack,
          historyForward: _webViewProvider.tabList[0].historyForward,
        );

        BotToast.showText(
          crossPage: false,
          text: "Added duplicated tab!",
          textStyle: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
          contentColor: Colors.blue,
          duration: Duration(seconds: 1),
          contentPadding: EdgeInsets.all(10),
        );
      },
      child: Container(
        color: _webViewProvider.currentTab == 0 ? _themeProvider.navSelected : Colors.transparent,
        child: Row(
          children: [
            Padding(
              padding: _webViewProvider.useTabIcons
                  ? const EdgeInsets.all(10.0)
                  : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: _webViewProvider.useTabIcons
                  ? _getIcon(0)
                  : Container(
                      constraints: BoxConstraints(maxWidth: 100),
                      child: Text(
                        _webViewProvider.tabList[0].pageTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: _webViewProvider.tabList[0].currentUrl.contains("sid=attack&user2ID=2225097") ||
                                  _webViewProvider.tabList[0].currentUrl.contains("profiles.php?XID=2225097") ||
                                  _webViewProvider.tabList[0].currentUrl.contains("https://www.torn.com/forums.php#/"
                                      "p=threads&f=67&t=16163503&b=0&a=0")
                              ? Colors.pink
                              : _themeProvider.mainText,
                        ),
                      ),
                    ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );

    var secondaryTabs = <Widget>[];
    for (var i = 0; i < _webViewProvider.tabList.length; i++) {
      if (i == 0) {
        secondaryTabs.add(
          Container(
            key: UniqueKey(),
            child: SizedBox.shrink(),
          ),
        );
        continue;
      }

      Widget secondaryTab = GestureDetector(
        key: UniqueKey(),
        onTap: () {
          _webViewProvider.activateTab(i);
        },
        onDoubleTap: () {
          if (_webViewProvider.tabList.length > 0) {
            _webViewProvider.removeTab(i);
          }
        },
        child: Container(
          color: _webViewProvider.currentTab == i ? _themeProvider.navSelected : Colors.transparent,
          child: Row(
            children: [
              Padding(
                padding: _webViewProvider.useTabIcons
                    ? const EdgeInsets.all(10.0)
                    : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: _webViewProvider.useTabIcons
                    ? _getIcon(i)
                    : Container(
                        constraints: BoxConstraints(maxWidth: 100),
                        child: Text(
                          _webViewProvider.tabList[i].pageTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: _webViewProvider.tabList[i].currentUrl.contains("sid=attack&user2ID=2225097") ||
                                    _webViewProvider.tabList[i].currentUrl.contains("profiles.php?XID=2225097") ||
                                    _webViewProvider.tabList[i].currentUrl.contains("https://www.torn.com/forums.php#/"
                                        "p=threads&f=67&t=16163503&b=0&a=0")
                                ? Colors.pink
                                : _themeProvider.mainText,
                          ),
                        ),
                      ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      );
      secondaryTabs.add(secondaryTab);
    }

    return Container(
      height: 40,
      decoration: new BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              children: [
                mainTab,
                VerticalDivider(
                  width: 2,
                  thickness: 2,
                  color: _themeProvider.mainText,
                ),
                Expanded(
                  child: ReorderableListView(
                    scrollDirection: Axis.horizontal,
                    children: secondaryTabs,
                    onReorder: (start, end) {
                      if (start == 0 || end == 0) return;
                      // Save where the current active tab is
                      var activeKey = _webViewProvider.tabList[_webViewProvider.currentTab].webView.key;
                      // Removing the item at oldIndex will shorten the list by 1
                      if (start < end) end -= 1;
                      // Do the move
                      _webViewProvider.reorderTabs(_webViewProvider.tabList[start], start, end);
                      // Make sure we continue in our previous active tab
                      for (var i = 0; i < _webViewProvider.tabList.length; i++) {
                        if (_webViewProvider.tabList[i].webView.key == activeKey) {
                          _webViewProvider.activateTab(i);
                          break;
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              VerticalDivider(
                width: 2,
                thickness: 2,
                color: _themeProvider.mainText,
              ),
              GestureDetector(
                child: Container(
                  color: _themeProvider.navSelected,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: _themeProvider.mainText,
                    ),
                  ),
                ),
                onTap: () {
                  _webViewProvider.addTab();
                  _webViewProvider.activateTab(_webViewProvider.tabList.length - 1);
                },
                onLongPress: () {
                  _webViewProvider.useTabIcons
                      ? _webViewProvider.changeUseTabIcons(false)
                      : _webViewProvider.changeUseTabIcons(true);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Uses the already generated shortcuts list
  Widget _getIcon(int i) {
    var url = _webViewProvider.tabList[i].currentUrl;

    // Find some icons manually first, as they might trigger errors with shortcuts
    if (url.contains("index.php")) {
      return ImageIcon(AssetImage('images/icons/home/home.png'));
    } else if (url.contains("sid=attack&user2ID=2225097")) {
      return Icon(MdiIcons.pistol, color: Colors.pink);
    } else if (url.contains("sid=attack&user2ID=")) {
      return Icon(Icons.person);
    } else if (url.contains("profiles.php?XID=2225097")) {
      return Icon(Icons.person, color: Colors.pink);
    } else if (url.contains("profiles.php")) {
      return Icon(Icons.person, color: _themeProvider.mainText);
    } else if (url.contains("companies.php")) {
      return ImageIcon(AssetImage('images/icons/home/job.png'));
    } else if (url.contains("https://www.torn.com/forums.php#/p=threads&f=67&t=16163503&b=0&a=0")) {
      return ImageIcon(AssetImage('images/icons/home/forums.png'), color: Colors.pink);
    } else if (url.contains("https://www.torn.com/forums.php")) {
      return ImageIcon(AssetImage('images/icons/home/forums.png'));
    } else if (url.contains("companies.php")) {
      return ImageIcon(AssetImage('images/icons/home/job.png'));
    } else if (url.contains("yata.yt")) {
      return Image.asset('images/icons/yata_logo.png');
    } else if (url.contains("events.php")) {
      return Image.asset('images/icons/home/events.png');
    }

    // Try to find by using shortcuts list
    // Note: some are not found because the value that comes from OnLoadStop in the WebView differs from
    // the standard URL in shortcuts. That's why there are some more in the list above.
    var shortProvider = context.read<ShortcutsProvider>();
    for (var short in shortProvider.allShortcuts) {
      if (short.url.contains(url)) {
        return ImageIcon(AssetImage(short.iconUrl));
      }
    }

    return ImageIcon(AssetImage('images/icons/pda_icon.png'));
  }
}
