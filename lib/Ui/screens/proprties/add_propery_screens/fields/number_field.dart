import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../../utils/constant.dart';
import '../../../../../utils/ui_utils.dart';
import '../../../widgets/custom_text_form_field.dart';

class CustomNumberField extends CustomField {
  @override
  String type = "number";
  TextEditingController? controller;
  @override
  void init() {
    id = data['id'];
    String initialValue = "";
    if (data['value'] != null && data['value'] != "null") {
      initialValue = "${data['value']}";
    }

    controller = TextEditingController(text: initialValue);
    super.init();
  }

  @override
  String? backValue() {
    return controller?.text;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget render(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: Column(
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
                  child: SizedBox(
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
            CustomTextFormField(
              hintText: "addNumerical".translate(context),
              action: TextInputAction.next,
              validator: CustomTextFieldValidator.nullCheck,
              formaters: [
                FilteringTextInputFormatter.allow(
                  RegExp("[0-9]"),
                ),
              ],
              keyboard: TextInputType.number,
              controller: controller,
              onChange: (value) {
                // AbstractField.fieldsData.addAll({widget.id: value});
              },
            )
          ],
        ));
  }
}
