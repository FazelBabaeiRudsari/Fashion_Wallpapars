import 'dart:typed_data';

import 'package:fashion_wallpapers/helper/variables.dart';
import 'package:fashion_wallpapers/model/wallpaper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';

class WallpaperCell extends StatelessWidget {
  const WallpaperCell(this.wallpaper);

  @required
  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.black /*MyTheme.COLOR['blue']*/,
      child: Padding(
        padding: EdgeInsets.only(bottom: 5.0),
        child: Container(
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Hero(
                    tag: "image${wallpaper.id}",
                    child: Container(
                        constraints: BoxConstraints.tightFor(
                            height: double.infinity, width: double.infinity),
                        child: TransitionToImage(
                          key: Key("1"),
                          fit: BoxFit.fill,
                          image: AdvancedNetworkImage(
                            Variable.STORAGE +
                                "/" +
                                wallpaper.group_id.toString() +
                                "/thumb-" +
                                wallpaper.path,
                            loadedCallback: () {},
                            loadFailedCallback: () {},
                            postProcessing: (Uint8List bytes) {
                              return null;
                            },
                            useDiskCache: true,
                            cacheRule:
                                CacheRule(maxAge: const Duration(days: 7)),
                            retryLimit: 2,
                            timeoutDuration: Duration(seconds: 5),
                          ),
                          loadingWidgetBuilder: (_, double progress, __) =>
                              Center(
                            child: CupertinoActivityIndicator(),
                          ),
                          placeholder: Center(
                            child: Icon(Icons.image, color: Colors.white),
                          ),
                        ))),
              ),
              Container(
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                  color: Colors.lightGreen,
                ),
                child: Text(
                  wallpaper.size / 1024 < 1
                      ? wallpaper.size.toString() + ' Kb'
                      : (wallpaper.size / 1024).toStringAsFixed(1) + ' Mb',
                  maxLines: 1,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getWallpaperImage(Wallpaper w) {
    if (w.path != null) {
      return Variable.STORAGE +
          '/' +
          w.group_id.toString() +
          '/thumb-' +
          w.path;
    } else {
      return Variable.DOMAIN + 'img/school-no.png';
    }
  }
}
