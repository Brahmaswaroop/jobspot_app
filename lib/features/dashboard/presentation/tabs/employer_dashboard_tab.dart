
import 'package:flutter/material.dart';
import 'package:jobspot_app/core/theme/app_theme.dart';
import 'package:jobspot_app/features/dashboard/presentation/widgets/candidate_card.dart';

class Candidate {
  final String name;
  final String position;
  final String experience;
  final IconData icon;
  final Color iconColor;

  Candidate({
    required this.name,
    required this.position,
    required this.experience,
    required this.icon,
    required this.iconColor,
  });
}

class EmployerDashboardTab extends StatefulWidget {
  const EmployerDashboardTab({super.key});

  @override
  State<EmployerDashboardTab> createState() => _EmployerDashboardTabState();
}

class _EmployerDashboardTabState extends State<EmployerDashboardTab> {
  // --- Master list of all available candidates ---
  final List<Candidate> _allCandidates = [
    Candidate(name: 'John Doe', position: 'Senior UI/UX Designer', experience: '5 years', icon: Icons.person, iconColor: AppColors.purple),
    Candidate(name: 'Jane Smith', position: 'Product Manager', experience: '8 years', icon: Icons.person_outline, iconColor: AppColors.orange),
    Candidate(name: 'Peter Jones', position: 'Software Engineer', experience: '3 years', icon: Icons.person_2, iconColor: AppColors.purple),
    Candidate(name: 'Alice Williams', position: 'Data Scientist', experience: '6 years', icon: Icons.person_3, iconColor: const Color(0xFF1877F2)),
    Candidate(name: 'David Brown', position: 'Flutter Developer', experience: '2 years', icon: Icons.person_4, iconColor: const Color(0xFFE50914)),
  ];

  // --- List of candidates that will be displayed in the UI ---
  late List<Candidate> _displayedCandidates;

  // State for active filters
  String? _selectedExperience;
  final List<String> _experienceLevels = ['Entry Level', 'Mid Level', 'Senior Level'];

  @override
  void initState() {
    super.initState();
    // Initially, display all candidates
    _displayedCandidates = List.from(_allCandidates);
  }

  // --- Main filtering logic ---
  void _filterCandidates() {
    setState(() {
        // Simple filter for demonstration. A real app would have more complex logic.
      if (_selectedExperience == null) {
        _displayedCandidates = List.from(_allCandidates);
      } else {
        _displayedCandidates = _allCandidates.where((candidate) {
          int years = int.parse(candidate.experience.split(' ')[0]);
          if (_selectedExperience == 'Entry Level') return years <= 2;
          if (_selectedExperience == 'Mid Level') return years > 2 && years <= 5;
          if (_selectedExperience == 'Senior Level') return years > 5;
          return false;
        }).toList();
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Experience',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _experienceLevels.map((level) {
                      final isSelected = _selectedExperience == level;
                      return ChoiceChip(
                        label: Text(level),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedExperience = selected ? level : null;
                          });
                          _filterCandidates();
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
      backgroundColor: AppColors.grey,
      appBar: AppBar(
        title: const Text('Find Top Candidates'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.black,
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
                  hintText: 'Search for candidate, role...',
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
                      onPressed: _openFilterOptions,
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
                    if (_selectedExperience != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Chip(
                          label: Text(_selectedExperience!),
                          labelStyle: const TextStyle(color: AppColors.white),
                          backgroundColor: AppColors.purple,
                          onDeleted: () {
                            _selectedExperience = null;
                            _filterCandidates();
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
                    '${_displayedCandidates.length} Candidates Found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Sort by: Relevance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Candidate Cards List ---
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _displayedCandidates.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final candidate = _displayedCandidates[index];
                  return CandidateCard(
                    name: candidate.name,
                    position: candidate.position,
                    experience: candidate.experience,
                    icon: candidate.icon,
                    iconColor: candidate.iconColor,
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
