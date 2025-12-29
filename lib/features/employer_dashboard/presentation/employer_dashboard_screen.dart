import 'package:flutter/material.dart';
import 'package:jobspot_app/features/employer_dashboard/presentation/tabs/employer_home_tab.dart';
import 'package:jobspot_app/features/employer_dashboard/presentation/tabs/job_posting_tab.dart';
import 'package:jobspot_app/features/employer_dashboard/presentation/tabs/applicants_tab.dart';
import 'package:jobspot_app/features/profile/presentation/profile_tab.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() =>
      _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  int _selectedIndex = 0;
  Key _refreshKey = UniqueKey();

  Future<void> _handleRefresh() async {
    // Simulate a network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _refreshKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        displacement: 40,
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: true, // Allow internal scrolling in tabs
              child: KeyedSubtree(
                key: _refreshKey,
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    const EmployerHomeTab(),
                    const JobPostingTab(),
                    const ApplicantsTab(),
                    const ProfileTab(role: 'employer'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Job Postings',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt),
            label: 'Applicants',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
