import 'dart:io';

import 'package:fashion_wallpapers/extra/aboutus.dart';
import 'package:fashion_wallpapers/helper/WallpaperBloc.dart';
import 'package:fashion_wallpapers/helper/helper.dart';
import 'package:fashion_wallpapers/main.dart';
import 'package:fashion_wallpapers/ui/tabfavourites.dart';
import 'package:fashion_wallpapers/ui/tabfour.dart';
import 'package:fashion_wallpapers/ui/tabthree.dart';
import 'package:fashion_wallpapers/ui/tabtwo.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_changer/wallpaper_changer.dart';
import 'package:workmanager/workmanager.dart';

import 'homepage.dart';

const CHECK_UPDATE = "checkUpdate";
const CHANGE_WALLPAPER = "changeWallpaper";

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case CHECK_UPDATE:
        var res = await Helper.checkAndSetUpdates();
        if (res != -1) showNotification();
        break;
      case CHANGE_WALLPAPER:
//        await Helper.changeWallpaper(await getExternalStorageDirectory());
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        int timerHours = localStorage.getInt('timer_hours') ?? 0;
        int remainedService = localStorage.getInt('remained_service') ?? 0;

        if (timerHours == 1 && remainedService <= 0) {
          //service finished
          localStorage.setInt('timer_hours', 0);
          break;
        } else if (timerHours == 1)
          localStorage.setInt('remained_service', remainedService - 1);
        int current = localStorage.getInt('current_wallpaper_index');
        if (current == null) {
          current = -1;
          localStorage.setInt('current_wallpaper_index', -1);
        }
        Directory directory = await getExternalStorageDirectory();
        final myImagePath = '${directory.path}/Fashion_Wallpapers/Favourites';
        if (Directory(myImagePath).existsSync()) {
          List<FileSystemEntity> files = Directory(myImagePath)
              .listSync(recursive: false, followLinks: false);

          if (current + 1 < files.length) {
            localStorage.setInt('current_wallpaper_index', current + 1);
          } else {
            current = -1;
            localStorage.setInt('current_wallpaper_index', -1);
          }

          await WallpaperChanger.change(files[current + 1].path);
        } else {
          print("not exist $myImagePath");
        }

        break;
    }
    //simpleTask will be emitted here.
    return Future.value(true);
  });
}

showNotification() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings(
//        onDidReceiveLocalNotification: onDidReceiveLocalNotification
      );
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    navigatorKey.currentState.pushNamed("/");
  });
  var androidPlatformChannelSpecifics = AndroidNotificationDetails('0',
      'Updates Channel', 'Shows Notification When New Wallpapers Are Available',
      importance: Importance.Default,
      priority: Priority.Default,
      ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(0, 'Fashion Wallpapers',
      'New Wallpapers Are Available!', platformChannelSpecifics,
      payload: '');
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  WallpaperBloc _bloc;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  BannerAd _bannerAd;

  MobileAdTargetingInfo targetingInfo;

  @override
  void initState() {
    print('init my app');
    _bloc = WallpaperBloc();
    Helper.initAdmob();
    showBannerAd();
    Helper.checkAndSetUpdates();
    initServices();
    super.initState();
  }

  showBannerAd() {
    _bannerAd ??= Helper.createBannerAd();
    _bannerAd
      ..load()
      ..show(
        anchorOffset: 0.0,
        horizontalCenterOffset: 0.0,
        anchorType: AnchorType.bottom,
      );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();

    super.dispose();
  }

  initServices() {
    Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
//      isInDebugMode:
//          true, // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
    //Android only (see below)
    Workmanager.registerPeriodicTask(
      "fashionWallpapers.checkUpdate", //name
      CHECK_UPDATE, //task name
      existingWorkPolicy: ExistingWorkPolicy.keep,
      initialDelay: Duration(hours: 72),
      constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false),
      frequency: Duration(hours: 72),
    );
  }

  TabBar _tabBar = TabBar(
    indicatorColor: Colors.white,
    tabs: [
      Tab(
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  child: CircleAvatar(
                    backgroundImage: AssetImage("images/woman.ico"),
                    backgroundColor: Colors.black,
                  ),
                  padding: EdgeInsets.all(3.0),
                  decoration: new BoxDecoration(
                    color: Colors.yellowAccent, // border color
                    shape: BoxShape.circle,
                  )),
              FittedBox(
                child: Text(
                  "Woman",
//                maxLines: 1,
//                overflow: TextOverflow.visible,
//                  style: TextStyle(color: Colors.white),
                ),
                fit: BoxFit.fill,
              ),
            ],
          ),
          fit: BoxFit.fill,
        ),
      ),
      Tab(
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  child: CircleAvatar(
//                        radius: 30.0,
                    backgroundImage: AssetImage("images/man.ico"),
                    backgroundColor: Colors.black,
                  ),
                  padding: EdgeInsets.all(3.0),
                  decoration: new BoxDecoration(
                    color: Colors.yellowAccent, // border color
                    shape: BoxShape.circle,
                  )),
              FittedBox(
                  child: Text(
                    "Man",
                  ),
                  fit: BoxFit.fill),
            ],
          ),
          fit: BoxFit.scaleDown,
        ),
      ),
      Tab(
        child: FittedBox(
          child: Column(
            children: <Widget>[
              Container(
                child: CircleAvatar(
//                          radius: 30.0,
                  backgroundImage: AssetImage("images/baby.ico"),
                  backgroundColor: Colors.black,
                ),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    color: Colors.yellowAccent, shape: BoxShape.circle),
              ),
              Text(
                "Baby",
              )
            ],
          ),
          fit: BoxFit.scaleDown,
        ),
      ),
      Tab(
        child: FittedBox(
          child: Column(
            children: <Widget>[
              Container(
                child: CircleAvatar(
                  backgroundImage: AssetImage("images/home.ico"),
                  backgroundColor: Colors.black,
                ),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    color: Colors.yellowAccent, shape: BoxShape.circle),
              ),
              Text("Home"),
            ],
          ),
          fit: BoxFit.cover,
        ),
      ),
      Tab(
        child: FittedBox(
          child: Column(
            children: <Widget>[
              Icon(
                Icons.favorite,
                color: Colors.yellowAccent,
              ),
              FittedBox(
                child: Text(
                  "favorite",
//                  style: TextStyle(color: Colors.yellowAccent, fontSize: 12.0),
                ),
                fit: BoxFit.fitHeight,
              ),
            ],
          ),
          fit: BoxFit.fitHeight,
        ),
      ),
    ],
//    controller: _tabController,
  );

//  var schoolsBuilder = Helper.createRows();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
//        drawer: Drawer(
//          child: Column(
//            children: <Widget>[
//              ListTile(
//                  title: Text("Page One"),
//                  trailing: Icon(
//                    Icons.arrow_upward,
//                    color: Colors.white,
//                  ),
//                  onTap: () {
//                    Navigator.of(context).pop();
//                    Navigator.of(context).pushNamed("/a");
//                  }),
//              ListTile(
//                title: Text("Page Two"),
//                trailing: Icon(
//                  Icons.arrow_downward,
//                  color: Colors.white,
//                ),
//                onTap: () {
////
//                },
//              ),
//              Divider(),
//              ListTile(
//                title: Text("Close"),
//                trailing: Icon(
//                  Icons.close,
//                  color: Colors.white,
//                ),
//                onTap: () => Navigator.of(context).pop(CloseButton),
//              ),
//              ListTile(
//                title: Text("about as"),
//                trailing: IconButton(
//                    icon: Icon(Icons.extension),
//                    color: Colors.white,
//                    onPressed: () {
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(builder: (context) => AboutUs()),
//                      );
//                    }),
//              ),
//            ],
//          ),
//        ),
        appBar: AppBar(
          backgroundColor: Colors.black,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(_tabBar.preferredSize.height - 50),
            child: _tabBar,
          ),
        ),
        backgroundColor: Colors.black,
        body: BlocProvider<WallpaperBloc>(
            bloc: _bloc,
            child: TabBarView(
              children: <Widget>[
                HomePage(),
                TabTwo(),
                TabThree(),
                TabFour(),
                TabFavourites(),
              ],
            )),
      ),
    );
  }

  String _toTwoDigitString(int value) {
    return value.toString().padLeft(2, '0');
  }
}
