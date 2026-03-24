import 'package:flutter/material.dart';

class BarcodeListenerWidget extends StatefulWidget {
  const BarcodeListenerWidget({super.key, required this.child});
  final Widget child;

  @override
  State<BarcodeListenerWidget> createState() => _BarcodeListenerWidgetState();
}

class _BarcodeListenerWidgetState extends State<BarcodeListenerWidget> {
  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();

    return KeyboardListener(
      focusNode: focusNode,
      child: widget.child,
      onKeyEvent: (value) {
        print(value.character);
      },
    );
  }
}
