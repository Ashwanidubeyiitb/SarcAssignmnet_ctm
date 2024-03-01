// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'main.dart'; // Import your main Todo widget

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(Duration(seconds: 5), () {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (_) => TodoApp()), // Replace TodoApp() with your main Todo widget
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // Netflix-like background color
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.movie,
//               size: 100,
//               color: Colors.red, // Netflix-like logo color
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Netflix',
//               style: TextStyle(
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white, // Netflix-like text color
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
