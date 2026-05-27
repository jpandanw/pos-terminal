//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import flutter_thermal_printer
import printing
import screen_retriever_macos
import shared_preferences_foundation
import unique_device_identifier
import universal_ble
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FlutterThermalPrinterPlugin.register(with: registry.registrar(forPlugin: "FlutterThermalPrinterPlugin"))
  PrintingPlugin.register(with: registry.registrar(forPlugin: "PrintingPlugin"))
  ScreenRetrieverMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  UniqueDeviceIdentifierPlugin.register(with: registry.registrar(forPlugin: "UniqueDeviceIdentifierPlugin"))
  UniversalBlePlugin.register(with: registry.registrar(forPlugin: "UniversalBlePlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
