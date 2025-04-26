// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> sendFeedbackEmail(String feedback) async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'support@metagamejsc.com',
    queryParameters: {
      'subject': 'Mod Store Feedback',
      'body': feedback,
    },
  );

  if (await canLaunchUrl(emailLaunchUri)) {
    await launchUrl(emailLaunchUri);
  } else {
    throw 'Could not launch $emailLaunchUri';
  }
}

class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({super.key});

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      final String feedback = _feedbackController.text.trim();
      try {
        await sendFeedbackEmail(feedback);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Feedback sent successfully!'),
            backgroundColor: Colors.green.shade600,
          ),
        );
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending feedback: $error'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: SingleChildScrollView(
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    "Send Us Your Feedback",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _feedbackController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your feedback";
                        }
                        return null;
                      },
                      maxLength: 200,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(16),
                        hintText: "Enter your message...",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Submit Feedback",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
