import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GridViewProductWidget extends StatelessWidget {

  final String image;
  final String name;
  final int qnty;
  final DateTime lastUpdated;
  final VoidCallback onTap;


  const GridViewProductWidget({
    super.key,
    required this.image,
    required this.name,
    required this.qnty,
    required this.lastUpdated,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkResponse(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [

            // Ultima actualización
            Positioned(
              right: 0,
              top: 0,
              child: Tooltip(
                message: DateFormat("dd/MMMM/yyyy - HH:mm:ss").format(lastUpdated),
                triggerMode: TooltipTriggerMode.tap,
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                child: AbsorbPointer( // <-- bloquea al child, pero NO al Tooltip
                  child: const SizedBox(
                    width: 48, height: 48,
                    child: Icon(Icons.access_time, size: 24),
                  ),
                ),
              ),
            ),

            // Cuerpo
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                spacing: 10,
                children: [
                  Expanded(child: Image.asset(image)),
                  Text(
                    name,
                    style: TextStyle(
                        fontSize: 18
                    ),
                  ),
                  Text(
                    qnty.toStringAsFixed(0),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
