import 'package:day12/providers/weather_provider.dart';
import 'package:day12/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool status = false;
  @override
  void initState() {
    getTempUnitStatus().then((value) {
      setState(() {
        status = value;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Show temperature in Fahrenheit'),
            subtitle: Text('Default is Celsius'),
            value: status,
            onChanged: (value) async {
              setState(() {
                status = value;
              });
              await setTempUnitStatus(status);
              Provider.of<WeatherProvider>(context, listen: false)
              .getData();

            },
          ),
        ],
      ),
    );
  }
}
