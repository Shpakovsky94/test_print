import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class FlutterBlueServiceTest extends StatefulWidget {
  @override
  _FlutterBlueServiceTestState createState() => _FlutterBlueServiceTestState();
}

class _FlutterBlueServiceTestState extends State<FlutterBlueServiceTest> {
  List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = <BluetoothService>[];

  BluetoothService? printService;
  BluetoothCharacteristic? printCharacteristic;
  var index = 0;
  var data;
  var image = Image.asset('/assets/qr.png');

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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final PreferredSizeWidget appBar = AppBar(
      title: Text(
        'BLE connector',
        style: Theme.of(context).textTheme.headline6,
      ),
    );


    Future<void> writeData(characteristic, data) async{
      if (characteristic == null) return;
      try {
        var utf8Encoded = utf8.encode(data);
        debugPrint(data.toString());
       var result = await characteristic.write(utf8Encoded);
        debugPrint(result.toString());
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    Future<void> _print() async {
      var serviceUuid = '0000ff00-0000-1000-8000-00805f9b34fb';
      var characteristicsUuid = '0000ff02-0000-1000-8000-00805f9b34fb';

      _services.forEach((service) {
        if(service.uuid.toString().toLowerCase() == serviceUuid) {
          printService = service;

          for (var c in printService!.characteristics) {
            if(c.uuid.toString().toLowerCase() == characteristicsUuid) {
              var ZPL_TEST_LABEL = 'Hello WeChat!\r\n';

              printCharacteristic = c;
              writeData(printCharacteristic, ZPL_TEST_LABEL);
            }
        }
      }});
    }


    Widget _buildPrintDeviceView() {
     return  Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Text(_connectedDevice!.name),
                Text(_connectedDevice!.id.toString()),
              ],
            ),
          ),
          FlatButton(
              color: Colors.blue,
              child: Text(
                'Print',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                _print();
              }),
        ],
      );
    }

    final pageBody = SafeArea(
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
                      onPressed: () async {
                        flutterBlue.stopScan();
                        try {
                        setState(() {
                          device.connect();
                        });
                        } catch (e) {
                          debugPrint('already_connected');
                        } finally {
                          _services = await device.discoverServices();
                        }
                        setState(() {
                          _connectedDevice = device;
                        });
                      }),
                ],
              ),
            );
          }).toList(),
        ],
      )),
    );

    return Scaffold(
      appBar: appBar,
      body: _connectedDevice != null ? _buildPrintDeviceView() : pageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.settings_bluetooth),
          onPressed: _fetchBluetoothDevice),
    );
  }
}
