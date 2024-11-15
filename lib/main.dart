import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:videoplayerdemo/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  VideoPlayerController? controller;
  DatabaseHelper dbHelper = DatabaseHelper();

  final List<String> videos = [
    "https://onespace.fra1.cdn.digitaloceanspaces.com/VLOG/1703139048919_452186_SaveInsta.App - 3236477835018689769.mp4",
    "https://onespace.fra1.cdn.digitaloceanspaces.com/VLOG/1703061817486_177985_SaveInsta.App - 3244920338181176295.mp4",
    "https://onespace.fra1.cdn.digitaloceanspaces.com/POST/1701924641748_127256_SaveInsta.App - 3225801074357555239.mp4",
    "https://onespace.fra1.cdn.digitaloceanspaces.com/VLOG/1703056848200_249518_SaveInsta.App - 3234421960815445644.mp4",
    "https://onespace.fra1.cdn.digitaloceanspaces.com/VLOG/1703057056108_384645_SaveInsta.App - 3184575012534032125.mp4",
    "https://onespace.fra1.cdn.digitaloceanspaces.com/VLOG/1702450624564_995931_SaveInsta.App - 3215667781838993569.mp4",
  ];

  @override
  void initState() {
    controller?.initialize();
    controller = VideoPlayerController.networkUrl(
      Uri.parse(videos[0]),
    )..initialize().then((value) {
        setState(() {});
      });
    controller?.play();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller?.dispose();
    super.dispose();
  }

  var play = true;
  var show = false;

  @override
  Widget build(BuildContext context) {
    controller?.setLooping(true);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Downloaded(),
                    ));
              },
              child: const Text(
                'Downloaded',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ))
        ],
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          show = !show;
          Future.delayed(
            const Duration(seconds: 3),
            () {
              show = false;
              setState(() {});
            },
          );
          setState(() {});
        },
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(controller!),
              show == true
                  ? Center(
                      child: InkWell(
                          onTap: () {
                            if (play == false) {
                              controller?.play();
                            } else {
                              controller?.pause();
                            }
                            play = !play;
                            setState(() {});
                          },
                          child: Icon(
                            play == true ? Icons.pause : Icons.play_arrow,
                            color: Colors.white.withOpacity(0.8),
                            size: 70.0,
                          )))
                  : const SizedBox(),
              Positioned(
                bottom: 10,
                right: 15,
                child: InkWell(
                    onTap: () async {
                      try {
                        final db = await dbHelper.database;

                        Directory directory = await getApplicationDocumentsDirectory();
                        String filePath = '${directory.path}/abc4';
                        Dio dio = Dio();

                        await dio.download(videos[0], filePath, onReceiveProgress: (received, total) async {
                          if (total != -1) {
                            print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
                            if (received == total) {
                              var result = await db.insert(
                                'videos',
                                {
                                  'title': "demo 1",
                                  'filePath': filePath,
                                },
                              );
                              print("video result ==>> ${result}");
                              // Video video = Video(id: 0, title: "demo 1", filePath: filePath);
                            }
                          }
                        });

                        print('File downloaded to: $filePath');
                      } catch (e) {
                        print('Error downloading file: $e');
                      }
                      // var status = await Permission.storage.request();
                      // if (status.isGranted) {
                      //   try {
                      //     Directory directory = await getApplicationDocumentsDirectory();
                      //     String filePath = '${directory.path}/abc4';
                      //     Dio dio = Dio();
                      //
                      //     await dio.download(videos[0], filePath, onReceiveProgress: (received, total) {
                      //       if (total != -1) {
                      //         print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
                      //       }
                      //     });
                      //
                      //     print('File downloaded to: $filePath');
                      //   } catch (e) {
                      //     print('Error downloading file: $e');
                      //   }
                      // } else {
                      //   print('Permission denied');
                      // }
                    },
                    child: const Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                      size: 35.0,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Downloaded extends StatefulWidget {
  const Downloaded({super.key});

  @override
  State<Downloaded> createState() => _DownloadedState();
}

class _DownloadedState extends State<Downloaded> {
  DatabaseHelper dbHelper = DatabaseHelper();
  VideoPlayerController? controller;

  List<Map<String, dynamic>>? isExits;
  getVideos() async {
    final db = await dbHelper.database;

   isExits = await db.query(
      'videos',
      // where: "id = ? ",
      // whereArgs: [0],
    );

    print("isExits ===>>${isExits}");
    print("isExits ===>>${isExits}");
setState(() {});
  }

  var play = true;
  var show = false;

  @override
  void initState() {
    getVideos();
    controller?.initialize();
    controller?.play();
    // TODO: implement initState
    super.initState();
  }

  void dispose() {
    // TODO: implement dispose
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller?.setLooping(true);
    return Scaffold(
      appBar: AppBar(title: const Text('Downloaded Videos')),
      body: isExits == null ? Center(
       child: Text("No Data",style: const TextStyle(
            color: Colors.black,
            fontSize: 20.0
        ),),
      ):ListView.builder(
        itemCount: isExits?.length,
        itemBuilder: (context, index) {
          controller = VideoPlayerController.file(File(isExits?[index]['filePath'])
          )..initialize().then((value) {
            setState(() {});
          });
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 5),
            child: Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isExits?[index]['title'],style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20.0
                  ),),
                  Container(
                    height: 250.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                    child: GestureDetector(
                      onTap: () {
                        show = !show;
                        Future.delayed(
                          const Duration(seconds: 3),
                              () {
                            show = false;
                            setState(() {});
                          },
                        );
                        setState(() {});
                      },
                      child: Container(
                        height: 250.0,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                                height: 250.0,
                                child: VideoPlayer(controller!)),
                            show == true
                                ? Center(
                                child: InkWell(
                                    onTap: () {
                                      if (play == false) {
                                        controller?.play();
                                      } else {
                                        controller?.pause();
                                      }
                                      play = !play;
                                      setState(() {});
                                    },
                                    child: Icon(
                                      play == true ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 70.0,
                                    )))
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
