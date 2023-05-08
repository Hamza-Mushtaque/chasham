import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MinAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;

  const MinAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
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
            child: const Icon(
              Icons.person,
              color: Colors.white,
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
