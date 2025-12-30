import 'package:flutter/material.dart';
import 'package:jobspot_app/data/services/job_service.dart';
import 'package:jobspot_app/core/utils/supabase_service.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobService = JobService();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _minPayController = TextEditingController();
  final _maxPayController = TextEditingController();
  final _vacanciesController = TextEditingController(text: '1');
  final _skillsController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();

  // Selections
  String _workMode = 'onsite';
  String _payType = 'monthly';
  String _genderPreference = 'any';
  final List<String> _selectedDays = [];
  TimeOfDay _shiftStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _shiftEnd = const TimeOfDay(hour: 17, minute: 0);
  bool _sameDayPay = false;
  bool _isLoading = false;

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _minPayController.dispose();
    _maxPayController.dispose();
    _vacanciesController.dispose();
    _skillsController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _shiftStart : _shiftEnd,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).cardColor,
              dayPeriodColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _shiftStart = picked;
        } else {
          _shiftEnd = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one working day'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.getCurrentUser()?.id;
      if (userId == null) throw Exception('User not authenticated');

      final jobData = {
        'employer_id': userId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'work_mode': _workMode,
        'location': _locationController.text.trim(),
        'pay_type': _payType,
        'pay_amount_min': int.parse(_minPayController.text),
        'pay_amount_max': _maxPayController.text.isNotEmpty
            ? int.parse(_maxPayController.text)
            : null,
        'working_days': _selectedDays,
        'shift_start': _formatTimeOfDay(_shiftStart),
        'shift_end': _formatTimeOfDay(_shiftEnd),
        'vacancies': int.parse(_vacanciesController.text),
        'gender_preference': _genderPreference,
        'skills': _skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'age_min': _minAgeController.text.isNotEmpty
            ? int.parse(_minAgeController.text)
            : null,
        'age_max': _maxAgeController.text.isNotEmpty
            ? int.parse(_maxAgeController.text)
            : null,
        'same_day_pay': _sameDayPay,
      };

      await _jobService.createJobPost(jobData);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post New Job')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionCard(
                      title: 'Basic Details',
                      icon: Icons.article_outlined,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Job Title*',
                            hintText: 'e.g. Delivery Partner',
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Job Description*',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),

                    _buildSectionCard(
                      title: 'Work Location & Mode',
                      icon: Icons.location_on_outlined,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _workMode,
                          decoration: const InputDecoration(
                            labelText: 'Work Mode',
                            prefixIcon: Icon(Icons.laptop_chromebook),
                          ),
                          items: ['onsite', 'remote', 'hybrid']
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m.toUpperCase()),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _workMode = v!),
                        ),
                        if (_workMode != 'remote') ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location Address',
                              prefixIcon: Icon(Icons.map_outlined),
                            ),
                          ),
                        ],
                      ],
                    ),

                    _buildSectionCard(
                      title: 'Pay & Vacancies',
                      icon: Icons.payments_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                initialValue: _payType,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Pay Type',
                                  prefixIcon: Icon(Icons.calendar_month),
                                ),
                                items:
                                    [
                                          'hourly',
                                          'daily',
                                          'weekly',
                                          'monthly',
                                          'task_based',
                                        ]
                                        .map(
                                          (t) => DropdownMenuItem(
                                            value: t,
                                            child: Text(t.toUpperCase()),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (v) => setState(() => _payType = v!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _vacanciesController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Openings',
                                  prefixIcon: Icon(Icons.people_alt_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _minPayController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Min (₹)*',
                                  prefixIcon: Icon(Icons.currency_rupee),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _maxPayController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Max (₹)',
                                  prefixIcon: Icon(Icons.currency_rupee),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Same Day Payout?'),
                          subtitle: const Text(
                            'Enable if you pay workers immediately',
                          ),
                          value: _sameDayPay,
                          onChanged: (v) => setState(() => _sameDayPay = v),
                        ),
                      ],
                    ),

                    _buildSectionCard(
                      title: 'Schedule & Shifts',
                      icon: Icons.access_time,
                      children: [
                        const Text(
                          'Working Days',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _daysOfWeek.map((day) {
                            final isSelected = _selectedDays.contains(day);
                            return FilterChip(
                              label: Text(day.substring(0, 3)),
                              selected: isSelected,
                              showCheckmark: false,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedDays.add(day);
                                  } else {
                                    _selectedDays.remove(day);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimePickerField(
                                'Start Time',
                                _shiftStart,
                                true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTimePickerField(
                                'End Time',
                                _shiftEnd,
                                false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    _buildSectionCard(
                      title: 'Requirements',
                      icon: Icons.rule,
                      children: [
                        TextFormField(
                          controller: _skillsController,
                          decoration: const InputDecoration(
                            labelText: 'Skills Required',
                            hintText: 'e.g. Driving, Cooking, Java',
                            prefixIcon: Icon(Icons.stars_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _genderPreference,
                          decoration: const InputDecoration(
                            labelText: 'Gender Preference',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: ['any', 'male', 'female']
                              .map(
                                (g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g.toUpperCase()),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _genderPreference = v!),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _minAgeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Min Age',
                                  prefixIcon: Icon(Icons.remove_circle_outline),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _maxAgeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Max Age',
                                  prefixIcon: Icon(Icons.add_circle_outline),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('POST JOB NOW'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper widget to make sections look cleaner
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      // Using flat style for modern look, increase if you prefer shadow
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 22),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  // Custom Time Picker widget that mimics an input field
  Widget _buildTimePickerField(String label, TimeOfDay time, bool isStart) {
    return InkWell(
      onTap: () => _selectTime(context, isStart),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.schedule),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          time.format(context),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
