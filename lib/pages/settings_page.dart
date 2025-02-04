import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20),
                child: Text(
                  "Settings",
                 
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildSectionTitle("Account"),
            _buildListTile(
              context,
              icon: Icons.person,
              title: "Profile Settings",
              subtitle: "Update your personal details",
              onTap: () {
                // Navigate to profile settings page
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: const Divider(),
            ),
            _buildSectionTitle("Preferences"),
            _buildListTile(
              context,
              icon: Icons.notifications_active,
              title: "Notifications",
              subtitle: "Manage notification preferences",
              onTap: () {
                // Navigate to notification settings page
              },
            ),
            _buildListTile(
              context,
              icon: Icons.payment,
              title: "Payment Settings",
              subtitle: "Manage payment methods",
              onTap: () {
                // Navigate to payment settings page
              },
            ),
            _buildListTile(
              context,
              icon: Icons.lock,
              title: "Privacy & Security",
              subtitle: "Manage your security settings",
              onTap: () {
                // Navigate to privacy & security settings page
              },
            ),
            _buildListTile(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: const Divider(),
            ),
            _buildSectionTitle("Support"),
            _buildListTile(
              context,
              icon: Icons.help,
              title: "Help & Support",
              subtitle: "Get help or report issues",
              onTap: () {
                // Navigate to Help & Support page
              },
            ),
            _buildListTile(
              context,
              icon: Icons.info,
              title: "About Us",
              subtitle: "Learn more about the app",
              onTap: () {
                // Navigate to About Us page
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: const Divider(),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  // Handle logout action
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: Text(
        title,
       
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(
        title,
      
      ),
      subtitle: subtitle != null
          ? Text(subtitle, )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
