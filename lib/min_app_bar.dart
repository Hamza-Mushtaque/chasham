import 'package:chasham_fyp/services/bluetooth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MinAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final BluetoothConnection? connection;

  const MinAppBar({
    Key? key,
    required this.title,
    required this.connection,
  }) : super(key: key);

  Future<void> con_cancel() async {
    await connection!.finish();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () { 
          con_cancel();
          Navigator.of(context).pop();
        }
      ),
      centerTitle: true,
      title: SvgPicture.asset(
        'assets/svgs/logo-color.svg',
        height: 32,
      ),
      actions: [
        IconButton(
          onPressed: () => {Navigator.pushNamed(context, '/profile')},
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
