import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/api_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({
    super.key,
    required this.apiService,
    this.title = 'Contact support',
  });

  final ApiService apiService;
  final String title;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _issue = 'General support';
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final firstName = _firstNameController.text.trim();
    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();

    if (email.isEmpty || firstName.isEmpty || subject.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete every field.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.apiService.submitSupportRequest({
        'email': email,
        'first_name': firstName,
        'issue': _issue,
        'subject': subject,
        'description': description,
      });
      if (!mounted) {
        return;
      }
      _subjectController.clear();
      _descriptionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support request submitted.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Submit a request',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 34),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Your email address'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _issue,
            decoration: const InputDecoration(labelText: 'Customer Issue'),
            items: const [
              DropdownMenuItem(value: 'General support', child: Text('General support')),
              DropdownMenuItem(value: 'Billing', child: Text('Billing')),
              DropdownMenuItem(value: 'Story moderation', child: Text('Story moderation')),
              DropdownMenuItem(value: 'Account access', child: Text('Account access')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _issue = value);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(backgroundColor: AppTheme.brand),
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}