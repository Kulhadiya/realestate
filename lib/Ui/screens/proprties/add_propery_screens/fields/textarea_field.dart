import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/cupertino.dart';

import '../../../../../utils/constant.dart';
import '../../../../../utils/ui_utils.dart';
import '../../../widgets/custom_text_form_field.dart';

class CustomTextAreaField extends CustomField {
  @override
  String type = "textarea";
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
  backValue() {
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
      padding: const EdgeInsets.symmetric(
        vertical: .0,
      ),
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
                  .color(
                    context.color.textColorDark,
                  )
                  .bold(weight: FontWeight.w500)
            ],
          ),
          SizedBox(
            height: 14.rh(context),
          ),
          CustomTextFormField(
            hintText: "Write something...",
            minLine: 4,
            maxLine: 100,
            validator: CustomTextFieldValidator.maxFifty,
            controller: controller,
            onChange: (value) {},
          )
        ],
      ),
    );
  }
}
