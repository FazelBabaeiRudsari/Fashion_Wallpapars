import 'dart:async';

import 'package:fashion_wallpapers/extra/loaders.dart';
import 'package:fashion_wallpapers/helper/WallpaperBloc.dart';
import 'package:fashion_wallpapers/helper/helper.dart';
import 'package:fashion_wallpapers/helper/variables.dart';
import 'package:fashion_wallpapers/model/wallpaper.dart';
import 'package:fashion_wallpapers/ui/gridcell.dart';
import 'package:fashion_wallpapers/ui/wallpaperdetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TabTwo extends StatefulWidget {
  @override
  _TabTwoState createState() => _TabTwoState();
}

class _TabTwoState extends State<TabTwo>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // StreamController<int> streamController = StreamController<int>();
  List<Wallpaper> wallpapers = List<Wallpaper>();

  WallpaperBloc _bloc;

  ScrollController _scrollController = ScrollController();

  _TabTwoState();

  bool loading = true;

  @override
  void initState() {
    print("init 2");
//    _bloc = BlocProvider.of<WallpaperBloc>(context);
    _bloc ??= WallpaperBloc();
    //   WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) => _refreshData(1));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
//        print('scroll');
        _refreshData(int.parse(Variable.params2['page']) + 1);
      }
    });
    //   Helper.getLocalStorage();
    super.initState();
  }

  @override
  void dispose() {
    print("dispose page 2");
    _scrollController.dispose();
    // streamController.close();
    super.dispose();
//    _bloc.dispose();
    // this.bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
//    final WallpaperBloc _bloc = BlocProvider.of<WallpaperBloc>(context);
    return RefreshIndicator(
      backgroundColor: Colors.white,
      onRefresh: () => _refreshData(1),
      child: StreamBuilder<List<Wallpaper>>(
        stream: _bloc.stream,
        builder:
            (BuildContext context, AsyncSnapshot<List<Wallpaper>> snapshot) {
          print(snapshot.connectionState);
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(
                child: Text(
                  Variable.DISCONNECTED,
                  style: TextStyle(color: Colors.white),
                ),
              );
            case ConnectionState.waiting:
              return Center(child: Loader());
            case ConnectionState.done:
              return Center(
                child: Text(
                  'done',
                  style: TextStyle(color: Colors.white),
                ),
              );
            case ConnectionState.active:
//            print(snapshot.data);
              if (snapshot.hasError || !snapshot.hasData) {
                return Container(
                    child: Center(
                        child: IconButton(
                  padding: EdgeInsets.all(10.0),
                  iconSize: MediaQuery.of(context).size.width / 6,
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _refreshData(1);
                  },
                )));
              } else {
                // streamController.sink.add(snapshot.data.length);
                // if(snapshot.data.length==0) return;R
                //  print(snapshot.data[0].id);
                wallpapers.addAll(snapshot.data);
                snapshot.data.clear();
//              print(wallpapers.length);

                return Column(
                  children: <Widget>[
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        itemCount: wallpapers.length,
                        itemBuilder: (BuildContext context, int index) {
                          // if (index ==
                          //         wallpapers
                          //             .length /*&&
                          //     Variable.TOTAL_WALLPAPERS > wallpapers.length*/
                          //     ) return CupertinoActivityIndicator();
                          return _grid(context, wallpapers[index]);
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: /* (orientation==Orientation.portrait)?2:*/ 3,
                            childAspectRatio: .8),
                      ),
                    ),
                    Visibility(
                      visible: loading,
                      child: CupertinoActivityIndicator(),
                    )
                  ],
                );
              }

              break;
            default:
              return Text('');
          }
        } //return to page 1
        ,
      ),
    );
  }

  Widget _grid(BuildContext context, Wallpaper wallpaper) {
    return GestureDetector(
      child: GridTile(
        child: WallpaperCell(wallpaper),
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          fullscreenDialog: true,
          maintainState: false,
          builder: (BuildContext context) => WallpaperDetails(
                wallpaper: wallpaper,
              ))),
      onLongPress: () {},
    );
  }

  Future<void> _refreshData(int page) async {
    // print(wallpapers.length.toString() +'|'+  Variable.TOTAL_WALLPAPERS.toString());
    if (page == 1) wallpapers.clear();
    if (Variable.TOTAL_WALLPAPERS['2'] > 0 &&
        wallpapers.length >= Variable.TOTAL_WALLPAPERS['2']) return;
    print('refresh');

    Variable.params2['page'] = page.toString();
    if (mounted)
      setState(() {
        loading = true;
      });
    else
      loading = true;
    _bloc.sink.add(await Helper.getWallpapers(context, Variable.params2));
    if (mounted)
      setState(() {
        loading = false;
      });
    else
      loading = false;
  }
}
