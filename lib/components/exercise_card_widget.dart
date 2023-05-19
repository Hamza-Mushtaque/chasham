import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ExerciseCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final int serialNo;
  final BluetoothConnection? connection;
  final bool isActive;

  ExerciseCardWidget(
      {required this.title,
      required this.description,
      required this.serialNo,
      required this.connection,
      required this.isActive});

  Future<void> con_cancel() async {
    await connection!.finish();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement routing logic using the serialNo
        // Example: Navigator.pushNamed(context, '/exercise/$serialNo');
        con_cancel();
        Navigator.pushReplacementNamed(context, '/exercise',
            arguments: {'id': serialNo.toString()});
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color:
              isActive ? Theme.of(context).colorScheme.secondary : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NastaliqKasheeda'),
                ),
              ),
              SizedBox(height: 8.0),
              SizedBox(
                width: double.infinity,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.0, fontFamily: 'NooriNastaliq'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
