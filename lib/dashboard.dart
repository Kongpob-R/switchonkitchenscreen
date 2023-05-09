import 'dart:html';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  initState() {
    super.initState();
  }

  String? imgUrl;

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
    return FutureBuilder(
      future: FirebaseStorage.instance.ref().child('newfile').getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              body: Column(
            children: [
              imgUrl == null
                  ? const Placeholder(
                      fallbackHeight: 200,
                      fallbackWidth: 400,
                    )
                  : SizedBox(
                      height: 300,
                      width: 300,
                      child: Image.network(
                        imgUrl!,
                        fit: BoxFit.contain,
                      ),
                    ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () => uploadToStorage(),
                child: const Text("Upload"),
              ),
            ],
          ));
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
