import 'package:chasham_fyp/services/bluetooth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class LessonCardWidget extends StatelessWidget {
  final String title;
  final String brailleImgPath;
  final String letterImgPath;
  final String description;
  final String lessonId;
  final String lessonSerial;
  final BluetoothConnection? connection;

  const LessonCardWidget({
    Key? key,
    required this.lessonSerial,
    required this.title,
    required this.brailleImgPath,
    required this.letterImgPath,
    required this.description,
    required this.lessonId,
    required this.connection,
  }) : super(key: key);



  Future<void> con_cancel() async {
    await connection!.finish();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              con_cancel();
              Navigator.pushReplacementNamed(context, '/lesson',
                  arguments: {'id': lessonSerial});
            },
            child: Container(
                width: 240,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'سبق نمبر 1',
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'NastaliqKasheeda',
                          fontWeight: FontWeight.w600),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          brailleImgPath,
                          width: 96,
                        ),
                        Image.network(
                          letterImgPath,
                          width: 72,
                        ),
                      ],
                    ),
                  ],
                )),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'NooriNastaliq', fontSize: 18),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
