import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for ByteData
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jobspot_app/core/theme/app_theme.dart';
import 'dart:ui' as ui; // Required for image resizing

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
      salary: '\$140k - \$180k',
      type: 'Full Time',
      logo: Icons.apple,
      logoColor: AppColors.orange,
      latitude: 37.3346,
      longitude: -122.0090,
    ),
  ];

  Set<Marker> _markers = {};
  // NEW: Icons for selected and unselected states
  BitmapDescriptor? _selectedMarkerIcon;
  BitmapDescriptor? _unselectedMarkerIcon;
  // NEW: Keep track of the selected marker
  String? _selectedJobCompany;

  @override
  void initState() {
    super.initState();
    // Load the custom marker icons before building markers
    _loadMarkerIcons();
  }

  // --- MODIFIED: Function to load both custom marker icons ---
  Future<void> _loadMarkerIcons() async {
    // Selected icon is map_icon_1.png, unselected is map_icon_2.png
    final Uint8List selectedIconBytes = await getBytesFromAsset(
      'assets/icons/map_icon_1.png',
      64,
    );
    final Uint8List unselectedIconBytes = await getBytesFromAsset(
      'assets/icons/map_icon_2.png',
      72,
    );

    if (mounted) {
      setState(() {
        _selectedMarkerIcon = BitmapDescriptor.bytes(selectedIconBytes);
        _unselectedMarkerIcon = BitmapDescriptor.bytes(unselectedIconBytes);
      });
      // Initial build of markers
      _buildMarkers();
    }
  }

  // --- Helper function to get bytes and resize image (from your code) ---
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
  }

  // --- MODIFIED: Function to build markers based on selection state ---
  void _buildMarkers() {
    // Don't build if icons aren't ready yet
    if (_unselectedMarkerIcon == null || _selectedMarkerIcon == null) return;

    final markers = _jobs.map((job) {
      final isSelected = job.company == _selectedJobCompany;
      return Marker(
        markerId: MarkerId(job.company),
        position: LatLng(job.latitude, job.longitude),
        icon: isSelected ? _selectedMarkerIcon! : _unselectedMarkerIcon!,
        zIndexInt: isSelected ? 1 : 0,
        infoWindow: InfoWindow(
          title: job.position,
          snippet: job.company,
          onTap: () {
            _showJobDetails(job).whenComplete(() {
              if (mounted) {
                setState(() {
                  _selectedJobCompany = null;
                  _buildMarkers();
                });
              }
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedJobCompany = job.company;
            _buildMarkers(); // Re-build markers to update icons immediately
          });
        },
      );
    }).toSet();

    // Update the state with the newly built markers
    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // --- Show Job Details in a Bottom Sheet ---
  Future<void> _showJobDetails(Job job) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.15,
          maxChildSize: 0.6,
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
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            // When tapping on the map, clear selection
            onTap: (argument) {
              if (_selectedJobCompany != null) {
                setState(() {
                  _selectedJobCompany = null;
                  _buildMarkers();
                });
              }
            },
          ),

          // --- Search Bar ---
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.1,
                    ), // Using withOpacity is slightly cleaner
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Search for position, company...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),

          // --- Filter Chips ---
          Positioned(
            top: 126,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ActionChip(
                    onPressed: () {},
                    avatar: const Icon(
                      Icons.filter_list,
                      size: 18,
                      color: AppColors.black,
                    ),
                    label: const Text('Filter'),
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    onPressed: () {},
                    avatar: const Icon(
                      Icons.sort,
                      size: 18,
                      color: AppColors.black,
                    ),
                    label: const Text('Sort'),
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.company} • ${job.location}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Now',
                  style: TextStyle(fontSize: 16, color: AppColors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
