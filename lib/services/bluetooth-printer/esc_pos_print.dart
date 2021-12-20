import 'package:flutter/material.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/foundation.dart';

class EscPosPrint extends StatefulWidget {
  @override
  _EscPosPrintState createState() => _EscPosPrintState();
}

class _EscPosPrintState extends State<EscPosPrint> {
  List<PrinterBluetooth> devicesList = [];

  PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  PrinterBluetooth? _connectedDevice;

  List<PrinterBluetooth> _fetchPrinterBluetooth() {
    if (_connectedDevice != null) {
      setState(() {
        // _connectedDevice?.disconnect();
        _connectedDevice = null;
      });
    }
    // devicesList.clear();

    // Start scanning
    printerManager.startScan(Duration(seconds: 4));

    printerManager.scanResults.listen((printers) async {
      // store found printers
      // do something with scan results
      for (PrinterBluetooth r in printers) {
        if (r.name != '' && !devicesList.contains(r)) {
          debugPrint('deviceName: ${r.name}');
          setState(() {
            devicesList.add(r);
          });
        }
      }
    });

    // Stop scanning
    // printerManager.stopScan();
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
                            Text(device.name  as String == ''
                                ? '(unknown device)'
                                : device.name  as String),
                            Text(device.address as String),
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
      body: _connectedDevice != null ? pageBody : pageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.settings_bluetooth),
          onPressed: _fetchPrinterBluetooth),
    );
  }
}
