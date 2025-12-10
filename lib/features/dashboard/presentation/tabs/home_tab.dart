import 'package:flutter/material.dart';
import 'package:jobspot_app/core/theme/app_theme.dart';
import 'package:jobspot_app/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:jobspot_app/features/dashboard/presentation/widgets/job_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
                        style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'John Doe',
                        style: textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.5),
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
                      color: AppColors.purple,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Interviews',
                      count: '8',
                      icon: Icons.videocam,
                      color: AppColors.orange,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Selected',
                      count: '2',
                      icon: Icons.check_box,
                      color: Color(0xFF01B307),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved Jobs',
                    style: textTheme.headlineMedium,
                  ),
                  TextButton(onPressed: () {}, child: const Text('See all')),
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
                logoColor: AppColors.purple,
              ),
              const SizedBox(height: 12),
              const JobCard(
                company: 'Apple Inc.',
                position: 'Product Manager',
                location: 'New York, USA',
                salary: '\$140k - \$180k',
                type: 'Full Time',
                logo: Icons.apple,
                logoColor: AppColors.orange,
              ),
              const SizedBox(height: 12),
              const JobCard(
                company: 'Microsoft',
                position: 'Software Engineer',
                location: 'Seattle, USA',
                salary: '\$110k - \$145k',
                type: 'Remote',
                logo: Icons.business,
                logoColor: AppColors.purple,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended Jobs',
                    style: textTheme.headlineMedium,
                  ),
                  TextButton(onPressed: () {}, child: const Text('See all')),
                ],
              ),
              const SizedBox(height: 16),
              // Job Cards
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    SizedBox(
                      width: 320, // Constrain the width of the JobCard
                      child: JobCard(
                        company: 'Google Inc.',
                        position: 'Senior UI/UX Designer',
                        location: 'California, USA',
                        salary: '\$120k - \$150k',
                        type: 'Full Time',
                        logo: Icons.g_mobiledata,
                        logoColor: AppColors.purple,
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 320, // Constrain the width of the JobCard
                      child: JobCard(
                        company: 'Apple Inc.',
                        position: 'Product Manager',
                        location: 'New York, USA',
                        salary: '\$140k - \$180k',
                        type: 'Full Time',
                        logo: Icons.apple,
                        logoColor: AppColors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 320, // Constrain the width of the JobCard
                      child: JobCard(
                        company: 'Microsoft',
                        position: 'Software Engineer',
                        location: 'Seattle, USA',
                        salary: '\$110k - \$145k',
                        type: 'Remote',
                        logo: Icons.business,
                        logoColor: AppColors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
