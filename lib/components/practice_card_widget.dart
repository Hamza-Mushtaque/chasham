import 'package:flutter/material.dart';

class PracticeCardWidget extends StatelessWidget {
  final String title;
  final String brailleImgPath;
  final String letterImgPath;
  final String description;

  const PracticeCardWidget({
    Key? key,
    required this.title,
    required this.brailleImgPath,
    required this.letterImgPath,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => {Navigator.pushNamed(context, '/lesson/1')},
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
                      'مشق نمبر ١',
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'NastaliqKasheeda',
                          fontWeight: FontWeight.w600),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          brailleImgPath,
                          width: 96,
                        ),
                        Image.asset(
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
