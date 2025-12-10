import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jobspot_app/core/theme/app_theme.dart';

// A simple data class for a Job
class Job {
  final String company;
  final String position;
  final String location;
  final String salary;
  final String type;
  final IconData logo;
  final Color logoColor;
  final double latitude;
  final double longitude;

  Job({
    required this.company,
    required this.position,
    required this.location,
    required this.salary,
    required this.type,
    required this.logo,
    required this.logoColor,
    required this.latitude,
    required this.longitude,
  });
}

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  late GoogleMapController mapController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(39.8283, -98.5795),
    zoom: 4,
  );

  // --- Sample Job Data ---
  final List<Job> _jobs = [
    Job(
      company: 'Google Inc.',
      position: 'Senior UI/UX Designer',
      location: 'California, USA',
      salary: '\$120k - \$150k',
      type: 'Full Time',
      logo: Icons.g_mobiledata,
      logoColor: AppColors.purple,
      latitude: 37.4220,
      longitude: -122.0841,
    ),
    Job(
      company: 'Apple Inc.',
      position: 'Product Manager',
      location: 'New York, USA',
      salary: '\$120k - \$150k',
      type: 'Full Time',
      logo: Icons.apple,
      logoColor: AppColors.orange,
      latitude: 37.3346,
      longitude: -122.0090,
    ),
  ];

  late Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    // Create markers from the job data
    _markers = _jobs.map((job) {
      return Marker(
        markerId: MarkerId(job.company),
        position: LatLng(job.latitude, job.longitude),
        infoWindow: InfoWindow(
          title: job.position,
          snippet: job.company,
          onTap: () => _showJobDetails(job), // Show bottom sheet on tap
        ),
      );
    }).toSet();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // --- Show Job Details in a Bottom Sheet ---
  void _showJobDetails(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to be a custom height
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3, // Start at 30% of the screen height
          minChildSize: 0.15,    // Minimum height of 15%
          maxChildSize: 0.6,     // Can be dragged up to 60%
          expand: false,
          builder: (_, controller) {
            return JobDetailsSheet(job: job, scrollController: controller);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- Google Map ---
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationButtonEnabled: false, // Disabled to create a custom one if needed
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
          ),

          // --- Search Bar ---
          Positioned(
            top:60,
            left: 16,
            right: 16,
            child: Container(
              // This is the main container that provides the visual style.
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1), // Using withOpacity is slightly cleaner
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              // Place the TextField directly as the child.
              child: TextField(
                decoration: InputDecoration(
                  // The InputBorder.none is crucial to remove the default underline.
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Search for position, company...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  // No need for a separate `border` property if enabled/focused are set to none.
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
            ),
          ),


          // --- Filter Chips ---
          Positioned(
            top: 120, // Below the search bar
            left: 16,
            right: 16,
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ActionChip(
                    onPressed: () {
                      // TODO: Implement filter functionality
                    },
                    avatar: const Icon(Icons.filter_list, size: 18, color: AppColors.black),
                    label: const Text('Filter'),
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    onPressed: () {
                      // TODO: Implement sort functionality
                    },
                    avatar: const Icon(Icons.sort, size: 18, color: AppColors.black),
                    label: const Text('Sort'),
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Widget for the Job Details Bottom Sheet ---
class JobDetailsSheet extends StatelessWidget {
  final Job job;
  final ScrollController scrollController;

  const JobDetailsSheet({
    super.key,
    required this.job,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header with Company Logo and Info ---
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: job.logoColor.withValues(alpha: 0.1),
                  child: Icon(job.logo, size: 30, color: job.logoColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.position,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.company} • ${job.location}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Job Tags ---
            Wrap(
              spacing: 8.0,
              children: [
                Chip(
                  label: Text(job.type),
                  backgroundColor: AppColors.purple.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: AppColors.purple),
                ),
                Chip(
                  label: Text(job.salary),
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Apply Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement apply functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Apply Now', style: TextStyle(fontSize: 16, color: AppColors.white)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
