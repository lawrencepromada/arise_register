import 'package:flutter/material.dart';

import 'create_user_screen.dart';
import 'manage_users_screen.dart';

class AdministratorHome extends StatelessWidget {
  final String branchId;
  final String branchName;

  const AdministratorHome({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Administrator features are currently disabled",
        ),
      ),
    );
  }
} 


// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: const Text('Administrator'),
//     ),
//     body: Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'ARISE REGISTER',
//             style: TextStyle(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Branch: $branchName',
//             style: const TextStyle(
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 40),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               child: const Text('CREATE USER'),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => CreateUserScreen(
//                       branchId: branchId,
//                       branchName: branchName,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               child: const Text('MANAGE USERS'),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ManageUsersScreen(
//                       branchName: branchName,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }