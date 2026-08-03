import 'package:flutter/material.dart';

import 'service_setup_screen.dart';
import 'register_attendees_screen.dart';
import 'registrations_screen.dart';

class ChiefUsherHome extends StatelessWidget {
  final String branchId;
  final String branchName;

  const ChiefUsherHome({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chief Usher"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "ARISE REGISTER",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Branch: $branchName",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text("Service Setup"),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceSetupScreen(
                        branchId: branchId,
                        branchName: branchName,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text("Register Attendees"),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterAttendeesScreen(
                        branchId: branchId,
                        branchName: branchName,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.table_chart),
                label: const Text("Registrations"),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegistrationsScreen(
                        branchId: branchId,
                        branchName: branchName,
                      ),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),

                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}