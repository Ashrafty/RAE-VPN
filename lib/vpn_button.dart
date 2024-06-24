import 'package:flutter/material.dart';

class VpnButton extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onPressed;

  const VpnButton({
    Key? key,
    required this.isConnected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 287,
        height: 287,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isConnected ? const Color(0xFF17692D) : const Color(0xFF05363F),
        ),
        child: Center(
          child: Text(
            isConnected ? 'Stop' : 'Start',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
