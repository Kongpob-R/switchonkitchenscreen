import 'dart:html';
import 'dart:js' as js;

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? imgUrl;
  Map<String, List<String>> urls = {};
  String errorMsg = "";
  DatabaseReference fullBannerRef =
      FirebaseDatabase.instance.ref("banner/fullscreen");
  DatabaseReference halfBannerRef =
      FirebaseDatabase.instance.ref("banner/halfscreen");

  @override
  initState() {
    super.initState();
    connect();
  }

  void connect() async {
    fullBannerRef.onValue.listen(
      (DatabaseEvent event) {
        final snapShotOnValue = event.snapshot;
        setState(
          () {
            if (snapShotOnValue.exists) {
              List<String> newUrls = [];
              for (var element in event.snapshot.children) {
                print(element.value);
                newUrls.add(element.value.toString());
              }
              urls['fullBanner'] = newUrls;
            }
          },
        );
      },
    );
  }

  uploadToStorage() async {
    FirebaseStorage fs = FirebaseStorage.instance;
    List<File>? imageFile = await ImagePickerWeb.getMultiImagesAsFile();
    var snapshot = await fs.ref().child('newfile').putBlob(imageFile);
    String downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      imgUrl = downloadUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (errorMsg != "") {
      return Center(
        child: Text(errorMsg),
      );
    }
    if (urls['fullBanner'] != null) {
      return Container(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            ListView.builder(
              reverse: true,
              shrinkWrap: true,
              itemCount: urls['fullBanner']!.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => js.context
                      .callMethod('open', [urls['fullBanner']![index]]),
                  child: Text(
                    urls['fullBanner']![index],
                    style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () => uploadToStorage(),
              child: const Text("Upload Fullscreen Banner"),
            ),
          ],
        ),
      );
    }

    // return Scaffold(
    //   body: Column(
    //     children: [
    //       imgUrl == null
    //           ? const Placeholder(
    //               fallbackHeight: 200,
    //               fallbackWidth: 400,
    //             )
    //           : SizedBox(
    //               height: 300,
    //               width: 300,
    //               child: Image.network(
    //                 imgUrl!,
    //                 fit: BoxFit.contain,
    //               ),
    //             ),
    //       const SizedBox(
    //         height: 50,
    //       ),
    //       ElevatedButton(
    //         onPressed: () => uploadToStorage(),
    //         child: const Text("Upload"),
    //       ),
    //     ],
    //   ),
    // );
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
