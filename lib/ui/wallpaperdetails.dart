import 'dart:async';
import 'dart:typed_data';

import 'package:fashion_wallpapers/extra/loaders.dart';
import 'package:fashion_wallpapers/helper/helper.dart';
import 'package:fashion_wallpapers/helper/variables.dart';
import 'package:fashion_wallpapers/model/wallpaper.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';

class WallpaperDetails extends StatefulWidget {
  final Wallpaper wallpaper;

  WallpaperDetails({@required this.wallpaper});

  @override
  _WallpaperDetailsState createState() => _WallpaperDetailsState();
}

class _WallpaperDetailsState extends State<WallpaperDetails> {
//  bool loadFailed = false;
  Uint8List bytes;
  InterstitialAd _interstitialAd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    print("init details");
    setTimerForAd();
//    _getWallpaperImage(widget.wallpaper);
  }

  void setTimerForAd() async {
    Helper.showAdTimes++;
    if (Helper.showAdTimes % 5 == 0 && await Helper.isNetworkConnected()) {
      Timer(Duration(seconds: 5), () {
        if (bytes == null) {
          _interstitialAd?.dispose();
          _interstitialAd = Helper.createInterstitialAd()..load();
          _interstitialAd?.show();
        }
      });
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Fashion Wallpapers",
          textAlign: TextAlign.center,
        ),
      ),
//      bottomNavigationBar: _getNavBar(context),
      backgroundColor: Colors.black,
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding:
              EdgeInsets.only(top: 30.0, right: 45.0, left: 45.0, bottom: 20.0),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                    tag: "image${widget.wallpaper.id}",
                    child: TransitionToImage(
                      duration: Duration(seconds: 0),
                      enableRefresh: true,
                      image: AdvancedNetworkImage(
                        Variable.STORAGE +
                            "/" +
                            widget.wallpaper.group_id.toString() +
                            "/" +
                            widget.wallpaper.path,
                        printError: false,
                        postProcessing: (Uint8List bytes) {
                          this.bytes = bytes;
                          return null;
                        },
                        loadedCallback: () {},
                        loadFailedCallback: () {},
                        loadedFromDiskCacheCallback: () {},
                        loadingProgress: (double progress, _) {},
                        useDiskCache: true,
                        disableMemoryCache: true,
                        cacheRule: CacheRule(maxAge: const Duration(days: 3)),
                        retryLimit: 1,
                        timeoutDuration: Duration(minutes: 2),
                      ),
                      loadingWidgetBuilder: (_, double progress, __) => Center(
                        child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              TransitionToImage(
                                key: Key("1"),
                                duration: Duration(seconds: 0),
                                width: double.infinity,
                                image: AdvancedNetworkImage(
                                    Variable.STORAGE +
                                        "/" +
                                        widget.wallpaper.group_id.toString() +
                                        "/thumb-" +
                                        widget.wallpaper.path,
                                    postProcessing: (Uint8List bytes) {
                                  return null;
                                }, disableMemoryCache: false),
                              ),

//                            CircularProgressIndicator(),
                              Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(.8),
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    (progress * 100).toStringAsFixed(0) + "%",
                                    style: TextStyle(color: Colors.white),
                                  ))
                            ]),
                      ),
                      placeholder: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 100.0),
                          ),
//                          Text("No Image Available!",
//                              style: TextStyle(
//                                  color: Colors.red,
//                                  fontWeight: FontWeight.bold)),
                          Center(
                            child: Icon(
                              Icons.refresh,
                              size: 100.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      fit: BoxFit.fitWidth,
                    )),
                SizedBox(
                  height: 30.0,
                ),
                OutlineButton(
                  color: Colors.white,
                  textColor: Colors.white,
                  borderSide: BorderSide(color: Colors.white),
                  child: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                OutlineButton(
                    color: Colors.white,
                    textColor: Colors.white,
                    borderSide: BorderSide(color: Colors.white),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.wallpaper),
                        Text('Set As Wallpaper')
                      ],
                    ),
                    onPressed: () {
                      if (bytes == null)
                        Helper.showMessage(context, "No Image Available !");
                      else
                        Helper.setImageAsWallpaper(
                            context, bytes, widget.wallpaper.path);
                    }),
                OutlineButton(
                    color: Colors.white,
                    textColor: Colors.white,
                    borderSide: BorderSide(color: Colors.white),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.favorite),
                        Text('Add To Favourites')
                      ],
                    ),
                    onPressed: () {
                      if (bytes == null)
                        Helper.showMessage(context, "No Image Available !");
                      else
                        Helper.addWallpaperToFavourites(
                            context, bytes, widget.wallpaper.path);
                    }),
                OutlineButton(
                    color: Colors.white,
                    textColor: Colors.white,
                    borderSide: BorderSide(color: Colors.white),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.share),
                        Text('Share Wallpaper')
                      ],
                    ),
                    onPressed: () {
                      if (bytes == null)
                        Helper.showMessage(context, "No Image Available !");
                      else
                        Helper.shareImage(
                            bytes, widget.wallpaper.path, context);
                    }),
                OutlineButton(
                    color: Colors.white,
                    textColor: Colors.white,
                    borderSide: BorderSide(color: Colors.white),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.file_download),
                        Text('Download Wallpaper')
                      ],
                    ),
                    onPressed: () {
                      if (bytes == null)
                        Helper.showMessage(context, "No Image Available !");
                      else
                        Helper.saveWallpaper(
                            context, bytes, widget.wallpaper.path);
                    }),
              ],
            ),
          ],
        );
      }),
    );
  }

  _getWallpaperImage(Wallpaper w) async {
//    var request = await HttpClient().getUrl(Uri.parse(
//        Variable.STORAGE + "/" + w.group_id.toString() + "/" + w.path));
//    var response = await request.close();
//    bytes = await contextsolidateHttpClientResponseBytes(response);
//
//    assetImage = AssetImage(bytes);
////        headers: {"header": "value"})
//    print('get Image');
//    return assetImage;
  }
}
