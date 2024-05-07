// ignore_for_file: depend_on_referenced_packages

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/ui/screens/proprties/add_propery_screens/property_success.dart';
import 'package:ebroker/ui/screens/widgets/animated_routes/scale_up_route.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart' as h;
import 'package:mime/mime.dart';

import '../Property tab/sell_rent_screen.dart';

class SetProeprtyParametersScreen extends StatefulWidget {
  final Map propertyDetails;
  final bool isUpdate;
  const SetProeprtyParametersScreen(
      {super.key, required this.propertyDetails, required this.isUpdate});
  static Route route(RouteSettings settings) {
    Map? argument = settings.arguments as Map?;

    return BlurredRouter(
      builder: (context) {
        return SetProeprtyParametersScreen(
          propertyDetails: argument?['details'],
          isUpdate: argument?['isUpdate'],
        );
      },
    );
  }

  @override
  State<SetProeprtyParametersScreen> createState() =>
      _SetProeprtyParametersScreenState();
}

class _SetProeprtyParametersScreenState
    extends State<SetProeprtyParametersScreen>
    with AutomaticKeepAliveClientMixin {
  List<ValueNotifier> disposableFields = [];
  bool newCustomFields = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  List galleryImage = [];
  File? titleImage;
  File? t360degImage;
  File? meta_image;
  Map<String, dynamic>? apiParameters;
  List<RenderCustomFields> paramaeterUI = [];
  @override
  void initState() {
    apiParameters = Map.from(widget.propertyDetails);
    galleryImage = apiParameters!['gallery_images'];
    titleImage = apiParameters!['title_image'];
    t360degImage = apiParameters!['threeD_image'];
    meta_image = apiParameters!['meta_image'];
    Future.delayed(
      Duration.zero,
      () {
        paramaeterUI =
            (Constant.addProperty['category']?.parameterTypes as List)
                .mapIndexed((index, element) {
          var data = element;

          if (element is! Map) {
            data = (element as Parameter).toMap();
          }
          return RenderCustomFields(
              index: index,
              field: KRegisteredFields().get(data['type_of_parameter']) ??
                  BlankField(),
              data: data);
        }).toList();

        setState(() {});
      },
    );
    super.initState();
  }

  ///This will convert {0:Demo} to it's required format here we have assigned Parameter id : value, before.

  List<RenderCustomFields> buildFields() {
    if (Constant.addProperty['category'] == null) {
      return [
        RenderCustomFields(field: BlankField(), data: const {}, index: 0)
      ];
    }

    ///Loop parameters
    return paramaeterUI;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        actions: const [
          Text("3/4"),
          SizedBox(
            width: 14,
          ),
        ],
        title: widget.isUpdate
            ? UiUtils.translate(context, "updateProperty")
            : UiUtils.translate(context, "ddPropertyLbl"),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 7),
        child: UiUtils.buildButton(
          context,
          height: 48.rh(context),
          onPressed: () async {
            // if (_formKey.currentState!.validate() == false) return;

            Map parameterValues =
                paramaeterUI.fold({}, (previousValue, element) {
              previousValue.addAll({
                "parameters[${previousValue.length ~/ 2}][parameter_id]":
                    element.getId(),
                "parameters[${previousValue.length ~/ 2}][value]":
                    element.getValue(),
              });

              return previousValue;
            });
            apiParameters?.addAll(Map.from(parameterValues));

            /// Multipart image of gallery images
            List gallery = [];
            await Future.forEach(
              galleryImage,
              (dynamic item) async {
                var multipartFile = await MultipartFile.fromFile(item.path);
                if (!multipartFile.isFinalized) {
                  gallery.add(multipartFile);
                }
              },
            );
            apiParameters!['gallery_images'] = gallery;

            if (titleImage != null) {
              ///Multipart image of title image
              final mimeType = lookupMimeType((titleImage as File).path);
              var extension = mimeType!.split("/");
              apiParameters!['title_image'] = await MultipartFile.fromFile(
                  (titleImage as File).path,
                  contentType: h.MediaType('image', extension[1]),
                  filename: (titleImage as File).path.split("/").last);
            }

            //set 360 deg image

            if (t360degImage != null) {
              final mimeType = lookupMimeType(t360degImage!.path);
              var extension = mimeType!.split("/");

              apiParameters!['threeD_image'] = await MultipartFile.fromFile(
                  t360degImage?.path ?? "",
                  contentType: h.MediaType('image', extension[1]),
                  filename: t360degImage?.path.split("/").last);
            }

            if (meta_image != null) {
              final mimeType = lookupMimeType(meta_image!.path);
              List<String> extension = mimeType!.split("/");
              apiParameters!['meta_image'] = await MultipartFile.fromFile(
                  meta_image?.path ?? "",
                  contentType: h.MediaType('image', extension[1]),
                  filename: meta_image?.path.split("/").last);
            }

            Future.delayed(
              Duration.zero,
              () {
                // / if (Constant.isDemoModeOn) {
                // /   HelperUtils.showSnackBarMessage(
                // /       context,
                // UiUtils.getTranslatedLabel(
                // context, "thisActionNotValidDemo"));
                //   return;
                // }

                // Navigator.push(context, MaterialPageRoute(builder: (context) {
                //   return SelectOutdoorFacility();
                // },));
                apiParameters?['isUpdate'] = widget.isUpdate;
                Navigator.pushNamed(context, Routes.selectOutdoorFacility,
                    arguments: apiParameters);

                // context
                //     .read<CreatePropertyCubit>()
                //     .create(parameters: apiParameters!);
              },
            );
          },
          buttonTitle: UiUtils.translate(context, "next"),
        ),
      ),
      body: Form(
        key: _formKey,
        child: BlocListener<CreatePropertyCubit, CreatePropertyState>(
          listener: (context, state) {
            if (state is CreatePropertyInProgress) {
              Widgets.showLoader(context);
            }

            if (state is CreatePropertyFailure) {
              Widgets.hideLoder(context);
              HelperUtils.showSnackBarMessage(context, state.errorMessage);
            }
            if (state is CreatePropertySuccess) {
              Widgets.hideLoder(context);
              if (widget.isUpdate == false) {
                ref[propertyType ?? "sell"]
                    ?.fetchMyProperties(type: propertyType ?? "sell");
                Future.delayed(
                  const Duration(milliseconds: 260),
                  () {
                    Navigator.pushReplacement(
                        context,
                        ScaleUpRouter(
                          builder: (context) {
                            return PropertyAddSuccess(
                              model: state.propertyModel!,
                            );
                          },
                          current: widget,
                        ));
                  },
                );
              } else {
                context.read<PropertyEditCubit>().add(state.propertyModel!);
                context
                    .read<FetchMyPropertiesCubit>()
                    .update(state.propertyModel!);
                cubitReference?.update(state.propertyModel!);
                HelperUtils.showSnackBarMessage(
                    context, UiUtils.translate(context, "propertyUpdated"),
                    type: MessageType.success, onClose: () {
                  Navigator.of(context)
                    ..pop()
                    ..pop()
                    ..pop()
                    ..pop();
                });
              }
            }
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(UiUtils.translate(context, "addvalues")),
                  const SizedBox(
                    height: 18,
                  ),
                  ...buildFields(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
