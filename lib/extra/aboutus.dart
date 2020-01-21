import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Fashion Wallpapers"),
      ),
      backgroundColor: Colors.black,
      body: Container(
        child: Align(
            alignment: Alignment.center,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {}, // handle your image tap here
                      child: Image.asset(
                        'images/fazel.jpg',
                        fit:
                            BoxFit.scaleDown, // this is the solution for border
                        width: 200.0,
                        height: 200.0,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "Mojtaba Mohammad Rajabi",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
                SizedBox(
                  height: 40.0,
                ),
                Column(
                  children: <Widget>[
                    InkWell(
                      // handle your image tap here
                      child: Image.asset(
                        'images/fazel.jpg',
                        fit:
                            BoxFit.scaleDown, // this is the solution for border
                        width: 200.0,
                        height: 200.0,
                      ),
                      onTap: () =>
                          launch('https://instagram.com/fazel.babaei.rudsari'),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "Fazel Babaei Rudsari",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
