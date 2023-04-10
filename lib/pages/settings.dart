import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notification = true;
  bool _darkMode = false;
  bool _showImages = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notification = prefs.getBool('notification') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
      _showImages = prefs.getBool('showImages') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification', _notification);
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('showImages', _showImages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: ListView(
        children: [
          SwitchListTile(
            title:const Text('Notification'),
            value: _notification,
            onChanged: (bool value) {
              setState(() {
                _notification = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title:const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title:const Text('Show Images'),
            value: _showImages,
            onChanged: (bool value) {
              setState(() {
                _showImages = value;
              });
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }
}
