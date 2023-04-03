import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_example/bluetoothApp.dart';
import 'package:flutter_bluetooth_serial_example/voice.dart';

class drawer extends StatefulWidget {
  const drawer({Key key}) : super(key: key);

  @override
  State<drawer> createState() => _drawerState();
}

class _drawerState extends State<drawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Center(
              child: Text(
                'Smart Home control using hand gestures'.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: Colors.black,
            ),
            title: Text(
              'Home',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => BluetoothApp()),
              );
            },
          ),
          Divider(height: 2),
          ListTile(
            leading: Icon(
              Icons.voice_chat,
              color: Colors.black,
            ),
            title: Text(
              'Voice control',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => VoiceCommand()),
              // );
            },
          ),
          Divider(height: 2),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Colors.black,
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
