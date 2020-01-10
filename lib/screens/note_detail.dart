import 'package:flutter/material.dart';
import 'package:note_keeper/models/note.dart';
import 'package:intl/intl.dart';
import 'package:note_keeper/utils/database_helper.dart';
import 'dart:async';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  String appBarTitle;
  Note note;
  static var _priorities = ['High', 'Low'];

  //Define the SingleTon Instance of DataBaseHelper
  DataBaseHelper helper = DataBaseHelper();

  TextEditingController titleController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme
        .of(context)
        .textTheme
        .title;
    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 10.0, top: 15.0, right: 10.0),
          child: ListView(
            children: <Widget>[
              //First Element
              ListTile(
                title: DropdownButton(
                  //TODO:
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint('User selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  },
                ),
              ),

              //Second Element
              Padding(
                padding: EdgeInsets.only(
                    left: 0.0, top: 15.0, right: 0.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Title Text Field');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelStyle: textStyle,
                      labelText: 'Title',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              //Third Element
              Padding(
                padding: EdgeInsets.only(
                    left: 0.0, top: 15.0, right: 0.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Description Text Field');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelStyle: textStyle,
                      labelText: 'Description',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              //Fourth Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme
                            .of(context)
                            .primaryColorDark,
                        textColor: Theme
                            .of(context)
                            .primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("Save Button Clicked");
                            _save();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 5.0,
                    ),
                    Expanded(
                      child: RaisedButton(
                        color: Theme
                            .of(context)
                            .primaryColorDark,
                        textColor: Theme
                            .of(context)
                            .primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("Delete Button Clicked");
                            _delete();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context,true);
  }

//Convert the String priority in the form of integer priority before saving it to the Database

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

//Convert the integer priority to String Priority before saving it to the Database

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //'High
        break;
      case 2:
        priority = _priorities[1]; //'Low'
        break;
    }
    return priority;
  }

  //Update the title of the Note Object
  void updateTitle() {
    note.title = titleController.text;
  }

//update the description of the Note Object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  //Save data to Database
  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      //case 1: Update Operation
      result = await helper.updateNote(note);
    } else {
      //case 2: Insert Operation
      result = await helper.insertNote(note);
    }
    if (result != 0) {
      //Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      //Fail
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }


  //Delete the Note from Database
  void _delete() async {
    moveToLastScreen();
    //case 1: if the user is trying to delete the NEW NOTE i.e., he / she has come to the detail page by pressing the FAB button of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was Deleted');
      return;
    }

    // Case 2: if the user is trying to delete the old note that already has a valid ID.

    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title), content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

}
