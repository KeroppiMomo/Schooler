import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/ui/suggestion_text_field.dart';
import 'package:schooler/ui/setup/setup_completed_screen.dart';
import 'package:schooler/res/resources.dart';

SubjectEditorScreenResources _R = R.subjectEditorScreen;

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
            title: Text(_R.popConfirmTitle),
            content: Text(_R.popConfirmMessage),
            actions: <Widget>[
              FlatButton(
                child: Text(_R.popConfirmCancelText),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: Text(_R.popConfirmDiscardText),
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
          title: Text(_R.appBarTitle),
          leading: BackButton(),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  padding: _R.listPadding,
                  initialItemCount: Settings().subjects.length +
                      1, // +1 is the "Add Subject" button
                  itemBuilder: (context, i, animation) {
                    if (i == Settings().subjects.length) {
                      return FlatButton.icon(
                        label: Text(_R.addSubjectText),
                        icon: Icon(_R.addSubjectIcon),
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
                child: Text(_R.doneButtonText),
                onPressed: () => _onDonePressed(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubject(BuildContext context, int i, {Animation animation}) {
    Subject subject = Settings().subjects[i];
    final listTile = Builder(
      // To get the context for Scaffold.of
      builder: (context) => ListTile(
        leading: Icon(
          _R.subjectIcon,
          color: subject.color,
        ),
        title: subject.name == ''
            ? Text(_R.subjectPlaceholderText, style: R.placeholderTextStyle)
            : Text(subject.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_R.colorButtonIcon),
              tooltip: _R.colorButtonTooltip,
              onPressed: () {
                _showColorPicker(
                  context,
                  _R.getColorPickerTitle(subject.name),
                  subject.color,
                  (selectedColor) {
                    setState(() {
                      Settings().subjects[i].color = selectedColor;
                      Settings().saveSettings();
                    });
                  },
                  null,
                );
              },
            ),
            IconButton(
              icon: Icon(_R.removeSubjectIcon),
              tooltip: _R.removeSubjectTooltip,
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
        sizeFactor: animation
            .drive(CurveTween(curve: _R.removeSubjectSizeTransitionCurve)),
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
            child: Text(_R.colorPickerCancelText),
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
    Settings().subjects.add(_R.defaultNewSubject);
    Settings().saveSettings();

    _listKey.currentState.insertItem(Settings().subjects.length - 1);
  }

  void _removeSubject(BuildContext context, int i) {
    _listKey.currentState.removeItem(
      i,
      (context, animation) {
        final widget = AbsorbPointer(
            child: _buildSubject(context, i, animation: animation));
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
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SuggestionTextField(
            minItemForListView: _R.suggestionMinItemForListView,
            listViewHeight: _R.suggestionListViewHeight,
            curValue: subject.name,
            suggestionCallback: (pattern) {
              Set<String> suggestionList = Set();
              for (final sessions in Settings().timetable.timetable.values) {
                for (final session in sessions) {
                  if (session.name == '') continue;
                  if (session.name.length < pattern.length) continue;
                  if (session.name.substring(0, pattern.length).toLowerCase() ==
                      pattern.toLowerCase()) {
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
              if (Settings()
                  .subjects
                  .any((subject) => subject.name == newName)) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(_R.getSubjectNameExistMessage(newName)),
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => SetupCompletedScreen()));
  }
}
