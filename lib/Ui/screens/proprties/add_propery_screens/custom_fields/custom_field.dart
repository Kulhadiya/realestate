import 'package:flutter/material.dart';

import '../../../../../exports/main_export.dart';

abstract class CustomField<T> {
  ///id
  dynamic id;

  //this will be to use context [not set now, it will be implement by implementing classes]
  late BuildContext context;

  //to update state
  late void Function(VoidCallback fn) update;

  ///data
  Map data = {};

  ///init field
  void init() {}

  ///dispose required resourses
  void dispose() {}

  ///this is to return value which you want to set in api
  T backValue();
  abstract String type;
  Widget render(BuildContext context);
}

class RenderCustomFields extends StatefulWidget {
  final int index;
  final CustomField field;
  final Map data;
  const RenderCustomFields(
      {super.key,
      required this.field,
      required this.data,
      required this.index});

  getId() {
    return field.id;
  }

  getValue() {
    return field.backValue();
  }

  dispose() {
    field.dispose();
  }

  @override
  State<RenderCustomFields> createState() => _RenderCustomFieldsState();
}

class _RenderCustomFieldsState extends State<RenderCustomFields> {
  @override
  void initState() {
    widget.field.update = setState;
    widget.field.data = widget.data;
    widget.field.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.field.update = setState;
    widget.field.context = context;
    widget.field.data = widget.data;

    return Padding(
      padding: EdgeInsets.only(top: widget.index == 0 ? 0 : 10, bottom: 10),
      child: widget.field.render(context),
    );
  }
}

class BlankField extends CustomField {
  @override
  String type = "blank";

  @override
  Widget render(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  backValue() {
    return null;
  }
}

class KRegisteredFields {
  final List _fields = [
    CustomTextField(),
    CustomNumberField(),
    CustomTextAreaField(),
    CustomDropdownField(),
    CustomRadioField(),
    CheckboxField(),
    CustomFileField()
  ];

  CustomField? get(String type) {
    CustomField? selectedField;
    for (CustomField field in _fields) {
      if (field.type == type) {
        selectedField = field;
      }
    }

    return selectedField;
  }
}
// fieldType == "textarea"
// fieldType == 'textbox'
// fieldType == 'number'
// fieldType == 'dropdown'
// fieldType == 'radiobutton'
// fieldType == "checkbox"

//////////////////////////////
//
//
//
// fieldType == "file"
