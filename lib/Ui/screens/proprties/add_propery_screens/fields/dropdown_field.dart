import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../utils/AppIcon.dart';
import '../../../../../utils/constant.dart';
import '../../../../../utils/ui_utils.dart';

class CustomDropdownField extends CustomField {
  @override
  String type = "dropdown";

  dynamic value;
  @override
  backValue() {
    return value;
  }

  @override
  void init() {
    id = data['id'];
    value = data['value'] ?? (data['type_values'] as List).first;

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
                color: context.color.tertiaryColor.withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(
                  10,
                ),
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
              width: 10.rw(
                context,
              ),
            ),
            Text(
              data['name'],
            )
                .size(
                  context.font.large,
                )
                .bold(weight: FontWeight.w500)
                .color(
                  context.color.textColorDark,
                )
          ],
        ),
        SizedBox(
          height: 14.rh(context),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
          ),
          child: Container(
            decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(
                  10,
                ),
                border: Border.all(
                  width: 1.5,
                  color: context.color.borderColor,
                )),
            child: Padding(
              padding: const EdgeInsets.all(
                8.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: DropdownButton(
                  value: value,
                  dropdownColor: context.color.secondaryColor,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  icon: SvgPicture.asset(AppIcons.downArrow),
                  isDense: true,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  style: TextStyle(
                      color: context.color.textLightColor,
                      fontSize: context.font.large),
                  underline: const SizedBox.shrink(),
                  items: (data['type_values'] as List)
                      .map((e) => DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          ))
                      .toList(),
                  onChanged: (dynamic v) {
                    value = v;
                    update(() {});
                    // widget.dropDownItemChange.value = v;
                    // AbstractField.fieldsData.addAll(
                    //   {
                    //     widget.parameters['id']: v,
                    //   },
                    // );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
