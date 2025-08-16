import 'package:flutter/material.dart';

import '../../core/app/consts.dart';

class DropDownWidget extends StatelessWidget {
  final TensorflowModel? selected;
  final ValueChanged<TensorflowModel?> onChanged;

  const DropDownWidget({
    super.key,
    this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TensorflowModel>(
      value: selected,
      borderRadius: BorderRadius.circular(8),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none
        )
      ),
      hint: const Text("Selecciona un modelo"),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
      items: TensorflowModel.values.map((model) {
        return DropdownMenuItem<TensorflowModel>(
          value: model,
          child: Text(model.nombre),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
