import 'package:flutter/material.dart';
import 'package:schooler/res/resources.dart';

/// Local resources.
final EditTextResources _R = R.editText;

class EditTextScreen extends StatefulWidget {
  final String title;
  final String value;
  final int maxLines;
  final void Function(String) onDone;
  final void Function() onCancelled;

  EditTextScreen({
    this.title,
    this.value,
    this.maxLines = 1,
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
          icon: Icon(_R.cancelIcon),
          onPressed: cancelPressed,
        ),
        actions: [
          IconButton(
            icon: Icon(_R.doneIcon),
            onPressed: donePressed,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: _R.textFieldPadding,
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLines: widget.maxLines,
                    decoration: InputDecoration(
                      labelText: widget.title,
                      suffixIcon: IconButton(
                        icon: Icon(_R.clearButtonIcon),
                        onPressed: () => _controller.clear(),
                        tooltip: _R.clearButtonTooltip,
                      ),
                    ),
                    onSubmitted: (_) => donePressed(),
                  ),
                ),
              ),
            ),
            Divider(),
            FlatButton.icon(
              icon: Icon(_R.cancelIcon),
              label: Text(_R.cancelText),
              onPressed: cancelPressed,
            ),
            Divider(),
            FlatButton.icon(
              icon: Icon(_R.doneIcon),
              label: Text(_R.doneText),
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
