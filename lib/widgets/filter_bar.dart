import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/job_provider.dart';

/// Job type chips and a location dropdown. Reads and updates JobProvider.
class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('All types'),
                  selected: provider.selectedType == null,
                  onSelected: (_) => provider.setType(null),
                ),
              ),
              for (final type in provider.availableTypes)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(Job.labelForType(type)),
                    selected: provider.selectedType == type,
                    onSelected: (_) => provider.setType(type),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: DropdownButtonFormField<String?>(
            key: ValueKey(provider.selectedLocation),
            initialValue: provider.selectedLocation,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.place_outlined),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All locations'),
              ),
              for (final location in provider.availableLocations)
                DropdownMenuItem<String?>(
                  value: location,
                  child: Text(location, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: provider.setLocation,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Salary range')),
                  if (provider.salaryRange != null)
                    TextButton(
                      onPressed: () => provider.setSalaryRange(null),
                      child: const Text('Clear'),
                    ),
                ],
              ),
              Builder(
                builder: (context) {
                  final maximum = provider.salarySliderMax;
                  final selected = provider.salaryRange;
                  final values = selected == null
                      ? RangeValues(0, maximum)
                      : RangeValues(
                          selected.start.clamp(0, maximum).toDouble(),
                          selected.end.clamp(0, maximum).toDouble(),
                        );
                  return RangeSlider(
                    min: 0,
                    max: maximum,
                    divisions: 100,
                    values: values,
                    labels: RangeLabels(
                      _formatSalary(values.start),
                      _formatSalary(values.end),
                    ),
                    onChanged: (range) => provider.setSalaryRange(range),
                  );
                },
              ),
              Text(
                'Undisclosed salaries are always included. Amounts use the '
                'job post’s currency.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatSalary(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}m';
    if (value >= 1000) return '${(value / 1000).round()}k';
    return value.round().toString();
  }
}
