import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:exif/exif.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'style/style.dart';
import 'sharedPrefs.dart';
import 'components/animatedButton.dart';
import 'package:sensors/sensors.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(
      MaterialApp(
        theme: ThemeData(
          backgroundColor: Styles.backgroundColor,
          primarySwatch: Styles.primaryThemeColor,

          //brightness: Brightness.light,
        ),
        debugShowCheckedModeBanner: false,
        home: CameraApp(),
      ),
    );
  });
  //runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  Future<void> _initializeControllerFuture;
  String iso_label = "-";
  String rounded_values = "";
  double speed_label;
  String blende_label = "-";
  int diff_label = 0;
  double iso_dropdown = 200.0;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool errorOccured = false;
  bool isInfoVisible = false;
  bool isSavedSettingsVisible = false;
  List<String> savedSettings = [];
  Future<List> savedFuture;
  ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  bool leftLandscape = false;
  Map<String, IfdTag> jpgdata;

  @override
  void initState() {
    super.initState();

    controller = CameraController(cameras[0], ResolutionPreset.low);
    //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    _initializeControllerFuture = controller.initialize();

    SharedPrefs.getIsoValue().then((double isoSharedValue) {
      if (isoSharedValue != null) {
        iso_dropdown = isoSharedValue;
      } else {
        iso_dropdown = 200.0;
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);*/

    //TOROL
    //SharedPrefs.deleteAllSettings();
    //print("ROUTE: .${ModalRoute.of(context).settings.name}.");
    savedFuture = SharedPrefs.getSavedSettings();
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x > 7 && event.y < 3 && event.y > -3) {
        leftLandscape = true;
        // print("+++EVENT ${leftLandscape}");
      } else if (event.y > 3 || event.y < -3) {
        leftLandscape = false;
        // print("+++EVENT ${leftLandscape}");
      } else {
        // print("+++EVENT ${event}");
      }
    });
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: new Scaffold(
        key: _scaffoldKey,
        //Here you can set what ever background color you need.
        backgroundColor: Colors.white,
        /*appBar: new AppBar(
          centerTitle: true,
          title: Text("CAMERA"),
        ),*/
        body:

            /*     Center(
            child: Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: <Widget>[
                    Container(color: Colors.yellow, child: Text("Camrea camera")),
                    Container(
                      //width: 300,
                      color: Colors.red,
                      child: AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: CameraPreview(controller)),
                    ),
                    FloatingActionButton(
                      child: Icon(Icons.camera_alt),
                      // Provide an onPressed callback.
                      onPressed: () async {
                        // Take the Picture in a try / catch block. If anything goes wrong,
                        // catch the error.
                        try {
                          // Ensure that the camera is initialized.
                          await _initializeControllerFuture;

                          // Construct the path where the image should be saved using the path
                          // package.
                          final path = join(
                            // Store the picture in the temp directory.
                            // Find the temp directory using the `path_provider` plugin.
                            (await getTemporaryDirectory()).path,
                            '${DateTime.now()}.png',
                          );

                          // Attempt to take a picture and log where it's been saved.
                          await _controller.takePicture(path);
                        } catch (e) {
                          // If an error occurs, log the error to the console.
                          print(e);
                        }
                      },
                    )
                  ],
                )),
          ),*/
            OrientationBuilder(builder: (context, orientation) {
          // NativeDeviceOrientation nativeDevOrientation = NativeDeviceOrientationReader.orientation(context);

          //print("orientation: ${MediaQuery.of(context).orientation}");
/*
      int turns;
      switch (orientation) {
        case NativeDeviceOrientation.landscapeLeft: turns = -1; break;
        case NativeDeviceOrientation.landscapeRight: turns = 1; break;
        case NativeDeviceOrientation.portraitDown: turns = 2; break;
        default: turns = 0; break;
      }*/
          /*  SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
          ]);*/
          return FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              final size = MediaQuery.of(context).size;
              //final deviceRatio = size.width / size.height;
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return Container(
                    //alignment: orientation == Orientation.landscape ? Alignment.bottomCenter : Alignment.centerRight,
                    alignment: Alignment.center,
                    color: Styles.backgroundColor,
                    child: Stack(
                      alignment: orientation == Orientation.landscape
                          ? Alignment.center
                          : Alignment.center,
                      children: <Widget>[
                        Column(
                          //crossAxisAlignment: orientation == Orientation.landscape ? CrossAxisAlignment.end : CrossAxisAlignment.end ,
                          mainAxisAlignment:
                              orientation == Orientation.landscape
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.center,
                          children: <Widget>[
                            /*if (deviceRatio < controller.value.aspectRatio &&
                                orientation == Orientation.portrait)
                              Container(height: 100),*/

                            Container(
                              padding: orientation == Orientation.portrait
                                  ? EdgeInsets.all(0)
                                  : EdgeInsets.only(right: 0),

                              //alignment:  orientation == Orientation.landscape ? Alignment.centerRight : Alignment.topCenter,
                              height: orientation == Orientation.landscape
                                  ? size.height
                                  : size.width *
                                      (1 / controller.value.aspectRatio),
                              width: orientation == Orientation.landscape
                                  ? size.height *
                                      (1 / controller.value.aspectRatio)
                                  : size.width,
                              child: AspectRatio(
                                aspectRatio: orientation == Orientation.portrait
                                    ? controller.value.aspectRatio
                                    : 1 / controller.value.aspectRatio,
                                child: orientation == Orientation.portrait
                                    ? Container(
                                        child: Stack(
                                          children: <Widget>[
                                            CameraPreview(controller),
                                          ],
                                        ),
                                      )
                                    : /*RotatedBox(
                                                
                                                    quarterTurns: 1,
                                                    child: CameraPreview(controller))
                                                    */

                                    //mainAxisAlignment: MainAxisAlignment.start,
                                    //crossAxisAlignment: CrossAxisAlignment.start,

                                    //Text("sad"),
                                    Container(
                                        // color: Colors.red,

                                        child: RotatedBox(
                                            quarterTurns:
                                                leftLandscape ? -1 : 1,
                                            child: Container(
                                                //width: 900,
                                                child: CameraPreview(controller)
                                                //Text("sdadasas")
                                                )),
                                      ),

                                // Container(width: 100,)

                                //),
                              ),
                            ),
                          ],
                        ),

                        // CameraPreview(controller),
                        /*Container(alignment: Alignment.bottomLeft,child:Text("XXXXX",style: TextStyle(
                                color: Colors.white, backgroundColor: Colors.blue),)),*/
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              //DIFF
                              /*Container(
                                alignment: Alignment.bottomLeft,
                                padding: EdgeInsets.only(left: 15, bottom: 15),
                                child: (diff_label != 0)
                                    ? Container(
                                        color: Colors.red,
                                        height: 40,
                                        width: 40,
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.wb_sunny),
                                            Text("${diff_label}"),
                                          ],
                                        ))
                                    : Text(""),
                              ),*/
                              //DIFF

                              if (diff_label != 0)
                                Container(
                                  padding: orientation == Orientation.landscape
                                      ? EdgeInsets.only(left: 16)
                                      : EdgeInsets.all(0),
                                  child: Container(
                                    padding: Styles.circlePadding,
                                    alignment: Alignment.bottomLeft,
                                    child: Container(
                                      //padding: Styles.circlePadding,

                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            diff_label >= 0
                                                ? Icon(Icons.wb_sunny,
                                                    size: 20,
                                                    color: Styles.diffTextColor)
                                                : Icon(Icons.lightbulb_outline,
                                                    size: 20,
                                                    color:
                                                        Styles.diffTextColor),
                                            Text(
                                              diff_label <= 0
                                                  ? "${diff_label}"
                                                  : "+${diff_label}",
                                              style: TextStyle(
                                                  color: Styles.diffTextColor),
                                            )
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          color: Styles.diffColor,
                                          shape: BoxShape.circle,
                                          /*border: Border.all(
                                              width: Styles.boxBorderWith,
                                              color: Styles.primaryColor),*/
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              /*/*Container(
                                padding: EdgeInsets.only(
                                    top: 15, left: 15, bottom: 15),
                                child: Text(
                                  "iso: ${iso_label.split(".")[0]}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.yellow),
                                ),
                              ),*/
                              Container(
                                padding: EdgeInsets.only(left: 15, bottom: 15),
                                child: Text(
                                  "speed: ${prettyTime(speed_label)}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.yellow),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 15, bottom: 15),
                                child: Text(
                                  "fNUmber: ${blende_label}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.yellow),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 15, bottom: 15),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "iso: ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          backgroundColor: Colors.yellow),
                                    ),
                                  ],
                                ),
                              ),*/

                              //ISO
                              Container(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      padding:
                                          (orientation == Orientation.landscape)
                                              ? EdgeInsets.only(left: 16)
                                              : EdgeInsets.all(0),
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            padding: Styles.circlePadding,
                                            alignment: Alignment.bottomLeft,
                                            child: Container(
                                                width: 60,
                                                height: 60,
                                                alignment: Alignment.center,
                                                //color: Colors.blue,
                                                //padding: SelectFormFieldStyle.boxPadding,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      width: 2.0,
                                                      color:
                                                          Styles.primaryColor),

                                                  // color: Color(0xFFe0f2f1)
                                                ),
                                                child: Stack(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 8),
                                                          child: Text("i s o",
                                                              style: TextStyle(
                                                                  color: Styles
                                                                      .primaryColor)),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          top: 20, left: 6),
                                                      height: 50,
                                                      width: 50,
                                                      //color: Colors.green,
                                                      alignment:
                                                          Alignment.center,
                                                      //color: Styles.primaryColor,
                                                      child: DropdownButton<
                                                          String>(
                                                        style: TextStyle(
                                                          color: Colors.black,

                                                          //t decoration: TextDecoration.underline,
                                                        ),

                                                        underline: Container(
                                                          height: 0.0,
                                                          decoration: const BoxDecoration(
                                                              border: Border(
                                                                  bottom: BorderSide(
                                                                      color: Colors
                                                                          .transparent,
                                                                      width:
                                                                          0.0))),
                                                        ),
                                                        /*value: iso_dropdown
                                                            .toString()
                                                            .split(".")[0],*/
                                                        value: null,
                                                        iconSize: 0,
                                                        icon: null,

                                                        isExpanded: true,
                                                        hint: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                              child: Text(
                                                                iso_dropdown
                                                                    .toString()
                                                                    .split(
                                                                        ".")[0],
                                                                style:
                                                                    TextStyle(
                                                                  color: Styles
                                                                      .primaryColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        //icon: Icon(Icons.arrow_downward),

                                                        /*decoration: InputDecoration(
                                                        ic
                                                      ),*/
                                                        //iconSize: 24,
                                                        // elevation: 16,

                                                        onChanged:
                                                            (String newValue) {
                                                          // value = newValue;
                                                          print("DD ONCAHNGE");
                                                          SharedPrefs
                                                              .setIsoValue(
                                                                  double.parse(
                                                                      newValue));

                                                          setState(() {
                                                            /*iso_dropdown =
                                                                double.parse(
                                                                    newValue);*/
                                                            SharedPrefs
                                                                    .getIsoValue()
                                                                .then((double
                                                                    isoSharedValue) {
                                                              iso_dropdown =
                                                                  isoSharedValue;
                                                            });
                                                            blende_label = "-";
                                                            speed_label = null;
                                                            diff_label = 0;
                                                          });
                                                          //onChangedHandler(newValue);
                                                        },
                                                        items: <String>[
                                                          "12",
                                                          "25",
                                                          "50",
                                                          "100",
                                                          "200",
                                                          "400",
                                                          "800",
                                                          "1600",
                                                          "3200",
                                                        ].map((String value) {
                                                          return new DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Center(
                                                                child: Text(
                                                              "${value}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            )),
                                                            //child: new Text("${value}"),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ],
                                                )

                                                /*Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text("i s o",
                                                      style: TextStyle(
                                                          color: Styles
                                                              .primaryColor)),
                                                  Container(
                                                    height: 16,
                                                    width: 26,
                                                    alignment: Alignment.center,
                                                    //color: Styles.primaryColor,
                                                    child: DropdownButton<String>(
                                                      
                                                      style: TextStyle(
                                                        color:
                                                            Styles.primaryColor,

                                                        //t decoration: TextDecoration.underline,
                                                      ),

                                                      /*underline: Container(
                                                        height: 0.0,
                                                        decoration: const BoxDecoration(
                                                            border: Border(
                                                                bottom: BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 0.0))),
                                                      ),*/
                                                      value: iso_dropdown
                                                          .toString()
                                                          .split(".")[0],

                                                      iconSize: 0,
                                                      icon: null,
                                                      
                                                      isExpanded: true,
                                                      //icon: Icon(Icons.arrow_downward),

                                                      /*decoration: InputDecoration(
                                                        ic
                                                      ),*/
                                                      //iconSize: 24,
                                                      // elevation: 16,

                                                      onChanged:
                                                          (String newValue) {
                                                        // value = newValue;
                                                        print("DD ONCAHNGE");
                                                        setState(() {
                                                          iso_dropdown =
                                                              double.parse(
                                                                  newValue);
                                                          blende_label = "-";
                                                          speed_label = null;
                                                          diff_label = 0;
                                                        });
                                                        //onChangedHandler(newValue);
                                                      },
                                                      items: <String>[
                                                        "50",
                                                        "100",
                                                        "200",
                                                        "400",
                                                        "800"
                                                      ].map((String value) {
                                                        return new DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Center(
                                                              child: Text(
                                                            "${value}",
                                                            textAlign:
                                                                TextAlign.center,
                                                          )),
                                                          //child: new Text("${value}"),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ],
                                              ),




                                              */
                                                ),
                                          ),
                                          //column
                                          if (orientation ==
                                              Orientation.landscape)
                                            speedContainer(speed_label),
                                          if (orientation ==
                                              Orientation.landscape)
                                            blendeContainer(blende_label),
                                          if (orientation ==
                                              Orientation.landscape)
                                            dofContainer(blende_label),
                                        ],
                                      ),
                                    ),
                                    //row
                                    if (orientation == Orientation.portrait)
                                      speedContainer(speed_label),
                                    if (orientation == Orientation.portrait)
                                      blendeContainer(blende_label),
                                    if (orientation == Orientation.portrait)
                                      dofContainer(blende_label),
                                  ],
                                ),
                              ),

                              /*if (orientation == Orientation.portrait)
                                                                    Container(
                                                                      //padding:EdgeInsets.only(left:100),
                                                                      margin:  const EdgeInsets.only(left: 120.0, ),
                                                                      width: 200,
                                                                      color: Colors.red,
                                                                      alignment: Alignment.center,
                                                                      child: Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          //SPEED
                                                                          speedContainer(speed_label),
                                      
                                                                          //BLENDE
                                                                          blendeContainer(blende_label),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  if (orientation == Orientation.landscape)
                                                                    Column(
                                                                      children: <Widget>[
                                                                        //SPEED
                                                                        speedContainer(speed_label),
                                      
                                                                        //BLENDE
                                                                        blendeContainer(blende_label),
                                                                      ],
                                                                    ),*/
                            ],
                          ),
                        ),
                        //LIGHTBLUE
                        Container(
                          /*width: orientation == Orientation.landscape
                              ? size.width
                              : size.width,*/
                          width: size.width,
                          padding: EdgeInsets.only(top: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment:
                                orientation == Orientation.landscape
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    orientation == Orientation.landscape
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: orientation == Orientation.portrait
                                        ? EdgeInsets.only(left: 0)
                                        : EdgeInsets.only(right: 32),
                                    child: Column(
                                      //mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Container(
                                            alignment: Alignment.bottomCenter,
                                            padding: orientation ==
                                                    Orientation.portrait
                                                ? EdgeInsets.only(
                                                    left: 20, top: 10)
                                                : EdgeInsets.only(left: 0),
                                            child: Image(
                                              image: AssetImage(
                                                  'images/horizont_logo_f.png'),
                                              height: 54,
                                              width: 54,
                                            )),
                                        if (orientation ==
                                            Orientation.landscape)
                                          Container(
                                              padding: EdgeInsets.only(top: 30),
                                              child: Container(
                                                  padding: (orientation ==
                                                          Orientation.portrait)
                                                      ? EdgeInsets.only(
                                                          right: 30)
                                                      : EdgeInsets.only(
                                                          right: 0),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: <Widget>[
                                                        GestureDetector(
                                                            child: Container(
                                                              height: 45,
                                                              width: 65,
                                                              child: Icon(
                                                                Icons.info,
                                                                color: Styles
                                                                    .primaryColor,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              setState(() {
                                                                isInfoVisible =
                                                                    true;
                                                              });
                                                            })
                                                      ]))),
                                      ],
                                    ),
                                  ),
                                  orientation == Orientation.portrait
                                      ? Container(
                                          padding: EdgeInsets.only(
                                              left: 10, right: 25, top: 10),
                                          child: Row(
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  /* Text(
                                                    "HORIZONT",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),*/
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        right: 80, top: 2),
                                                    child: Image(
                                                      image: AssetImage(
                                                          'images/horizont_sign_f.png'),
                                                      height: 26,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  orientation == Orientation.portrait
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                              //START

                                              Container(
                                                  padding: (orientation ==
                                                          Orientation.portrait)
                                                      ? EdgeInsets.only(
                                                          //right: 30,
                                                          top: 10,
                                                          left: 20)
                                                      : EdgeInsets.only(
                                                          right: 0),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: <Widget>[
                                                        GestureDetector(
                                                            /*backgroundColor:
                                                                Colors
                                                                    .transparent,*/
                                                            child: Container(
                                                              //padding: EdgeInsets.all(10),
                                                              height: 65,
                                                              width: 45,

                                                              child: Icon(
                                                                Icons.info,
                                                                size: 25,
                                                                color: Styles
                                                                    .primaryColor,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              setState(() {
                                                                isInfoVisible =
                                                                    true;
                                                              });
                                                            })
                                                      ]))

                                              //END
                                            ])
                                      : Container()
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (isInfoVisible)
                          Container(
                              color: Colors.black87,
                              child: Padding(
                                padding: (orientation == Orientation.portrait)
                                    ? EdgeInsets.only(left: 8.0, right: 8.0)
                                    : EdgeInsets.only(
                                        left: 100.0, right: 100.0),
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Container(
                                    /*padding: (orientation == Orientation.portrait)
                                ? EdgeInsets.only(top: 60)
                                : EdgeInsets.only(left: 100, right: 100, top: 20),*/
                                    //color:Colors.purple,
                                    //  child: ConstrainedBox(
                                    /*  constraints: BoxConstraints(
                                    maxHeight: (orientation ==
                                            Orientation.portrait)
                                        ? MediaQuery.of(context).size.height + 200
                                        : MediaQuery.of(context).size.height +
                                            700),*/
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Html(
                                          data: """
      <!--For a much more extensive example, look at example/main.dart-->
      <div>
        <h1  style="color:blue;">Horizont lightmeter</h1>
        <p>Lightmeter app for KMZ Horizont panoramic camera. The app contains the same settings as the camera.</p>
        <h2>Aperture:</h2>
        <p> f2.8-f16</p>
        <h2>Shutter speed:</h2>
        <p> 1/30-1/250</p>
        <h2>Sensitivity:</h2>
        <p> ISO 12 - 3200</p>
        <p>Iso value is changable, the lightmeter always calculates with as narrow aperture as possible, because of the fixed focus. So the speed changes only in f16, otherwise always remains 1/30. If the light is too less/much, the lightmeter shows the lowest/highest settings, and shows a marker, which contains the difference between the proper exposure and the actual value.</p>
        </br>
        <p>Note: </br>In some versions, where only 3 shutter speeds are marked, avoid using of the unmarked 1/250 speed, because it is uncalibrated!</p>


      </div>
  """,
                                          //Optional parameters:
                                          /* padding: orientation == Orientation.portrait
                                        ? EdgeInsets.only(left: 8, right: 8)
                                        : EdgeInsets.only(
                                            left: 120, right: 120),*/
                                          //backgroundColor: Colors.white70,
                                          defaultTextStyle:
                                              Styles.infoTextStyle,
                                          //linkStyle: const TextStyle(
                                          //  color: Colors.redAccent,),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 120.0),
                                          child: Html(
                                            data: """
  
  <div>
  
  <h1>DOF table</h1>
  
  <table>
  
      <tr>
  
        <th>Aperture</th>
  
        <th>Depth of field</th>
  
      </tr>
  
      <tr>
  
        <td>f2.8</td>
  
        <td>5.5m - ∞</td>
  
      </tr>
  
      <tr>
  
        <td>f4</td>
  
        <td>3.9m - ∞</td>
  
      </tr>
  
      <tr>
  
        <td>f5.6</td>
  
        <td>2.8m - ∞</td>
  
      </tr>
  
      <tr>
  
        <td>f8</td>
  
        <td>2m - ∞</td>
  
      </tr>
  
      <tr>
  
        <td>f11</td>
  
        <td>1.5m - ∞</td>
  
      </tr>
  
      <tr>
  
        <td>f16</td>
  
        <td>1m - ∞</td>
  
      </tr>
  
  
  
  </table>
  
  
  
        </div>
  
      """,

                                            //Optional parameters:

                                            /*  padding: orientation ==
                                              Orientation.portrait
                                          ? EdgeInsets.only(left: 8, right: 8)
                                          : EdgeInsets.only(
                                              left: 120, right: 120),
*/
                                            //backgroundColor: Colors.white70,

                                            defaultTextStyle:
                                                Styles.infoTextStyle,

                                            //linkStyle: const TextStyle(

                                            //  color: Colors.redAccent,),
                                          ),
                                        ),

                                        //saved settings button

                                        //back button
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.0),
                                                  child: GestureDetector(
                                                    //elevation: 0,
                                                    //color: Colors.transparent,
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                bottom: 8),
                                                        height: 30,
                                                        child: Text(
                                                          "HISTORY",
                                                          style: Styles
                                                              .colorButtonTextStyle,
                                                        )),
                                                    //textColor: Colors.white,
                                                    onTap: () {
                                                      setState(() {
                                                        isInfoVisible = false;
                                                        savedFuture = SharedPrefs
                                                            .getSavedSettings();
                                                        /*SharedPrefs
                                                                .getSavedSettings()
                                                            .then((List
                                                                savedSetts) {
                                                          savedSettings =
                                                              savedSetts;
                                                        });*/
                                                        isSavedSettingsVisible =
                                                            true;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: GestureDetector(
                                                //elevation: 0,
                                                //color: Colors.transparent,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: 10, bottom: 10),
                                                  //height: 30,
                                                  //width: 30,
                                                  child: Icon(
                                                    Icons.arrow_back,
                                                    size: 30.0,
                                                    color: Styles.primaryColor,
                                                  ),
                                                ),
                                                //textColor: Colors.white,
                                                onTap: () {
                                                  setState(() {
                                                    isInfoVisible = false;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    // )
                                  ),
                                ),
                              )),

                        //SAVED SETTINGS CONTAINER
                        if (isSavedSettingsVisible)
                          FutureBuilder(
                            future: savedFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Positioned.fill(
                                  child: Container(
                                      color: Styles.backgroundColor,
                                      width: 60,
                                      height: 60,
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                          height: 60.0,
                                          width: 60.0,
                                          child: SpinKitRing(
                                            color: Styles.primaryColor,
                                          ))),
                                );
                              } else if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                //  savedFuture.then((List value) {
                                //  setState(() {
                                savedSettings = snapshot.data;
                                //  });
                                return Container(
                                    color: Styles.backgroundColor,
                                    constraints: BoxConstraints.expand(),
                                    child: Column(children: <Widget>[
                                      Expanded(
                                          flex: 4,
                                          child: Container(
                                            padding: (orientation ==
                                                    Orientation.portrait)
                                                ? EdgeInsets.only(
                                                    left: 8.0,
                                                    right: 8.0,
                                                    top: 30)
                                                : EdgeInsets.only(
                                                    left: 100.0,
                                                    right: 100.0,
                                                    top: 22),
                                            alignment: Alignment.topCenter,
                                            constraints:
                                                BoxConstraints.expand(),
                                            child: SingleChildScrollView(
                                                child: Container(
                                                    child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                getPrettySetting(),

                                                /*Text(savedSettings.toString(),
                                            style: Styles.infoTextStyle)*/
                                              ],
                                            ))),
                                          )),
                                      Container(
                                        color: Colors.transparent,
                                        height: 50,
                                        padding: (orientation ==
                                                Orientation.portrait)
                                            ? EdgeInsets.only(bottom: 10)
                                            : EdgeInsets.only(
                                                bottom: 6,
                                                right: 100,
                                                left: 100),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            GestureDetector(
                                              //elevation: 0,
                                              // color: Colors.transparent,
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    bottom: 5, left: 15),
                                                //height: 30,
                                                //width: 30,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.delete,
                                                      size: 30.0,
                                                      color:
                                                          Styles.primaryColor,
                                                    ),
                                                    Text(
                                                      "CLEAR",
                                                      style: Styles
                                                          .colorButtonTextStyle,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              //textColor: Colors.white,
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible:
                                                      false, // user must tap button for close dialog!
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      //title: Text('Reset settings?'),
                                                      backgroundColor: Styles
                                                          .backgroundColor,
                                                      content: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 50,
                                                                left: 15),
                                                        height: 150,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          50),
                                                              child:
                                                                  GestureDetector(
                                                                //color: Colors.transparent,
                                                                child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        padding: EdgeInsets.only(
                                                                            right:
                                                                                10,
                                                                            left:
                                                                                20),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Styles.primaryColor,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                          'DELETE ALL',
                                                                          style:
                                                                              Styles.dialogButtonStyle),
                                                                    ]),
                                                                onTap: () {
                                                                  //Navigator.of(context).pop(ConfirmAction.CANCEL);
                                                                  print(
                                                                      "DELETE ALL");
                                                                  //isSavedSettingsVisible = false;
                                                                  //isInfoVisible = false;
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();

                                                                  print(
                                                                      "DELETE ALL");

                                                                  var a = SharedPrefs
                                                                      .deleteAllSettings();
                                                                  a.then((bool
                                                                      value) {
                                                                    setState(
                                                                        () {
                                                                      savedFuture =
                                                                          SharedPrefs
                                                                              .getSavedSettings();
                                                                    });
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            GestureDetector(
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            10,
                                                                        right:
                                                                            10),
                                                                child: Text(
                                                                    "CANCEL",
                                                                    style: TextStyle(
                                                                        color: Styles
                                                                            .primaryColor,
                                                                        fontWeight:
                                                                            FontWeight.w300)),
                                                              ),
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            GestureDetector(
                                              //elevation: 0,
                                              // color: Colors.transparent,
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    bottom: 5, right: 15),
                                                //height: 30,
                                                //width: 30,
                                                child: Icon(
                                                  Icons.arrow_back,
                                                  size: 30.0,
                                                  color: Styles.primaryColor,
                                                ),
                                              ),
                                              //textColor: Colors.white,
                                              onTap: () {
                                                setState(() {
                                                  isSavedSettingsVisible =
                                                      false;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]));

                                // });
                                // print("value: ${value}");

                              }
                            },
                          ),
                      ],
                    ));
              } else {
                // Otherwise, display a loading indicator.
                return Container(
                  color: Styles.backgroundColor,
                  child: Center(
                      child: Container(
                    alignment: Alignment.center,
                    child: SizedBox(
                        height: 60.0,
                        width: 60.0,
                        child: SpinKitRing(
                          color: Styles.primaryColor,
                        )
                        /*CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 2.0,
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Styles.primaryColor),
                          ),*/
                        ),
                  )),
                );
              }
            },
          );
        }),

        floatingActionButton: (!errorOccured &&
                !isInfoVisible &&
                !isSavedSettingsVisible)
            ? Padding(
                padding: const EdgeInsets.only(bottom: 20, right: 16),
                child: Container(
                  //color:Styles.backgroundColor,
                  width: 60,
                  height: 60,

                  child: AnimatedButton(
                    onTap: () async {
                      try {
                        final path = join(
                          (await getTemporaryDirectory()).path,
                          '${DateTime.now()}.jpg',
                        );

                        await controller.takePicture(path);

                        var f_number_new;
                        var speed_new;
                        var exp_time_new;
                        int diff;

                        File image_file = File(path);

                        try {
                          var exif = await readExifFromFile(image_file);

                          setState(() {
                            jpgdata = exif;
                          });
                        } catch (e, s) {
                          print(e);
                          print(s);
                        }

                        image_file.delete();
                        /*print("data: ${jpgdata}");
                        print(
                            "speed: ${jpgdata["EXIF ISOSpeedRatings"].values[0]}");
                        print(
                            "speed: ${jpgdata["EXIF ISOSpeedRatings"].values[0] is int}"); //true
                        print(
                            "exp_time: ${jpgdata["EXIF ExposureTime"].values[0]}");
                        print(
                            "exp_time: ${jpgdata["EXIF ExposureTime"].values[0] is String}"); //false
                        print("FNumber: ${jpgdata["EXIF FNumber"].values[0]}");
                        */
                        /*countString("1/2");
                                                                                            countString("1/100");
                                                                                            countString("1/0");*/

                        //print("FNumber: ${jpgdata["EXIF FNumber"].values[0]}"); //false

                        double f_number = 2;

                        // (f2 / camera f-number)
                        double b = 2 /
                            countString(
                                jpgdata["EXIF FNumber"].values[0].toString());
                        //print("b: ${b}");
                        //print("exp_time: ${countString(jpgdata["EXIF ExposureTime"].values[0].toString())}");
                        double exp_time = countString(
                            jpgdata["EXIF ExposureTime"].values[0].toString());
                        //print("speed: ${jpgdata["EXIF ISOSpeedRatings"].values[0] * b}");

                        double speed =
                            jpgdata["EXIF ISOSpeedRatings"].values[0] * 1.111;

                        List<double> speeds = [
                          1 / 1000,
                          1 / 500,
                          1 / 250,
                          1 / 125,
                          1 / 60,
                          1 / 30,
                          1 / 15,
                          1 / 8,
                          1 / 4,
                          1 / 2,
                          1.0,
                        ];

                        List<double> blende = [
                          0.7,
                          1,
                          1.4,
                          2,
                          2.8,
                          4,
                          5.6,
                          8,
                          11,
                          16,
                          22,
                          32,
                          45,
                          64,
                          91,
                          128
                        ];

                        List<double> isos = [
                          12,
                          25,
                          50,
                          100,
                          200,
                          400,
                          800,
                          1600,
                          3200,
                          6400,
                          12500,
                          25000
                        ];
                        List<double> kmz_blende = [2.8, 4, 5.6, 8, 11, 16];

                        List<double> kmz_speeds = [
                          1 / 30,
                          1 / 60,
                          1 / 125,
                          1 / 250
                        ];

                        List<double> kmz_isos = [
                          12,
                          25,
                          50,
                          100,
                          200,
                          400,
                          800,
                          1600,
                          3200
                        ];

                        //print("____rounded:_____");
                        f_number_new = round(blende, f_number, false);
                        print("f_number_new ${f_number_new}");
                        speed_new = round(isos, speed, false);
                        print("speed_new ${speed_new}");
                        exp_time_new = round(speeds, exp_time, false);
                        print("exp_time_new ${exp_time_new}");

                        int completeDiff = completeDifference(
                          isos,
                          blende,
                          speeds,
                          iso_dropdown,
                          speed_new,
                          16.0,
                          f_number_new,
                          1 / 250,
                          exp_time_new,
                        );
                        /*if (completeDiff < 0) {
                        }
                        */
                        String roundedValues = [
                          prettyTime(exp_time_new).toString(),
                          f_number_new.toString(),
                          speed_new.toString(),
                        ].join(",");

                        // diff between rounded and biggest kmz value

                        diff = difference(isos, speed_new, iso_dropdown);
                        print("diff: ${diff}");
                        speed_new = iso_dropdown;
                        int blende_diff =
                            difference(blende, 16.0, f_number_new);
                        print("diff2: ${blende_diff}");
                        diff += blende_diff;
                        f_number_new = 16.0;
                        var hasValue = false;
                        var actual_speed;
                        if ((diff != 0 ||
                            (!(kmz_blende.contains(f_number_new)) ||
                                !(kmz_isos.contains(speed_new)) ||
                                !(kmz_speeds.contains(exp_time_new))))) {
                          for (int i = kmz_blende.length - 1;
                              i >= 0 && !hasValue;
                              i--) {
                            f_number_new = kmz_blende[i];
                            print("f_number_new: ${f_number_new}");
                            for (int j = 0;
                                j < kmz_speeds.length && !hasValue;
                                j++) {
                              if (difference(speeds, exp_time_new,
                                      kmz_speeds.reversed.toList()[j]) ==
                                  (diff * -1)) {
                                diff = 0;
                                print("!!!");
                                hasValue = true;
                              }
                              //ha tul nagy a feny
                              /*else if (j==0 && i == kmz_blende.length - 1 && completeDifference(isos, blende, time, )) {
                                                                            
                                                                                                      }*/
                              actual_speed = kmz_speeds.reversed.toList()[j];
                              //exp_time_new = kmz_speeds.reversed.toList()[j];
                            }
                            if (diff != 0) {
                              if (i == 0) {
                                diff += difference(
                                    speeds, exp_time_new, actual_speed);
                                //over = true;
                                //exp_time_new = kmz_speeds[0]
                              } else {
                                diff += 1;
                              }
                            }
                          }
                        }

                        print("DIFFERENCE: ${diff}");
                        exp_time_new = actual_speed;
                        print("++++++");
                        print("speed: ${exp_time_new}");
                        print("iso: ${speed_new}");
                        print("blende: ${f_number_new}");
                        print("++++++");

                        setState(() {
                          // ha a becsult ertek kisebb mint (iso, 16.0, 1/250)
                          if (completeDiff < 0) {
                            print("TUL SOK FENY");
                            iso_label = speed_new.toString();
                            speed_label = 1 / 250;
                            blende_label = "16.0";
                            diff_label = (-1 * completeDiff);
                            rounded_values = roundedValues;
                          } else {
                            iso_label = speed_new.toString();
                            speed_label = exp_time_new;
                            blende_label = f_number_new.toString();
                            diff_label = diff;
                            rounded_values = roundedValues;
                          }
                        });

                        var phoneAndRounded = [
                          "${jpgdata["EXIF ExposureTime"].values[0]}" +
                              " -> " +
                              roundedValues.split(",")[0].trim(),
                          "${prettyAperture(jpgdata["EXIF FNumber"].values[0].toString())}" +
                              " -> " +
                              prettyAperture(
                                  roundedValues.split(",")[1].trim()),
                          "${jpgdata["EXIF ISOSpeedRatings"].values[0]}" +
                              " -> " +
                              roundedValues.split(",")[2].trim()
                        ];
                        //SAVE SETTINGS
                        SharedPrefs.addSavedSettings([
                          "time:" + DateTime.now().toString(),
                          "rounded",
                          phoneAndRounded.join(","),
                          "kmz",
                          [
                            prettyTime(speed_label).toString(),
                            "f" + blende_label,
                            iso_label,
                            "diff: " + diff_label.toString()
                          ].join(","),
                          "my",
                          [
                            prettyTime(speed_label).toString(),
                            "f" + blende_label,
                            iso_label
                          ].join(","),
                          "note",
                          "-"
                        ].join("; "));

                        /*SharedPrefs.getSavedSettings().then((List savedSettings) {
                          if (savedSettings != null) {
                            print("PREV SETTINGS: " + savedSettings.toString());
                          }
                        });*/
                      } catch (e, s) {
                        // If an error occurs, log the error to the console.
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(
                            content: Container(
                          height: 110,
                          child: new Text(
                            'Error occured! Please restart the app!',
                            style: TextStyle(color: Styles.primaryColor),
                          ),
                        )));
                        setState(() {
                          diff_label = 0;
                          errorOccured = true;
                        });
                        print("error:_${e}");
                        print("error stack:_${s}");
                        print("RESTART APP");
                        runApp(
                          MaterialApp(
                            theme: ThemeData(
                              backgroundColor: Styles.backgroundColor,
                              primarySwatch: Styles.primaryThemeColor,

                              //brightness: Brightness.light,
                            ),
                            debugShowCheckedModeBanner: false,
                            home: CameraApp(),
                          ),
                        );
                      }
                    },
                    animationDuration: const Duration(milliseconds: 500),
                    initialText: "Confirm",
                    finalText: "Submitted",
                    iconData: Icons.trip_origin,
                    enabled: !errorOccured,
                    iconSize: 32.0,
                    buttonStyle: ButtonStyle(
                      primaryColor: Styles.buttonColor,
                      secondaryColor: Colors.grey,
                      iconColor: Colors.white,
                      elevation: 20.0,
                      initialTextStyle: TextStyle(
                        fontSize: 22.0,
                        color: Colors.white,
                      ),
                      finalTextStyle: TextStyle(
                        fontSize: 22.0,
                        color: Colors.green.shade600,
                      ),
                      borderRadius: 30.0,
                    ),
                  ),
                ),
              )
            : Container(),
      ),
    );
  }

  Widget getPrettySetting() {
    List<Widget> containerList = new List<Widget>();
    print("PRETTY RELOAD");
//    savedSettings = [];
/*
     list.then((List value) {
       savedSettings = value;
       print("value: ${value}");
    });
  */
    //SharedPrefs.getSavedSettings().then((List savedSetts) {
    if (savedSettings != null && savedSettings != []) {
      //widget.setState(() {
      //savedSettings = data;
      //});
      print("PRETTY SETTINGS: " + savedSettings.toString());
      //savedSettings = savedSettings;

      String category = "";
      int i = 0;
      print("SAVEDSETTINGS: ${savedSettings}");
      for (var setting in savedSettings) {
        i++;
        int j = 0;
        List<Widget> widgetList = new List<Widget>();
        for (String item in setting.split(";")) {
          j++;
          //print("." + item.toString());
          if (category == "kmz" || category == "rounded") {
            category = "";
            continue;
          }
          if (item.startsWith("time")) {
            category = "time";
            var dateTaken = item.split("time:")[1];
            widgetList.add(Container(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    Text(dateTaken.split(".")[0], style: Styles.settingsDate),
                    Container(
                      width: 40,
                      child: GestureDetector(
                        // elevation: 0,
                        //color: Colors.transparent,
                        child: Container(
                          child: Icon(
                            Icons.edit,
                            color: Styles.primaryColor,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible:
                                false, // user must tap button for close dialog!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                //title: Text('Reset settings?'),
                                backgroundColor: Styles.backgroundColor,
                                content: Container(
                                  padding: EdgeInsets.only(top: 30),
                                  height: 200,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(bottom: 50),
                                        child: GestureDetector(
                                          //color: Colors.transparent,
                                          child: Row(children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                  right: 10, left: 20),
                                              child: Icon(
                                                Icons.edit,
                                                color: Styles.primaryColor,
                                              ),
                                            ),
                                            Text('EDIT/INFO',
                                                style:
                                                    Styles.dialogButtonStyle),
                                          ]),
                                          onTap: () {
                                            //Navigator.of(context).pop(ConfirmAction.CANCEL);
                                            print("EDIT clicked");
                                            //isSavedSettingsVisible = false;
                                            //isInfoVisible = false;
                                            Navigator.of(context).pop();
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              //print("ONTAP CONTAINER ${setting}");
                                              //print("ONTAP CONTAINER NUM ${i}");
                                              //isSavedSettingsVisible = false;
                                              return DisplayEditScreen(
                                                  //setting, getSettingNumber(setting, savedSettings));
                                                  setting,
                                                  (savedSettings
                                                          .indexOf(setting) +
                                                      1));
                                            }));
                                          },
                                        ),
                                      ),
                                      GestureDetector(
                                        child: Row(children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.only(
                                                right: 10, left: 20),
                                            child: Icon(
                                              Icons.delete,
                                              color: Styles.primaryColor,
                                            ),
                                          ),
                                          Text('DELETE',
                                              style: Styles.dialogButtonStyle),
                                        ]),
                                        onTap: () {
                                          print("DELETE clicked");
                                          Navigator.of(context).pop();
                                          var a = SharedPrefs.deleteSettings(
                                              dateTaken);
                                          a.then((bool value) {
                                            setState(() {
                                              savedFuture = SharedPrefs
                                                  .getSavedSettings();
                                            });
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              bottom: 10, right: 10),
                                          child: Text("CANCEL",
                                              style: TextStyle(
                                                  color: Styles.primaryColor,
                                                  fontWeight: FontWeight.w300)),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              );
                            },
                          );
                        },
                        /*onPressed: () {
                            var a = SharedPrefs.deleteSettings(dateTaken);
                            a.then((bool value) {
                              setState(() {
                                savedFuture = SharedPrefs.getSavedSettings();
                              });
                            });
                          }*/
                      ),
                    )
                  ],
                )));
          } else {
            var title = "";
            if (item.trim() == "my") {
              title = "MY SETTING:";
              category = "my";
              widgetList.add(Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                child: Text(title, style: Styles.settingsTitle),
              ));
            } else if (item.trim() == "rounded") {
              category = "rounded";
              continue;
              //title = "Phone settings(rounded):";
              //widgetList.add(Text(title, style: Styles.settingsTitle));
            } else if (item.trim() == "kmz") {
              category = "kmz";
              continue;
              //title = "Calculated:";
              //widgetList.add(Text(title, style: Styles.settingsTitle));
            } else if (item.trim() == "note") {
              category = "note";
              title = "NOTE:";
              widgetList.add(Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                child: Text(title, style: Styles.settingsTitle),
              ));
            } else {
              //print("____ ${item}");

              for (var val in item.split(",").map((_) => _.trim()).toList()) {
                widgetList.add(Container(
                    padding: EdgeInsets.only(left: 16, bottom: 6),
                    child: Text(/*"· " +*/ val.split(".0")[0],
                        style: Styles.settingsValues)));
              }
            }
          }
          if (setting.split(";").length == j) {
            Widget cont = new Stack(children: <Widget>[
              Positioned(
                child: Text(
                  i.toString(),
                  style: TextStyle(
                      color: Colors.white12,
                      fontSize: 170,
                      fontWeight: FontWeight.w700),
                ),
                bottom: -30.0,
                right: 10.0,
              ),
              GestureDetector(
                onTap: () {
                  /*print("Container clicked");
                  //isSavedSettingsVisible = false;
                  //isInfoVisible = false;
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    print("ONTAP CONTAINER ${setting}");
                    print("ONTAP CONTAINER NUM ${i}");
                    //isSavedSettingsVisible = false;
                    return DisplayEditScreen(
                        //setting, getSettingNumber(setting, savedSettings));
                        setting,
                        (savedSettings.indexOf(setting) + 1));
                  }));
                  */
                },
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widgetList),
              ),
            ]);
            containerList.add(cont);
          }
        }
      }
    } else {
      print("NULL");
    }
    //});
    //sleep(Duration(seconds: 2));
    if (containerList.length > 0) {
      return new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: containerList);
    }
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(top: 150),
              //color: Colors.red,
              //constraints: BoxConstraints.expand(),
              child:
                  Text("NO HISTORY ITEMS", style: Styles.colorButtonTextStyle))
        ]);
  }
}

/*
int getSettingNumber(String setting, List<String> savedSettings) {
  String dateTaken = setting.split(";")[0];
  int i = 1;
  for (var sett in savedSettings) {
    if (sett.contains(dateTaken)) {
      return i;
    }
    i++;
  }

  return null;
}*/
/*
Widget infoButton(BuildContext context, Orientation orientation) {
  return Container(
    padding: (orientation == Orientation.portrait)
        ? EdgeInsets.only(right: 30)
        : EdgeInsets.only(right: 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          color: Colors.yellow,
          height: 100,
          width: 100,
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.train,
              color: Styles.primaryColor,
            ),
            onPressed: () {
              print("info pressed");
              if (orientation == Orientation.portrait) {
                showGeneralDialog(
                    context: context,
                    barrierColor:
                        Colors.black12.withOpacity(0.8), // background color
                    barrierDismissible:
                        false, // should dialog be dismissed when tapped outside
                    //barrierLabel: "Dialog", // label for barrier
                    transitionDuration: Duration(
                        milliseconds:
                            400), // how long it takes to popup dialog after button click
                    pageBuilder: (context, __, ___) {
                      // your widget implementation
                      return Text("PORTRAIT");
                    });
              } else {
                showGeneralDialog(
                  context: context,

                  barrierColor: Styles.backgroundColor,
                  //Colors.black12.withOpacity(0.8), // background color
                  barrierDismissible:
                      false, // should dialog be dismissed when tapped outside
                  //barrierLabel: "Dialog", // label for barrier
                  transitionDuration: Duration(
                      milliseconds:
                          400), // how long it takes to popup dialog after button click
                  pageBuilder: (context, __, ___) {
                    // your widget implementation
                    return Text("LANDSCAPE");

                    /*Padding(
                    padding: (orientation == Orientation.portrait)
                        ? EdgeInsets.only(left: 8.0, right: 8.0)
                        : EdgeInsets.only(left: 30.0, right: 30.0),
                    child: SingleChildScrollView(
                      child: Container(
                          /*padding: (orientation == Orientation.portrait)
                              ? EdgeInsets.only(top: 60)
                              : EdgeInsets.only(left: 100, right: 100, top: 20),*/
                          //color:Colors.purple,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: (orientation == Orientation.portrait)
                                    ? MediaQuery.of(context).size.height + 200
                                    : MediaQuery.of(context).size.height + 700),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: (orientation == Orientation.portrait)
                                      ? 0
                                      : 120,
                                  right: (orientation == Orientation.portrait)
                                      ? 0
                                      : 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                //crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Html(
                                    data: """
    <!--For a much more extensive example, look at example/main.dart-->
    <div>
      <h1  style="color:blue;">Lightmeter for KMZ Horizont camera</h1>
      <p>Lightmeter app for KMZ Horizont panoramic camera. The app contains the same settings as the camera.</p>
      <h2>Aperture:</h2>
      <p> f2.8-f16</p>
      <h2>Shutter speed:</h2>
      <p> 1/30-1/250</p>
      <h2>Sensitivity:</h2>
      <p> ISO 50 - 800</p>
      <p>Iso value is changable, the lightmeter always calculate with the smallest aperture, because of the fixed focus. So the speed changes only in f16. If the light is too less/much, the lightmeter shows the lowest/highest settings, and shows a red marker, which contains the difference between the lowest and the actual value.</p>



    </div>
  """,
                                    //Optional parameters:
                                   /* padding: orientation == Orientation.portrait
                                        ? EdgeInsets.only(left: 8, right: 8)
                                        : EdgeInsets.only(
                                            left: 120, right: 120),*/
                                    //backgroundColor: Colors.white70,
                                    defaultTextStyle: Styles.infoTextStyle,
                                    //linkStyle: const TextStyle(
                                    //  color: Colors.redAccent,),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(right: 120.0),
                                    child: Html(
                                      data: """
  
  <div>
  
  <h1>DOF table</h1>
  
  <table>
  
    <tr>
  
      <th>Aperture</th>
  
      <th>Depth of field</th>
  
    </tr>
  
    <tr>
  
      <td>f2.8</td>
  
      <td>5.5m - ∞</td>
  
    </tr>
  
    <tr>
  
      <td>f4</td>
  
      <td>3.9m - ∞</td>
  
    </tr>
  
    <tr>
  
      <td>f5.6</td>
  
      <td>2.8m - ∞</td>
  
    </tr>
  
    <tr>
  
      <td>f8</td>
  
      <td>2m - ∞</td>
  
    </tr>
  
    <tr>
  
      <td>f11</td>
  
      <td>1.5m - ∞</td>
  
    </tr>
  
    <tr>
  
      <td>f16</td>
  
      <td>1m - ∞</td>
  
    </tr>
  
  
  
  </table>
  
  
  
      </div>
  
    """,

                                      //Optional parameters:

                                    /*  padding: orientation ==
                                              Orientation.portrait
                                          ? EdgeInsets.only(left: 8, right: 8)
                                          : EdgeInsets.only(
                                              left: 120, right: 120),
*/
                                      //backgroundColor: Colors.white70,

                                      defaultTextStyle: Styles.infoTextStyle,

                                      //linkStyle: const TextStyle(

                                      //  color: Colors.redAccent,),
                                    ),
                                  ),

                                  //back button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      RaisedButton(
                                        color: Colors.transparent,
                                        child: Container(
                                          height: 30,
                                          width: 60,
                                          child: Icon(
                                            Icons.arrow_back,
                                            color: Styles.primaryColor,
                                          ),
                                        ),
                                        textColor: Colors.white,
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )),
                    ),
                  );*/
                  },
                );
              }
            },
          ),
        ),
      ],
    ),
  );
}
*/
Widget dofContainer(String blende_label) {
  return Container(
    padding: Styles.circlePadding,
    child: Container(
      width: 60,
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.landscape, size: 20, color: Styles.primaryColor),
          Text(
            getDistance(blende_label),
            style: TextStyle(color: Styles.primaryColor),
          )
        ],
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(width: Styles.boxBorderWith, color: Styles.primaryColor),
      ),
    ),
  );
}

String getDistance(String blende_label) {
  // 2.8, 4, 5.6, 8, 11, 16
  if (blende_label == "2.8") return "5.5m-";
  if (blende_label == "4.0") return "3.8m-";
  if (blende_label == "5.6") return "2.9m-";
  if (blende_label == "8.0") return "2m-";
  if (blende_label == "11.0") return "1.5m-";
  if (blende_label == "16.0")
    return "1m-";
  else
    return "-";
}

Widget blendeContainer(String blende_label) {
  return Container(
    padding: Styles.circlePadding,
    child: Container(
      width: 60,
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.camera, size: 20, color: Styles.primaryColor),
          Text(
            "${blende_label}",
            style: TextStyle(color: Styles.primaryColor),
          )
        ],
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(width: Styles.boxBorderWith, color: Styles.primaryColor),
      ),
    ),
  );
}

Widget speedContainer(double speed_label) {
  return Container(
    padding: Styles.circlePadding,
    child: Container(
      width: 60,
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.shutter_speed, size: 20, color: Styles.primaryColor),
          Text(
            "${prettyTime(speed_label)}",
            style: TextStyle(color: Styles.primaryColor),
          )
        ],
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(width: Styles.boxBorderWith, color: Styles.primaryColor),
      ),
    ),
  );
}

double round(List a, value, bool down) {
  double int_value = value.toDouble();
  int i = 0;
  while (int_value >= a[i] && i < a.length - 1) {
    i++;
  }
  if (i > 0) {
    if (((a[i] + a[i - 1]) / 2.0) > int_value) {
      //print("ertek1: ${int_value}, kerek: ${a[i - 1]}");
      return a[i - 1];
    }
  }

  //for (int i = 0; i < a.length; i++) {

  //print("ertek2: ${int_value}, kerek: ${a[i]}");

  return a[i];
}

int difference(List list, val1, val2) {
  var v1;
  var v2;
  bool minus = false;
  if (val1 <= val2) {
    v1 = val1;
    v2 = val2;
  } else {
    v1 = val2;
    v2 = val1;
    minus = true;
  }
  int diff_num = 0;
  int i = 0;
  while (v2 >= list[i]) {
    if (v1 < list[i]) {
      diff_num++;
    }
    i++;
  }
  return minus ? diff_num * -1 : diff_num;
}

double countString(String inputString) {
  if (inputString.contains("/")) {
    var splitted = inputString.split("/");

    return double.parse(splitted[0]) / double.parse(splitted[1]);
  } else {
    return double.parse(inputString);
  }
}

int completeDifference(

    /// Difference between values:(iso1, blende1, time1) and values:(iso2, blende2, time2).
    /// returns a negative value, if the second three value has less light than the first

    List isoList,
    List blendeList,
    List timeList,
    double iso1,
    double iso2,
    double blende1,
    double blende2,
    double time1,
    double time2) {
  var isoDiff = difference(isoList, iso1, iso2);
  var blendeDiff = difference(blendeList, blende1, blende2);
  var timeDiff = difference(timeList, time1, time2);

  return isoDiff - blendeDiff + timeDiff;
}

class DisplayEditScreen extends StatefulWidget {
  final String _setting;
  final int _number;

  DisplayEditScreen(this._setting, this._number, {Key key}) : super(key: key);

  @override
  _DisplayEditScreenState createState() =>
      _DisplayEditScreenState(_setting, _number);
}

class _DisplayEditScreenState extends State<DisplayEditScreen> {
  final String _setting;
  final int _number;
  String shSpeed;
  String aperture;
  String iso;
  String note = "";
  String timeTaken;
  String origSettings;
  String horizontSettings;
  String mySettings;
  List<String> mySettingsList;
  final _formKey = GlobalKey<FormState>();
  Map _formdata = new Map();

  _DisplayEditScreenState(this._setting, this._number);

  @override
  void initState() {
    super.initState();

    List<String> settingList =
        _setting.split(";").map((_) => _.trim()).toList();
    // TODO map trim on settingslist
    setState(() {
      origSettings = settingList[2];
      horizontSettings = settingList[4];
      mySettings = settingList[6];
      mySettingsList = mySettings.split(",");
      timeTaken = settingList[0].split("time:")[1];
      shSpeed = mySettingsList[0].trim();
      aperture = mySettingsList[1].trim();
      iso = mySettingsList[2].trim();

      note = settingList[8].trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Styles.backgroundColor,
        body: OrientationBuilder(builder: (context, orientation) {
          return Container(
            child: SingleChildScrollView(
              child: Stack(children: <Widget>[
                Container(
                  color: Styles.backgroundColor,
                  padding: orientation == Orientation.portrait
                      ? EdgeInsets.only(top: 50, left: 10)
                      : EdgeInsets.only(top: 30, left: 120, right: 120),
                  alignment: Alignment.topLeft,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "TIME TAKEN",
                            style: TextStyle(
                              color: Styles.editTextColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Text(
                          " " + timeTaken.split(".")[0],
                          style: TextStyle(
                              color: Styles.editTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: Text(
                            "MY SETTINGS",
                            style: TextStyle(
                              color: Styles.editTextColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Text(
                          "Shutter speed",
                          style: TextStyle(
                              color: Styles.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            color: Styles.editFieldBackgroundColor,
                            padding: Styles.editFieldPadding,
                            width: 120,
                            child: TextFormField(
                              style: TextStyle(color: Styles.editTextColor),
                              cursorColor: Styles.primaryColor,
                              decoration: InputDecoration(
                                focusColor: Styles.primaryColor,
                                contentPadding: Styles.formFieldPadding,

                                //fillColor: Colors.yellow,
                                //labelStyle:
                                //    TextStyle(color: Colors.white, fontSize: 16,),
                                //labelText: "shutter speed",
                              ),
                              //controller: TextEditingController(text: shSpeed),
                              initialValue: shSpeed,
                              autovalidate: true,
                              validator: (val) {
                                if (val.length != 0 &&
                                    !RegExp(r'^[a-zA-Z0-9./ ]+$')
                                        .hasMatch(val)) {
                                  return 'Use only letters and numbers!';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _formdata["shutter"] = value;
                              },
                            ),
                          ),
                        ),
                        Text(
                          "Aperture",
                          style: TextStyle(
                              color: Styles.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            color: Styles.editFieldBackgroundColor,
                            padding: Styles.editFieldPadding,
                            width: 120,
                            child: TextFormField(
                              style: TextStyle(color: Styles.editTextColor),
                              cursorColor: Styles.primaryColor,
                              decoration: InputDecoration(
                                focusColor: Styles.primaryColor,
                                contentPadding: Styles.formFieldPadding,
                                //fillColor: Colors.yellow,
                                //labelStyle:
                                //    TextStyle(color: Colors.white, fontSize: 16,),
                                //labelText: "shutter speed",
                              ),
                              initialValue: aperture.split(".0")[0],
                              autovalidate: true,
                              validator: (val) {
                                if (val.length != 0 &&
                                    !RegExp(r'^[a-zA-Z0-9. ]+$')
                                        .hasMatch(val)) {
                                  return 'Use only letters and numbers!';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _formdata["aperture"] = value;
                              },
                            ),
                          ),
                        ),
                        Text(
                          "ISO",
                          style: TextStyle(
                              color: Styles.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            color: Styles.editFieldBackgroundColor,
                            padding: Styles.editFieldPadding,
                            width: 120,
                            child: TextFormField(
                              style: TextStyle(color: Styles.editTextColor),
                              cursorColor: Styles.primaryColor,
                              decoration: InputDecoration(
                                focusColor: Styles.primaryColor,
                                contentPadding: Styles.formFieldPadding,
                                //fillColor: Colors.yellow,
                                //labelStyle:
                                //    TextStyle(color: Colors.white, fontSize: 16,),
                                //labelText: "shutter speed",
                              ),
                              initialValue: iso.split(".")[0],
                              autovalidate: true,
                              validator: (val) {
                                if (val.length != 0 &&
                                    !RegExp(r'^[a-zA-Z0-9. ]+$')
                                        .hasMatch(val)) {
                                  return 'Use only letters and numbers!';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _formdata["iso"] = value;
                              },
                            ),
                          ),
                        ),
                        Text(
                          "Note",
                          style: TextStyle(
                              color: Styles.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            //color: Styles.editFieldBackgroundColor,
                            padding: Styles.editFieldPadding,
                            width: 240,
                            //height:60,
                            child: TextFormField(
                              style: TextStyle(color: Styles.editTextColor),
                              cursorColor: Styles.primaryColor,
                              autovalidate: true,
                              decoration: InputDecoration(
                                focusColor: Styles.primaryColor,
                                contentPadding: Styles.formFieldPadding,
                                border: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                //errorStyle: TextStyle(color:Colors.white),
                                filled: true,
                                errorBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Styles.formErrorColor),
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                focusedErrorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Styles.formErrorColor, width: 2),
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                //borderRadius: BorderRadius.circular(0.0),),
                                errorStyle:
                                    TextStyle(color: Styles.formErrorColor),
                                fillColor: Styles.editFieldBackgroundColor,

                                //fillColor: Colors.yellow,
                                //labelStyle:
                                //    TextStyle(color: Colors.white, fontSize: 16,),
                                //labelText: "shutter speed",
                              ),
                              initialValue: note == "-" ? "" : note,
                              onSaved: (value) {
                                _formdata["note"] = value == "" ? "-" : value;
                              },
                              validator: (val) {
                                if (val.length == 0) {
                                  return null;
                                }
                                if (val.length > 25) {
                                  return 'Note is too long!';
                                }
                                if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(val)) {
                                  return 'Use only letters and numbers!';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "CALCULATED",
                            style: TextStyle(
                              color: Styles.editTextColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var horSett in horizontSettings.split(","))
                                Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    " · " + horSett.split(".0")[0],
                                    style: TextStyle(
                                        color: Styles.editTextColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "PHONE SETTINGS",
                            style: TextStyle(
                              color: Styles.editTextColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var horSett in origSettings.split(","))
                                Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    " · " + horSett.split(".0")[0],
                                    style: TextStyle(
                                        color: Styles.editTextColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: GestureDetector(
                                child: Container(
                                  //width: 65,
                                  height: 30,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Text(
                                    "SAVE",
                                    style: TextStyle(
                                      color: Styles.primaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                //color: Colors.transparent,
                                //elevation: 0,
                                onTap: () {
                                  // Validate returns true if the form is valid, or false
                                  // otherwise.

                                  if (_formKey.currentState.validate()) {
                                    // If the form is valid, display a Snackbar.

                                    _formKey.currentState.save();

                                    var newValues = [
                                      _formdata["shutter"],
                                      _formdata["aperture"],
                                      _formdata["iso"],
                                      // _formdata["note"]
                                    ].join(",");
                                    List<String> updateSetting = _setting
                                        .split(";")
                                        .map((_) => _.trim())
                                        .toList();

                                    // remove settings
                                    int noteIndex =
                                        updateSetting.indexOf("note") + 1;
                                    updateSetting[noteIndex] =
                                        _formdata["note"];

                                    int mySettingIndex =
                                        updateSetting.indexOf("my") + 1;
                                    updateSetting[mySettingIndex] = newValues;
                                    //updateSetting.removeLast();
                                    // remove notes
                                    //updateSetting.removeLast();

                                    //updateSetting.add(newValues);

                                    SharedPrefs.updateSettings(
                                        updateSetting.join(";"));

                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  child: Padding(
                    padding: (_number < 10)
                        ? EdgeInsets.only(right: 60)
                        : EdgeInsets.all(0),
                    child: Text(
                      this._number.toString(),
                      style: TextStyle(
                        color: Colors.white12,
                        fontSize:
                            orientation == Orientation.landscape ? 320 : 200,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  top: orientation == Orientation.landscape ? 40 : 140,
                  right: orientation == Orientation.landscape ? 125 : 20,
                ),
              ]),
            ),
          );
        }));
  }
}

String prettyTime(double time) {
  if (time == null) {
    return "-";
  }
  if (time < 1.0) {
    int count = (1 / time).toInt();
    return "1/" + count.toString();
  }
  return time.toInt().toString();
}

String prettyAperture(String aperture) {
  if (aperture.contains("/")) {
    var numbers = aperture.split("/");
    int a = int.parse(numbers[0]);
    int b = int.parse(numbers[1]);
    return "f" + "${(a / b).toStringAsFixed(1).split(".0")[0]}";
  }
  return "f" + aperture;
}
