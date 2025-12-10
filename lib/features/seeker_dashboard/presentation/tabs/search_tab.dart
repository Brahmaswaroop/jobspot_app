import 'package:flutter/material.dart';
import 'package:jobspot_app/core/theme/app_theme.dart';
import 'package:jobspot_app/features/seeker_dashboard/presentation/widgets/job_card.dart';

class Job {
  final String company;
  final String position;
  final String location;
  final String salary;
  final String type;
  final IconData logo;
  final Color logoColor;

  Job({
    required this.company,
    required this.position,
    required this.location,
    required this.salary,
    required this.type,
    required this.logo,
    required this.logoColor,
  });
}

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  // --- Master list of all available jobs (in a real app, this would come from an API) ---
  final List<Job> _allJobs = [
    Job(company: 'Google Inc.', position: 'Senior UI/UX Designer', location: 'California, USA', salary: '\$120k - \$150k', type: 'Full Time', logo: Icons.g_mobiledata, logoColor: AppColors.purple),
    Job(company: 'Apple Inc.', position: 'Product Manager', location: 'New York, USA', salary: '\$140k - \$180k', type: 'Full Time', logo: Icons.apple, logoColor: AppColors.orange),
    Job(company: 'Microsoft', position: 'Software Engineer', location: 'Seattle, USA', salary: '\$110k - \$145k', type: 'Remote', logo: Icons.business, logoColor: AppColors.purple),
    Job(company: 'Facebook', position: 'Data Scientist', location: 'Austin, USA', salary: '\$135k - \$160k', type: 'Contract', logo: Icons.facebook, logoColor: const Color(0xFF1877F2)),
    Job(company: 'Netflix', position: 'Flutter Developer', location: 'Los Gatos, USA', salary: '\$115k - \$155k', type: 'Part Time', logo: Icons.movie_filter, logoColor: const Color(0xFFE50914)),
  ];

  // --- List of jobs that will be displayed in the UI ---
  late List<Job> _displayedJobs;

  // State for active filters
  String? _selectedJobType;
  final List<String> _jobTypes = ['Full Time', 'Part Time', 'Remote', 'Contract'];

  @override
  void initState() {
    super.initState();
    // Initially, display all jobs
    _displayedJobs = List.from(_allJobs);
  }

  // --- Main filtering logic ---
  void _filterJobs() {
    setState(() {
      if (_selectedJobType == null) {
        // If no filter is selected, show all jobs
        _displayedJobs = List.from(_allJobs);
      } else {
        // Otherwise, filter the list
        _displayedJobs = _allJobs.where((job) => job.type == _selectedJobType).toList();
      }
    });
  }

  // --- Function to show the filter options in a modal bottom sheet ---
  void _openFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use StatefulBuilder to update the modal's UI without rebuilding the whole screen
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Job Type',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _jobTypes.map((type) {
                      final isSelected = _selectedJobType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            // Allow deselecting by tapping the same chip again
                            _selectedJobType = selected ? type : null;
                          });
                          // Apply the filter and close the sheet
                          _filterJobs();
                          Navigator.pop(context);
                        },
                        backgroundColor: AppColors.white,
                        selectedColor: AppColors.purple,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.black,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Find Your Dream Job'),
        centerTitle: true,
        backgroundColor: AppColors.darkPurple,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for position, company...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              // --- Sort & Filter Chips Section ---
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // --- Filter Chip ---
                    ActionChip(
                      onPressed: _openFilterOptions, // This now opens the popup
                      avatar: const Icon(Icons.filter_list, size: 18),
                      label: const Text('Filter'),
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // --- Sort Chip ---
                    ActionChip(
                      onPressed: () {
                        // TODO: Implement sort functionality
                      },
                      avatar: const Icon(Icons.sort, size: 18),
                      label: const Text('Sort'),
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),

                    // --- Display Active Filter Chip ---
                    if (_selectedJobType != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Chip(
                          label: Text(_selectedJobType!),
                          labelStyle: const TextStyle(color: AppColors.white),
                          backgroundColor: AppColors.purple,
                          onDeleted: () {
                            // Clear the filter and update the job list
                            _selectedJobType = null;
                            _filterJobs();
                          },
                          deleteIconColor: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Results Section Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_displayedJobs.length} Jobs Found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Sort by: Newest',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Job Cards List (now built from _displayedJobs) ---
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _displayedJobs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final job = _displayedJobs[index];
                  return JobCard(
                    company: job.company,
                    position: job.position,
                    location: job.location,
                    salary: job.salary,
                    type: job.type,
                    logo: job.logo,
                    logoColor: job.logoColor,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
