// lib/profile_screen.dart

import 'package:flutter/material.dart';
import 'database_helper.dart' as db;
import 'app_colors.dart'; // Import main.dart for color constants

// Assuming a secondary green for gradient
const secondaryAppGreen = Color(0xFF388E3C);

class ProfileScreen extends StatefulWidget {
  final db.User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late db.User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  // Function to navigate to Profile View
  void _navigateToProfileView(BuildContext context) {
    Navigator.pushNamed(context, '/profileView', arguments: _currentUser);
  }

  // Function to navigate to Profile Edit
  void _navigateToProfileEdit(BuildContext context) async {
    final updatedUser = await Navigator.pushNamed(
      context,
      '/profileEdit',
      arguments: _currentUser,
    );
    
    // Update the state if the user object was changed and returned
    if (updatedUser != null && updatedUser is db.User) {
      setState(() {
        _currentUser = updatedUser;
      });
    }
  }

  // Function to navigate to Information
  void _navigateToInformation(BuildContext context) {
    Navigator.pushNamed(context, '/information');
  }

  // Function to show delete confirmation dialog
  Future<void> _deleteAccount(BuildContext context) async {
    final bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await db.DatabaseHelper().deleteUser(_currentUser.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully.')),
          );
          // Pop until the first route (usually login/signup)
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the top padding (status bar height)
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Make body go behind app bar
      body: Container(
        // Using gradient background for consistency
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
            // Title
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 28, // Consistent large title size
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24), // Space after title

            // Profile Header Card (Updated Structure)
            _buildProfileHeader(_currentUser, context),
            const SizedBox(height: 24),

            // Menu Options
            _buildProfileMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(db.User user, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        // Lighter green, consistent with Personal Finance cards
        color: Colors.white.withOpacity(0.2), 
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "It's a good day for saving,",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.firstName} ${user.lastName}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // Added button inside the card
          const SizedBox(height: 20),
          const Divider(color: Colors.white30),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _navigateToProfileView(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View Profile Information',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Edit personal details that may have changed over time',
            onTap: () => _navigateToProfileEdit(context),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildMenuTile(
            icon: Icons.info_outline,
            title: 'Information',
            subtitle: 'Check our Terms and Data Privacy of Cashback PH',
            onTap: () => _navigateToInformation(context),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildMenuTile(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            subtitle: 'A final and irreversible action to delete your account',
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}