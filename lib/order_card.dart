import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

FirebaseDatabase database = FirebaseDatabase.instance;
DatabaseReference orderRef = FirebaseDatabase.instance.ref("orders");

class OrderCard extends StatefulWidget {
  const OrderCard({Key? key}) : super(key: key);

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  dynamic orders = [];
  Timer? _debounce;

  void debouncing({required Function() fn, int waitForMs = 500}) {
    // if this function is called before 500ms [waitForMs] expired
    //cancel the previous call
    _debounce?.cancel();
    // set a 500ms [waitForMs] timer for the [fn] to be called
    _debounce = Timer(Duration(milliseconds: waitForMs), fn);
  }

  @override
  initState() { 
    super.initState();
    connect();
  }

  @override
  dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void connect() async {
    orderRef.onValue.listen((DatabaseEvent event) {
      final snapShotOnValue = event.snapshot;
      setState(() {
        if (snapShotOnValue.exists) { 
          orders = snapShotOnValue.value; 
        }
      });
    });
  }

  String nextStateCycle(String state, String categories) {
    if (categories == "drinks") {
      if (state == "wait") {
        return "process";
      } else if (state == "process") {
        return "done";
      } else if (state == "done") {
        return "served";
      } else {
        return "served";
      }
    } else {
      if (state == "wait") {
        return "done";
      } else if (state == "done") {
        return "served";
      } else {
        return "served";
      }
    }
  }

  void handleIncrementState(String orderID, int itemID) async {
    String nextState = nextStateCycle(
      orders[orderID]['items'][itemID]["state"],
      orders[orderID]['items'][itemID]["categories"]
    );
    await orderRef.update({
      orderID + "/items/" + itemID.toString() + "/state": nextState,
    });
    if(nextState == "served") {
      return handleRemove(orderID);
    }
  }

  void handleRemove(String orderID) async {
    bool allServed = true;
    for (var value in orders[orderID]['items']){
      bool isServed = (value["state"] == "served");
      allServed = allServed && isServed;
      print(allServed);
    };
    if (allServed) {
      await orderRef.update({orderID: null}); 
    }
  }

  void handleUpdateCustomerName(String orderID, String? customerName) async {
    if (customerName != null) {
      await orderRef.update({orderID + "/customer_name": customerName});
    }
  }

  ButtonStyle stateColor(String state) {
    switch (state) {
      case 'wait':
        {
          return ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.lightBlue));
        }
      case 'process':
        {
          return ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.amber));
        }
      case 'done':
        {
          return ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.lightGreen));
        }
      default:
        {
          return ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey));
        }
    }
  }

  isDisable(String? state) {
    state = state.toString();
    if (state == 'served') {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
      ),
      itemCount: orders.length,
      itemBuilder: (BuildContext context, int index) {
        String key = orders.keys.elementAt(index);
        var _focusNode = FocusNode();
        return Card(
          color: Colors.grey[10],
          child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Row(children: <Widget>[
                        Flexible(
                          child: TextField(
                            focusNode: _focusNode,
                            controller: TextEditingController()
                              ..text = orders[key]['customer_name'] ??= '',
                            onChanged: (customerName) {
                              debouncing(fn: () {
                                handleUpdateCustomerName(
                                    key, customerName);
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Customer Name',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () => _focusNode.requestFocus(),
                                child: const Text('Rename')),
                          ),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: orders[key]['items']
                              .map<Widget>((item) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2),
                                    child: Container(
                                      decoration: const ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              width: 1.0,
                                              style: BorderStyle.solid,
                                              color: Colors.grey),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    item['name'],
                                                    textScaleFactor: 1.2,
                                                  ),
                                                  Text(item['variation']
                                                      .toString()
                                                      .replaceAll(
                                                          ', ', '\n')),
                                                  if (item['modifier'] !=
                                                      null)
                                                    Text(item['modifier']
                                                        .toString()
                                                        .replaceAll(
                                                            ', ', '\n')),
                                                ],
                                              ),
                                              Text(
                                                item['quantity'],
                                                textScaleFactor: 1.2,
                                              ),
                                              ElevatedButton(
                                                  onPressed:
                                                      isDisable(item['state'])
                                                          ? null
                                                          : () {
                                                              handleIncrementState(
                                                                key,
                                                                item['id'],
                                                              );
                                                            },
                                                  style: stateColor(
                                                      item['state']
                                                          .toString()),
                                                  child: Text(item['state']
                                                      .toString())),
                                            ]),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ])),
        );
      });
  }
}
