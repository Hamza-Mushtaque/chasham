// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class MajorAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final VoidCallback handleDrawer;

//   const MajorAppBar({
//     Key? key,
//     required this.title,
//     required this.handleDrawer,
//   }) : super(key: key);

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       centerTitle: true,
//       leading: IconButton(
//         icon: SvgPicture.asset(
//           'assets/svgs/logo-color.svg',
//           width: 48,
//         ),
//         onPressed: () {},
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//             fontFamily: 'NastaliqKasheeda'),
//       ),
//       actions: [
//         IconButton(
//           onPressed: () => {handleDrawer()},
//           icon: Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//             child: Icon(
//               Icons.person,
//               color: Theme.of(context).colorScheme.primary,
//               size: 24,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
