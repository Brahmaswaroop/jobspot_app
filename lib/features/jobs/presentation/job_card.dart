import 'package:flutter/material.dart';

class JobCard extends StatefulWidget {
  final Map<String, dynamic> job;
  final VoidCallback? onApply;

  const JobCard({
    super.key,
    required this.job,
    this.onApply,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final job = widget.job;

    // Formatting Salary
    final minPay = job['pay_amount_min'] ?? 0;
    final maxPay = job['pay_amount_max'];
    final payType = job['pay_type'] ?? '';
    final salaryStr = maxPay != null ? '₹$minPay - ₹$maxPay' : '₹$minPay';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.business, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'] ?? 'Untitled Position',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job['work_mode']?.toString().toUpperCase() ?? ''} • ${job['location'] ?? 'Remote'}',
                      style: textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: _isBookmarked ? colorScheme.secondary : null,
                ),
                onPressed: () {
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: theme.hintColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  (job['working_days'] as List?)?.join(', ') ?? 'N/A',
                  style: textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: theme.hintColor),
              const SizedBox(width: 4),
              Text(
                '${job['shift_start']?.toString().substring(0, 5) ?? ''} - ${job['shift_end']?.toString().substring(0, 5) ?? ''}',
                style: textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salaryStr,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    payType.toString().toUpperCase(),
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: widget.onApply,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: const Text("Apply"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
