import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum MascotState { idle, thinking, addData, updateData, coverEyes }

class MrWalletMascot extends StatelessWidget {
  final MascotState state;
  final double height;
  final bool isPasswordFocused;

  const MrWalletMascot({
    Key? key,
    this.state = MascotState.idle,
    this.height = 180.0,
    this.isPasswordFocused = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String assetPath = 'assets/animations/mr_wallet.json';

    if (isPasswordFocused || state == MascotState.coverEyes) {
      assetPath = 'assets/animations/card.json';
    } else {
      switch (state) {
        case MascotState.addData:
          assetPath = 'assets/animations/add_data.json';
          break;
        case MascotState.updateData:
          assetPath = 'assets/animations/update_data.json';
          break;
        case MascotState.thinking:
          assetPath = 'assets/animations/mr_wallet.json';
          break;
        case MascotState.idle:
        default:
          assetPath = 'assets/animations/mr_wallet.json';
          break;
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Lottie.asset(
          assetPath,
          height: height,
          fit: BoxFit.contain,
          
        ),
        if (isPasswordFocused)
          Positioned(
            top: height * 0.35,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_off, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    '🙈 Eyes Covered!',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
