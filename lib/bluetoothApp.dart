import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/drawer.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,
  };

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _devicesList = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {},
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Bluetooth connection"),
          // backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                getPairedDevices();
                show("Refreshing the list of devices");
              },
            ),
            IconButton(
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
              icon: Icon(Icons.bluetooth),
            ),
          ],
        ),
        drawer: drawer(),
        body: Container(
          child: ListView(
            children: <Widget>[
              Visibility(
                visible: _isButtonUnavailable &&
                    _bluetoothState == BluetoothState.STATE_ON,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.yellow,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Enable Bluetooth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                            show("Bluetooth is enabled");
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                            show("Bluetooth is disabled");
                          }

                          await getPairedDevices();
                          _isButtonUnavailable = false;

                          if (_connected) {
                            _disconnect();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: DropdownButtonFormField(
                          enableFeedback: true,
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              // borderSide: BorderSide.none,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                          items: _getDeviceItems(),
                          onChanged: (value) => setState(() => _device = value),
                          value: _devicesList.isNotEmpty ? _device : null,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isButtonUnavailable
                              ? null
                              : _connected
                                  ? _disconnect
                                  : _connect,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              _connected ? 'Disconnect' : 'Connect',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                // physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    DeviceWidget((index + 1).toString()),
                itemCount: 4,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "NOTE: If you cannot find the device in the list, please pair the device by going to the bluetooth settings",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding DeviceWidget(
    String deviceNumber,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "Device $deviceNumber",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _connected
                    ? () {
                        _sendOnMessageToBluetooth(deviceNumber + "on");
                      }
                    : null,
                child: Text("ON"),
              ),
              TextButton(
                onPressed: _connected
                    ? () {
                        _sendOnMessageToBluetooth(deviceNumber + "off");
                      }
                    : null,
                child: Text("OFF"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    if (_device.toString() != "HC-05") {
      setState(() {
        _isButtonUnavailable = true;
      });
      if (_device == null) {
        show('No device selected');
      } else {
        if (!isConnected) {
          await BluetoothConnection.toAddress(_device.address)
              .then((_connection) {
            print('Connected to the device');
            connection = _connection;
            setState(() {
              _connected = true;
            });

            connection.input.listen(null).onDone(() {
              if (isDisconnecting) {
                print('Disconnecting locally!');
              } else {
                print('Disconnected remotely!');
              }
              if (this.mounted) {
                setState(() {});
              }
            });
          }).catchError((error) {
            print('Cannot connect, exception occurred');
            print(error);
          });
          // show('Device connected');

          setState(() => _isButtonUnavailable = false);
        }
      }
    } else {
      show('Please select the correct device');
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  void _sendOnMessageToBluetooth(String input) async {
    connection.output.add(utf8.encode(input + "\r\n"));
    await connection.output.allSent;
    if (input.contains("on")) {
      show('Device Turned On');
    } else {
      show('Device Turned Off');
    }
    setState(() {
      _deviceState = 1; // device on
    });
  }

  // void _sendOffMessageToBluetooth() async {
  //   connection.output.add(utf8.encode("0" + "\r\n"));
  //   await connection.output.allSent;
  //   show('Device Turned Off');
  //   setState(() {
  //     _deviceState = -1; // device off
  //   });
  // }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}
