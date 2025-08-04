import 'dart:async';
import 'package:flutter/services.dart';

class FlutterBluetoothPrinter {
  static const MethodChannel _channel = MethodChannel('flutter_bluetooth_printer');

  // Get list of connected Bluetooth devices
  static Future<List<Map<String, String>>> getConnectedDevices() async {
    final List<dynamic> devices = await _channel.invokeMethod('getConnectedDevices');
    return devices.map((device) => Map<String, String>.from(device)).toList();
  }

  // Send receipt data to the Bluetooth printer
  static Future<bool> printReceipt(String deviceName, String receiptData) async {
    return await _channel.invokeMethod('printReceipt', {
      'deviceName': deviceName,
      'receiptData': receiptData,
    });
  }
}
