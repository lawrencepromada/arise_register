import 'package:flutter/material.dart';


class ManageUsersScreen extends StatelessWidget {

  final String branchName;


  const ManageUsersScreen({
    super.key,
    required this.branchName,
  });


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Manage Users'),
      ),


      body: Center(

        child: Text(
          'Users for $branchName',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),

      ),

    );

  }

}