import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';

class UserDetailsView extends StatelessWidget {
  final Map<String, dynamic> userData;
  const UserDetailsView({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Exclude password and userID fields
    final excludedKeys = ['UserPassword', 'UserID', 'password', 'id'];
    final displayData = userData.entries
        .where((entry) => !excludedKeys.contains(entry.key))
        .toList();

    return Scaffold(
      backgroundColor: TColor.lightGray,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.primaryColor1),
        title: Text(
          'Account Details',
          style: TextStyle(
            color: TColor.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Icon and Name
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: TColor.primaryColor2.withOpacity(0.10),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: TColor.primaryColor1.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: TColor.primaryColor1,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getFullName(userData),
                      style: TextStyle(
                        color: TColor.primaryColor1,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    if (userData['UserEmail'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        userData['UserEmail'],
                        style: TextStyle(
                          color: TColor.secondaryColor1,
                          fontSize: 14,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Details Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Information',
                        style: TextStyle(
                          color: TColor.primaryColor1,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...displayData.map((entry) => _buildDetailRow(entry)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(MapEntry entry) {
    final icon = _getIconForKey(entry.key);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: TColor.primaryColor1, size: 22),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 15, color: TColor.black),
                children: [
                  TextSpan(
                    text: '${_formatKey(entry.key)}: ',
                    style: TextStyle(
                      color: TColor.primaryColor1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '${entry.value}',
                    style: TextStyle(
                      color: TColor.black,
                      fontWeight: FontWeight.w400,
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

  String _getFullName(Map<String, dynamic> userData) {
    final first = userData['UserFirstName'] ?? '';
    final last = userData['UserLastName'] ?? '';
    return (first.toString() + ' ' + last.toString()).trim();
  }

  String _formatKey(String key) {
    // Convert camelCase or snake_case to Title Case
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  IconData? _getIconForKey(String key) {
    final lower = key.toLowerCase();
    if (lower.contains('email')) return Icons.email;
    if (lower.contains('gender')) return Icons.wc;
    if (lower.contains('weight')) return Icons.monitor_weight;
    if (lower.contains('height')) return Icons.height;
    if (lower.contains('age')) return Icons.cake;
    if (lower.contains('phone')) return Icons.phone;
    if (lower.contains('address')) return Icons.home;
    if (lower.contains('date')) return Icons.calendar_today;
    return null;
  }
}
