import 'package:flutter/material.dart';

class AddressBar extends StatefulWidget {
  final String initialUrl;
  final void Function(String url) onNavigate;
  const AddressBar({required this.initialUrl, required this.onNavigate, Key? key}) : super(key: key);

  @override
  State<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (v) => widget.onNavigate(v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => widget.onNavigate(_controller.text),
        )
      ]),
    );
  }
}
