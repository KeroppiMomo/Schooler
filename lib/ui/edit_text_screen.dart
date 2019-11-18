import 'package:flutter/material.dart';
import 'package:schooler/res/resources.dart';

/// Local resources.
final EditTextResources _R = R.editText;

class EditTextScreen extends StatefulWidget {
  final String title;
  final String value;
  final void Function(String) onDone;
  final void Function() onCancelled;

  EditTextScreen({
    this.title,
    this.value,
    this.onDone,
    this.onCancelled,
  });

  @override
  State<StatefulWidget> createState() => EditTextScreenState();
}

@visibleForTesting
class EditTextScreenState extends State<EditTextScreen> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: cancelPressed,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: donePressed,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: widget.title,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () => _controller.clear(),
                    tooltip: "Clear",
                  ),
                ),
                onSubmitted: (_) => donePressed(),
              ),
            ),
            Expanded(child: Container()),
            Divider(),
            FlatButton.icon(
              icon: Icon(Icons.clear),
              label: Text("Cancel"),
              onPressed: cancelPressed,
            ),
            Divider(),
            FlatButton.icon(
              icon: Icon(Icons.done),
              label: Text("Done"),
              onPressed: donePressed,
            ),
          ],
        ),
      ),
    );
  }

  void cancelPressed() {
    if (widget.onCancelled != null) widget.onCancelled();
    Navigator.of(context).pop();
  }

  void donePressed() {
    if (widget.onDone != null) widget.onDone(_controller.text);
    Navigator.of(context).pop();
  }
}
