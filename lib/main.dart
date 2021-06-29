import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: IconButton(
            iconSize: 124,
            icon: Icon(Icons.play_arrow_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen()));
            }),
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late CameraController _cameraController;

  late Duration videoPosition;
  late Duration videoDuration;

  late Timer _timer;

  setVideoPlayer() {
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );

    _initializeVideoPlayerFuture = _controller.initialize();
  }

  setCamera() async {
    _cameraController = CameraController(cameras[1], ResolutionPreset.max);
    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        // _cameraController.resolutionPreset;
      });
    });
  }

  @override
  void initState() {
    setVideoPlayer();
    super.initState();
    setCamera();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    // ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _cameraController.dispose();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Complete the code in the next step.
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the VideoPlayerController has finished initialization, use
                  // the data it provides to limit the aspect ratio of the video.
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        DragBox(Offset(56, 56), 'Camera', _cameraController),
                        Positioned(
                          bottom: 24,
                          right: 100,
                          child: Slider(
                            value: _controller.value.volume,
                            onChanged: (value) {
                              setState(() {
                                _controller.setVolume(value);
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else if (_controller.value.position == _controller.value.duration) {
                  _controller.seekTo(Duration(seconds: 0));
                } else {
                  _controller.play();
                }
              });
            },
            child: Icon(
              _controller.value.isPlaying
                  ? Icons.pause
                  : (_controller.value.position == _controller.value.duration)
                      ? Icons.refresh
                      : Icons.play_arrow,
            )));
  }
}

class DragBox extends StatefulWidget {
  final Offset initPos;
  final String label;
  final CameraController _cameraController;
  DragBox(this.initPos, this.label, this._cameraController);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  Offset position = Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    position = widget.initPos;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: position.dx,
        top: position.dy,
        child: Draggable(
          data: widget.label,
          child: Container(
            width: 180,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow, width: 4), borderRadius: BorderRadius.circular(4)),
            child: AspectRatio(aspectRatio: 16 / 9, child: CameraPreview(widget._cameraController)),
          ),
          onDraggableCanceled: (velocity, offset) {
            setState(() {
              position = offset;
            });
          },
          feedback: Container(
            width: 180,
            child: AspectRatio(aspectRatio: 16 / 9, child: CameraPreview(widget._cameraController)),
          ),
        ));
  }
}

//Slider(
//                             value: _controller.value.position.inSeconds * 1.0,
//                             min: 0,
//                             max: _controller.value.duration.inSeconds * 1.0,
//                             onChanged: (value) {
//                               setState(() {
//                                 _controller.seekTo(Duration(seconds: value.floor()));
//                               });
//                             },
//                           )
