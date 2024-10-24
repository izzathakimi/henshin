import 'package:flutter/material.dart';
import '../job_application_page/job_application_widget.dart';
import '../job_application_page2/job_application_page2_widget.dart';
import '../create_project_page/create_project_page_widget.dart';
import '../job_proposals_page/job_proposal_page_widget.dart';
import '../request_service_page/request_service_page_widget.dart';
import '../service_inprogress_page/service_inprogress_page_widget.dart';

class JobListing extends StatelessWidget {
  const JobListing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Listings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JobApplicationPageWidget()),
                );
              },
              child: const Text('Job Application Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JobApplicationPage2Widget()),
                );
              },
              child: const Text('Job Application Page 2'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateProjectPageWidget()),
                );
              },
              child: const Text('Create Project Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JobPropopsalsPageWidget()),
                );
              },
              child: const Text('Job Proposals Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestServicePageWidget()),
                );
              },
              child: const Text('Request Service Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ServiceInprogressPageWidget()),
                );
              },
              child: const Text('Service In Progress Page'),
            ),
          ],
        ),
      ),
    );
  }
}