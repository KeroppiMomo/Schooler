import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SuggestionTextField extends StatefulWidget {
  final String curValue;

  /// The minimum number of items for the suggestions widget to become a `ListView`.
  /// If the number of items is below this value, the items are placed in a `Column`.
  final int minItemForListView;
  final double listViewHeight;
  final List<String> Function(String) suggestionCallback;
  final void Function(String) onDone;

  SuggestionTextField({
    this.curValue,
    this.minItemForListView,
    this.listViewHeight,
    this.suggestionCallback,
    this.onDone,
  });

  @override
  State<StatefulWidget> createState() => SuggestionTextFieldState();
}

class SuggestionTextFieldState extends State<SuggestionTextField> {
  TextEditingController _textFieldController;

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController(text: widget.curValue);
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = widget.suggestionCallback == null
        ? []
        : widget.suggestionCallback(_textFieldController.text);
    final suggestionsChildren = suggestions
        .map((suggestion) => ListTile(
              title: Text(suggestion),
              onTap: () => _submit(suggestion),
            ))
        .toList();
    return Column(
      children: [
        Container(
          height: 44.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                pressedOpacity: 0.3,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Cancel',
                  style: const TextStyle(color: Colors.black54, fontSize: 16.0),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                pressedOpacity: 0.3,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Done',
                  style: const TextStyle(color: Colors.blue, fontSize: 16.0),
                ),
                onPressed: () => _submit(_textFieldController.text),
              ),
            ],
          ),
        ),
        widget.minItemForListView <= suggestions.length
            ? Container(
                height: widget.listViewHeight,
                child: ListView(children: suggestionsChildren),
              )
            : Column(children: suggestionsChildren),
        ...(suggestions.length == 0 ? [] : [Divider()]),
        TextField(
            controller: _textFieldController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 16.0),
            ),
            autofocus: true,
            onChanged: (newValue) => setState(() {}),
            onSubmitted: _submit),
      ],
    );
  }

  void _submit(String newValue) {
    Navigator.pop(context);
    widget.onDone?.call(newValue);
  }
}
