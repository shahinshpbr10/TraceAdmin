import 'package:flutter/material.dart';
import 'package:traceadmin/pages/banking_page..dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Account"),
            _buildSettingsTile(
              context,
              icon: Icons.person,
              title: "Profile Settings",
              subtitle: "Update your personal details",
              onTap: () {},
            ),
            _buildDivider(),

            _buildSectionTitle("Preferences"),
            _buildSettingsTile(
              context,
              icon: Icons.notifications_active,
              title: "Notifications",
              subtitle: "Manage notification preferences",
              onTap: () {},
            ),
            _buildSettingsTile(
              context,
              icon: Icons.payment,
              title: "Payment Details",
              subtitle: "Manage payment Details",
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder:(context) => AdminBankingPage(), ));
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.lock,
              title: "Privacy & Security",
              subtitle: "Manage your security settings",
              onTap: () {},
            ),
            _buildSettingsTile(
              context,
              icon: Icons.palette,
              title: "App Theme",
              subtitle: "Switch between light and dark modes",
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  // Handle theme switch
                },
              ),
              onTap: () {},
            ),
            _buildDivider(),

            _buildSectionTitle("Support"),
            _buildSettingsTile(
              context,
              icon: Icons.help,
              title: "Help & Support",
              subtitle: "Get help or report issues",
              onTap: () {},
            ),
            _buildSettingsTile(
              context,
              icon: Icons.info,
              title: "About Us",
              subtitle: "Learn more about the app",
              onTap: () {},
            ),
            _buildDivider(),

            // Logout Button
            Center(
              child: TextButton(
                onPressed: () {
                  // Handle logout action
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  // Reusable Divider
  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(thickness: 1, color: Colors.grey),
    );
  }

  // Reusable Settings Tile
  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
        Widget? trailing,
        required VoidCallback onTap,
      }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: Colors.deepPurple, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        )
            : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
