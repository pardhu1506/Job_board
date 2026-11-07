import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../models/job_application.dart';
import '../providers/application_provider.dart';
import '../services/form_validators.dart';

/// Application form. Every field is validated before anything is saved.
class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key, this.job, this.application})
    : assert(job != null || application != null);

  final Job? job;
  final JobApplication? application;

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  static const List<String> _experienceLevels = [
    'Fresher (0 years)',
    '1 to 2 years',
    '3 to 5 years',
    'More than 5 years',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  String? _experience;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final application = widget.application;
    if (application != null) {
      _nameController.text = application.fullName;
      _emailController.text = application.email;
      _phoneController.text = application.phone;
      _coverController.text = application.coverLetter;
      _experience = application.experience;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final store = context.read<ApplicationProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);

    final existing = widget.application;
    final application = existing == null
        ? JobApplication(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            jobId: widget.job!.id,
            jobTitle: widget.job!.title,
            company: widget.job!.company,
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            experience: _experience!,
            coverLetter: _coverController.text.trim(),
            appliedAt: DateTime.now(),
          )
        : existing.copyWith(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            experience: _experience!,
            coverLetter: _coverController.text.trim(),
          );

    try {
      if (existing == null) {
        await store.add(application);
      } else {
        await store.update(application);
      }
      if (!mounted) return;
      navigator.pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.application == null
              ? 'Apply for this job'
              : 'Edit application',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.application?.jobTitle ?? widget.job!.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.application?.company ?? widget.job!.company,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Demo only: your details are saved on this phone '
                          'and are not sent to any employer.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [LengthLimitingTextInputFormatter(60)],
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormValidators.fullName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormValidators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Mobile number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormValidators.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _experience,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Experience',
                    prefixIcon: Icon(Icons.timeline_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final level in _experienceLevels)
                      DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      ),
                  ],
                  onChanged: (value) => setState(() => _experience = value),
                  validator: FormValidators.experience,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _coverController,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: FormValidators.coverLetterMax,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Cover letter',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: FormValidators.coverLetter,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _saving
                        ? 'Saving…'
                        : widget.application == null
                        ? 'Submit application'
                        : 'Save changes',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
