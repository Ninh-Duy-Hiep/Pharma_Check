import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color selectedColor;
  ColorPickerDialog(this.selectedColor);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color _currentColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Chọn màu"),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: _currentColor,
          onColorChanged: (color) {
            setState(() => _currentColor = color);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _currentColor),
          child: const Text("Chọn"),
        ),
      ],
    );
  }
}
