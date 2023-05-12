import 'dart:html';

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
  List<String> urls = [];
  String errorMsg = "";
  DatabaseReference bannerRef = FirebaseDatabase.instance.ref("banner");

  @override
  initState() {
    super.initState();
    connect();
  }

  void connect() async {
    bannerRef.onValue.listen(
      (DatabaseEvent event) {
        final snapShotOnValue = event.snapshot;
        final data = event.snapshot.value;
        print(data);
        setState(
          () {
            if (data != null) {}
            if (snapShotOnValue.exists) {
              // urls = snapShotOnValue.value as List<String>;
              urls = ["hello"];
            } else {
              urls = [];
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
    if (urls.isNotEmpty) {
      return ListView.builder(
        reverse: true,
        itemCount: urls.length,
        itemBuilder: (context, index) {
          return Text(urls[index]);
        },
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
