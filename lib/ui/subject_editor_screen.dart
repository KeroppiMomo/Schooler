import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/ui/suggestion_text_field.dart';

class SubjectEditorScreen extends StatefulWidget {
  final void Function() onPop;

  SubjectEditorScreen({this.onPop});

  @override
  SubjectEditorScreenState createState() => SubjectEditorScreenState();
}

class SubjectEditorScreenState extends State<SubjectEditorScreen> {
  GlobalKey<AnimatedListState> _listKey;

  @override
  void initState() {
    super.initState();
    if (Settings().subjects == null) {
      Settings().subjects = [];
      Settings().saveSettings();
    }

    _listKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final dismiss = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Discard Subjects'),
            content: Text(
                'Are you sure to discard the subjects and return to the previous page?'),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: Text('DISCARD AND RETURN'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
        if (!(dismiss ?? false)) return false;
        widget.onPop?.call();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Subjects'),
          leading: BackButton(),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  padding: EdgeInsets.all(16.0),
                  initialItemCount:
                      Settings().subjects.length + 1, // +1 is the "Add Subject" button
                  itemBuilder: (context, i, animation) {
                    if (i == Settings().subjects.length) {
                      return FlatButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Add Subject'),
                        onPressed: () => _addSubject(context),
                      );
                    } else {
                      return _buildSubject(context, i, animation: animation);
                    }
                  },
                ),
              ),
              Divider(),
              FlatButton(
                child: Text('Done'),
                onPressed: () => _onDonePressed(context),
              ),
            ]
          ),
        ),
      ),
    );
  }

  Widget _buildSubject(BuildContext context, int i, {Animation animation}) {
    Subject subject = Settings().subjects[i];
    final listTile = Builder( // To get the context for Scaffold.of
      builder: (context) => ListTile(
        leading: Icon(
          Icons.book,
          color: subject.color,
        ),
        title: Text(subject.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.palette),
              tooltip: 'Change Color',
              onPressed: () {
                _showColorPicker(
                  context,
                  'Select color for "${subject.name}"',
                  subject.color,
                  (selectedColor) {
                    setState(() => subject.color = selectedColor);
                  },
                  null,
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Remove Subject',
              onPressed: () => _removeSubject(context, i),
            ),
          ],
        ),
        onTap: () => _onEditName(context, i),
      ),
    );

    if (animation == null)
      return listTile;
    else
      return SizeTransition(
        axisAlignment: -1.0,
        sizeFactor: animation.drive(CurveTween(curve: Curves.easeInOut)),
        child: FadeTransition(
          opacity: animation.drive(Tween(begin: 0, end: 1)),
          child: listTile,
        ),
      );
  }

  void _showColorPicker(BuildContext context, String title, Color color,
      void Function(Color) onSelected, void Function() onCancelled) {
    showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: MaterialColorPicker(
          selectedColor: color,
          allowShades: false,
          onMainColorChange: (selectedColor) =>
              Navigator.of(context).pop(selectedColor),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ).then((Color selectedColor) {
      if (selectedColor == null)
        onCancelled?.call();
      else
        onSelected?.call(selectedColor);
    });
  }

  void _addSubject(BuildContext context) {
    Settings().subjects.add(Subject('', color: Colors.grey));
    Settings().saveSettings();

    _listKey.currentState.insertItem(Settings().subjects.length - 1);
  }

  void _removeSubject(BuildContext context, int i) {
    _listKey.currentState.removeItem(
      i,
      (context, animation) {
        final widget = AbsorbPointer(child: _buildSubject(context, i, animation: animation));
        Settings().subjects.removeAt(i);
        Settings().saveSettings();
        return widget;
      },
    );
  }

  void _onEditName(BuildContext context, int i) {
    final subject = Settings().subjects[i];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SuggestionTextField(
            minItemForListView: 4,
            listViewHeight: 195.0,
            curValue: subject.name,
            suggestionCallback: (pattern) {
              Set<String> suggestionList = Set();
              for (final sessions in Settings().timetable.timetable.values) {
                for (final session in sessions) {
                  if (session.name == '') continue;
                  if (session.name.length < pattern.length) continue;
                  if (session.name.substring(0, pattern.length).toLowerCase() == pattern.toLowerCase()) {
                    suggestionList.add(session.name);
                  }
                }
              }
              for (final subject in Settings().subjects) {
                suggestionList.remove(subject.name);
              }
              return suggestionList.toList();
            },
            onDone: (newName) {
              if (Settings().subjects[i].name == newName) return;
              if (Settings().subjects.any((subject) => subject.name == newName)) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Subject with name "$newName" already exists.'),
                ));
                return;
              }
              setState(() {
                Settings().subjects[i].name = newName;
                Settings().saveSettings();
              });
            },
          ),
        ),
      ),
    );
  }

  void _onDonePressed(BuildContext context) {
    // TODO
  }
}
