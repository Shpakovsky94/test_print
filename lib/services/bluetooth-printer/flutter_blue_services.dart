import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/foundation.dart';

class FlutterBlueServices extends StatefulWidget {
  @override
  _FlutterBlueServicesState createState() => _FlutterBlueServicesState();
}

class _FlutterBlueServicesState extends State<FlutterBlueServices> {
  List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = <BluetoothService>[];

  List<BluetoothDevice> _fetchBluetoothDevice() {
    if (_connectedDevice != null) {
      setState(() {
        _connectedDevice?.disconnect();
        _connectedDevice = null;
      });
    }
    devicesList.clear();

    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    // Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        if (r.device.name != '' && !devicesList.contains(r.device)) {
          debugPrint('deviceName: ${r.device.name}');
          setState(() {
            devicesList.add(r.device);
          });
        }
      }
    });

    // Stop scanning
    flutterBlue.stopScan();
    return devicesList;
  }

  ListView  _buildConnectDeviceView() {
    List<Container> containers = <Container>[];

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = <Widget>[];

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Value: ' + [characteristic.uuid].toString()),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        Container(
          child: ExpansionTile(
              title: Text(service.uuid.toString()),
              children: characteristicsWidget),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final PreferredSizeWidget appBar = AppBar(
      title: Text(
        'BLE connector',
        style: Theme.of(context).textTheme.headline6,
      ),
    );

    final pageBody =
    SafeArea(
      child: SingleChildScrollView(
          child: Column(
            children: [
              ...devicesList.map((device) {
                return Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Text(device.name == ''
                                ? '(unknown device)'
                                : device.name),
                            Text(device.id.toString()),
                          ],
                        ),
                      ),
                      FlatButton(
                          color: Colors.blue,
                          child: Text(
                            'Connect',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(
                                  () async {
                                flutterBlue.stopScan();
                                try {
                                  await device.connect();
                                } catch (e) {
                                  debugPrint('already_connected');
                                } finally {
                                  _services = await device.discoverServices();
                                }
                                setState(() {
                                  _connectedDevice = device;
                                });
                              },
                            );
                          })
                    ],
                  ),
                );
              }).toList(),
            ],
          )),
    );

    return Scaffold(
      appBar: appBar,
      body: _connectedDevice != null ? _buildConnectDeviceView() : pageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.settings_bluetooth),
          onPressed: _fetchBluetoothDevice),
    );
  }
}
