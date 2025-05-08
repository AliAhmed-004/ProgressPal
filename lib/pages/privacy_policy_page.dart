import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  void _showEmailDialog(BuildContext context) {
    final email = 'ali.the.ahmed18@gmail.com';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('No Email App Found'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'It seems your device doesn’t have an email app set up.\n\n'
                  'You can manually email us at:',
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: email));
                    Navigator.of(context).pop(); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email address copied to clipboard'),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy, size: 18, color: Colors.blue),
                        const SizedBox(width: 6),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ali.the.ahmed18@gmail.com',
      query: Uri.encodeFull('subject=ProgressPal Support'),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      _showEmailDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Effective Date: May 8, 2025\n\n'
                'SpudByte ("we", "our", or "us") built the ProgressPal app as an offline productivity tool. This app is provided by us and is intended for use as is.\n\n'
                '1. Information Collection and Use\n'
                'ProgressPal does not collect personally identifiable information from users.\n\n'
                'However, certain features may involve temporary data processing:\n\n'
                '- AI Goal Generation: If you use this feature, the app sends your entered Track and Goal names to an external AI service to generate suggestions. This data is:\n'
                '  • Not linked to your identity\n'
                '  • Not stored by us\n'
                '  • Not used for tracking or analytics\n\n'
                'We do not collect, store, or share any personal data from your device.\n\n\n'
                '2. Permissions\n'
                'The app requests the following permission:\n'
                '- Notifications: To remind you to complete your goals. Notifications are optional and controlled by your device settings. No data is collected or transmitted for this purpose.\n\n\n'
                '3. Data Safety\n'
                '- No account is required to use the app.\n'
                '- All user progress is stored locally on your device.\n'
                '- We do not use third-party analytics or advertising SDKs.\n\n\n'
                '4. Third-Party Services\n'
                'The app uses external services only for optional AI-powered goal generation. These services may process the text you input, but are not used for tracking.\n\n\n'
                '5. Security\n'
                'We value your trust. Although no personal information is collected, we strive to ensure any temporary data is handled securely.\n\n\n'
                '6. Children’s Privacy\n'
                'ProgressPal does not knowingly collect data from children under 13.\n\n\n'
                '7. Changes to This Policy\n'
                'We may update this policy. Any changes will be posted here and take effect immediately.\n\n\n'
                '8. Contact Us\n'
                'If you have any issues, concerns or feedback that we should look at, you can email us at',
                style: TextStyle(fontSize: 16),
              ),
              GestureDetector(
                onTap: () => _launchEmail(context),
                child: const Text(
                  'ali.the.ahmed18@gmail.com',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
