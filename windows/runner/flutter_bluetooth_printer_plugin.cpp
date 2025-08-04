#include "flutter_bluetooth_printer_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <memory>

#include "bluetooth_helper.h"

namespace flutter_bluetooth_printer {

// Register the plugin with the registrar
    void FlutterBluetoothPrinterPlugin::RegisterWithRegistrar(
            flutter::PluginRegistrarWindows *registrar) {
        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "flutter_bluetooth_printer",
                        &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<FlutterBluetoothPrinterPlugin>();

        channel->SetMethodCallHandler(
                [plugin_pointer = plugin.get()](const auto& call, auto result) {
                    plugin_pointer->HandleMethodCall(call, std::move(result));
                });

        registrar->AddPlugin(std::move(plugin));
    }

// Handle method calls from Flutter
    void FlutterBluetoothPrinterPlugin::HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

        if (method_call.method_name().compare("getConnectedDevices") == 0) {
            auto devices = getConnectedBluetoothDevices();
            flutter::EncodableList device_list;
            for (const auto& device : devices) {
                flutter::EncodableMap device_map;
                device_map[flutter::EncodableValue("name")] = flutter::EncodableValue(device.name);
                device_map[flutter::EncodableValue("address")] = flutter::EncodableValue(device.address.ullLong);
                device_list.push_back(flutter::EncodableValue(device_map));
            }
            result->Success(flutter::EncodableValue(device_list));

        } else if (method_call.method_name().compare("printReceipt") == 0) {
            const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
            if (arguments) {
                std::wstring deviceName = std::get<std::wstring>(arguments->at(flutter::EncodableValue("deviceName")));
                std::string receiptData = std::get<std::string>(arguments->at(flutter::EncodableValue("receiptData")));

                auto devices = getConnectedBluetoothDevices();
                for (const auto& device : devices) {
                    if (device.name == deviceName) {
                        bool success = sendToPrinter(device.address, receiptData);
                        result->Success(flutter::EncodableValue(success));
                        return;
                    }
                }

                result->Error("Device not found", "Could not find Bluetooth device");
            } else {
                result->Error("Invalid arguments", "Expected a map with deviceName and receiptData");
            }
        } else {
            result->NotImplemented();
        }
    }

}  // namespace flutter_bluetooth_printer
