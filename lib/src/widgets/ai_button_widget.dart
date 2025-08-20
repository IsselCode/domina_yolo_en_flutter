import 'package:flutter/material.dart';

class AiButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const AiButtonWidget({
    super.key,
    required this.onPressed,
    this.label = "Contar con IA",
  });

  @override
  State<AiButtonWidget> createState() => _GradientAiButtonState();
}

class _GradientAiButtonState extends State<AiButtonWidget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.98 : 1,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: const [
            Color(0xFF22E5D3), // teal
            Color(0xFF4F6CF5), // blue
            Color(0xFFB445E4), // purple
          ]),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            // sombra suave como el ejemplo
            BoxShadow(
              color: const [
                Color(0xFF22E5D3), // teal
                Color(0xFF4F6CF5), // blue
                Color(0xFFB445E4), // purple
              ].last.withOpacity(0.35),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            splashColor: Colors.white.withOpacity(0.12),
            highlightColor: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            onHighlightChanged: (v) => setState(() => _pressed = v),
            onTap: widget.onPressed,
            child: Center(
              child: Row(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono
                  const Icon(Icons.auto_awesome, color: Colors.white,),
                  // Texto
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }
}
