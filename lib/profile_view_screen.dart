// lib/profile_view_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart' as db;
import 'app_colors.dart'; // Import main.dart for color constants

// Assuming a secondary green for gradient
const secondaryAppGreen = Color(0xFF388E3C);

class ProfileViewScreen extends StatelessWidget {
  final db.User user;
  const ProfileViewScreen({super.key, required this.user});

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not set';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM dd, yyyy').format(date); // e.g., Jan 01, 2025
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the top padding (status bar height)
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Profile Information', ...), // REMOVED
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        // Added gradient background
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryAppGreen, secondaryAppGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          // Adjusted padding to start below app bar + status bar
          padding: EdgeInsets.fromLTRB(16.0, topPadding + kToolbarHeight + 16, 16.0, 16.0),
          children: [
            // ADDED: New title widget
            const Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24), // Space after title

            // Personal Information Card
            _buildInfoCard(
              title: 'Personal Information',
              children: [
                _buildInfoRow(title: 'Full Name', value: '${user.firstName} ${user.lastName}'),
                _buildInfoRow(title: 'Age', value: user.age ?? 'Not set'),
                _buildInfoRow(title: 'Date of Birth', value: _formatDate(user.dateOfBirth)),
                _buildInfoRow(title: 'Occupation', value: user.occupation ?? 'Not set'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Contact Number Card
            _buildInfoCard(
              children: [
                _buildInfoRow(title: 'Contact Number', value: user.contactNumber ?? 'Not set'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Email Address Card
            _buildInfoCard(
              children: [
                _buildInfoRow(title: 'Email Address', value: user.email),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({String? title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}