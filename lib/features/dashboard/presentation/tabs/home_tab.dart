import 'package:flutter/material.dart';
import 'package:jobspot_app/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:jobspot_app/features/dashboard/presentation/widgets/job_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.notifications_outlined, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats Cards
              const Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Applied',
                      count: '24',
                      icon: Icons.send,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Interviews',
                      count: '8',
                      icon: Icons.videocam,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Featured Jobs Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Jobs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Job Cards
              const JobCard(
                company: 'Google Inc.',
                position: 'Senior UI/UX Designer',
                location: 'California, USA',
                salary: '\$120k - \$150k',
                type: 'Full Time',
                logo: Icons.g_mobiledata,
                logoColor: Color(0xFF6C63FF),
              ),
              const SizedBox(height: 12),
              const JobCard(
                company: 'Apple Inc.',
                position: 'Product Manager',
                location: 'New York, USA',
                salary: '\$140k - \$180k',
                type: 'Full Time',
                logo: Icons.apple,
                logoColor: Color(0xFFFF6B35),
              ),
              const SizedBox(height: 12),
              const JobCard(
                company: 'Microsoft',
                position: 'Software Engineer',
                location: 'Seattle, USA',
                salary: '\$110k - \$145k',
                type: 'Remote',
                logo: Icons.business,
                logoColor: Color(0xFF6C63FF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
