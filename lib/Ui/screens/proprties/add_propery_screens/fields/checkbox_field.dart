import 'dart:convert';

import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/constant.dart';
import '../../../../../utils/ui_utils.dart';

class CheckboxField extends CustomField {
  List checkedValues = [];
  List checkBoxValues = [];
  @override
  String type = "checkbox";
  String backValues = "";

  @override
  backValue() {
    return backValues;
  }

  @override
  void init() {
    id = data['id'];
    checkBoxValues = data['type_values'];
    if (data['value'] != null) {
      var selectedValue = data['value'].toString().split(",");
      checkedValues = selectedValue;
    }
    Map dataMap = checkedValues.fold(
        {},
        (previousValue, element) =>
            previousValue..addAll({"${previousValue.length}": element}));

    backValues = json.encode(dataMap);
    super.init();
  }

  @override
  Widget render(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48.rw(context),
              height: 48.rh(context),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                height: 24,
                width: 24,
                child: FittedBox(
                  fit: BoxFit.none,
                  child: UiUtils.imageType(data['image'],
                      color: Constant.adaptThemeColorSvg
                          ? context.color.tertiaryColor
                          : null,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(
              width: 10.rw(context),
            ),
            Text(data['name'])
                .size(context.font.large)
                .bold(weight: FontWeight.w500)
                .color(context.color.textColorDark)
          ],
        ),
        SizedBox(
          height: 14.rh(context),
        ),
        Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: List.generate(
            checkBoxValues?.length ?? 0,
            (index) {
              //this variable will prevent adding when state change
              ///this will work like init state text

              return Padding(
                padding: EdgeInsetsDirectional.only(
                    start: index == 0 ? 0 : 4, bottom: 4, top: 4, end: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (checkedValues.contains(checkBoxValues[index])) {
                      checkedValues.remove(checkBoxValues[index]);
                    } else {
                      checkedValues.add(checkBoxValues[index]);
                    }

                    Map dataMap = checkedValues.fold(
                        {},
                        (previousValue, element) => previousValue
                          ..addAll({"${previousValue.length}": element}));

                    backValues = json.encode(dataMap);

                    update(() {});
                    // AbstractField.fieldsData
                    //     .addAll({widget.parameters['id']: json.encode(temp)});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: context.color.borderColor, width: 1.5),
                        color: checkedValues.contains(checkBoxValues[index])
                            ? context.color.tertiaryColor.withOpacity(0.1)
                            : context.color.secondaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            checkedValues.contains(checkBoxValues[index])
                                ? Icons.done
                                : Icons.add,
                            color: checkedValues.contains(checkBoxValues[index])
                                ? context.color.tertiaryColor
                                : context.color.textColorDark,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(checkBoxValues[index]).color(
                              checkedValues.contains(checkBoxValues[index])
                                  ? context.color.tertiaryColor
                                  : context.color.textLightColor)
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
