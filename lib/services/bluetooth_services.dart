import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
String receiveText = "";
BluetoothDevice? selectedDevice;
bool flag = false;


class BL{
  BluetoothConnection? connection;
  late BuildContext context;
  String recieved_data = " ";

  BL({this.connection,required this.context});
  
  
  Future<void> sendData(String data) async {
    try {
      connection!.output.add(Uint8List.fromList(data.codeUnits));
      await connection!.output.allSent;
      _showSnackBar("Data sent: $data", true);
    } catch (exception) {
      _showSnackBar("Error sending data: $exception", false);
    }
  }

    void receiveData() {
    if (connection != null) {
      connection!.input!.listen((Uint8List data) {
        String incomingMessage = utf8.decode(data);
        print("Received message: $incomingMessage");
        _showSnackBar("Message Received: $incomingMessage", true);
        recieved_data = incomingMessage;
        print(recieved_data);
        // Do something with the incoming message...
      }).onDone(() {
        print("Disconnected from device");
        // Do something when the device is disconnected...
      });
    }
    
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }
}

