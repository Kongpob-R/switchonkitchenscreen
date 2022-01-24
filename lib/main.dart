import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'order_card.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

late Socket socket;

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  await dotenv.load(fileName: ".env");
  socket = io(
      dotenv.env['HOST_URL'].toString(),
      OptionBuilder()
          .setPath(dotenv.env['HOST_PATH'].toString())
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .build());
  socket.connect();
  socket.onConnect((_) {
    print('connect');
  });
  socket.onDisconnect((_) => print('disconnect'));
  runApp(const MyApp());
}

class KitchenRoute extends StatelessWidget {
  const KitchenRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Kitchen Screen"),
        ),
        body: OrderCard(socket: socket));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Square POS extraScreen',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/kitchen',
      routes: {
        '/kitchen': (context) => const KitchenRoute(),
      },
    );
  }
}
