import 'dart:developer';

import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../data/model/category.dart';
import '../../../../utils/imagePicker.dart';
import '../../widgets/panaroma_image_view.dart';

class AddPropertyDetails extends StatefulWidget {
  final Map? propertyDetails;

  const AddPropertyDetails({super.key, this.propertyDetails});

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return AddPropertyDetails(
          propertyDetails: arguments?['details'],
        );
      },
    );
  }

  @override
  State<AddPropertyDetails> createState() => _AddPropertyDetailsState();
}

class _AddPropertyDetailsState extends State<AddPropertyDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _propertyNameController =
      TextEditingController(text: widget.propertyDetails?['name']);
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.propertyDetails?['desc']);
  late final TextEditingController _cityNameController =
      TextEditingController(text: widget.propertyDetails?['city']);
  late final TextEditingController _stateNameController =
      TextEditingController(text: widget.propertyDetails?['state']);
  late final TextEditingController _countryNameController =
      TextEditingController(text: widget.propertyDetails?['country']);
  late final TextEditingController _latitudeController =
      TextEditingController(text: widget.propertyDetails?['latitude']);
  late final TextEditingController _longitudeController =
      TextEditingController(text: widget.propertyDetails?['longitude']);
  late final TextEditingController _addressController =
      TextEditingController(text: widget.propertyDetails?['address']);
  late final TextEditingController _priceController =
      TextEditingController(text: widget.propertyDetails?['price']);
  late final TextEditingController _clientAddressController =
      TextEditingController(text: widget.propertyDetails?['client']);

  late final TextEditingController _videoLinkController =
      TextEditingController();

  bool isPrivateProperty = false;

  ///META DETAILS
  late final TextEditingController metaTitleController =
      TextEditingController();
  late final TextEditingController metaDescriptionController =
      TextEditingController();
  late final TextEditingController metaKeywordController =
      TextEditingController();

  ///
  Map propertyData = {};
  final PickImage _pickTitleImage = PickImage();
  final PickImage _propertiesImagePicker = PickImage();
  final PickImage _pick360deg = PickImage();
  final PickImage _pickMetaTitle = PickImage();
  List editPropertyImageList = [];
  String titleImageURL = "";
  String metaImageUrl = "";
  String selectedRentType = "Monthly";
  List removedImageId = [];
  int propertyType = 0;

  List<dynamic> mixedPropertyImageList = [];

  @override
  void initState() {
    // log("WIDGET ${widget.propertyDetails]}");
    propertyType = widget.propertyDetails?['propType'] == "rent" ? 1 : 0;
    titleImageURL = widget.propertyDetails?['titleImage'] ?? "";
    metaImageUrl = widget.propertyDetails?['allPropData']['meta_image'] ?? "";
    mixedPropertyImageList =
        List<dynamic>.from(widget.propertyDetails?['images'] ?? []);
    if ((widget.propertyDetails != null)) {
      selectedRentType = widget.propertyDetails?['rentduration'] ?? "Monthly";
      isPrivateProperty =
          widget.propertyDetails?['allPropData']?['is_premium'] ?? false;
    }

    metaTitleController.text =
        widget.propertyDetails?['allPropData']['meta_title'] ?? "";
    metaDescriptionController.text =
        widget.propertyDetails?['allPropData']['meta_description'] ?? "";
    metaKeywordController.text =
        widget.propertyDetails?['allPropData']['meta_keywords'] ?? "";
    _propertiesImagePicker.listener((images) {
      try {
        mixedPropertyImageList.addAll(List<dynamic>.from(images));
      } catch (e) {}

      setState(() {});
    });

    _pickMetaTitle.listener((p0) {
      metaImageUrl = "";
      if (mounted) setState(() {});
    });
    _pickTitleImage.listener((p0) {
      titleImageURL = "";
      if (mounted) setState(() {});
    });
    super.initState();
  }

  void _onTapChooseLocation(FormFieldState state) async {
    FocusManager.instance.primaryFocus?.unfocus();
    double localLatitude = 0.0;
    double localLongitude = 0.0;
    if (Hive.box(HiveKeys.userDetailsBox)
        .get("latitude")
        .toString()
        .isNotEmpty) {
      dynamic latitudeValue =
          Hive.box(HiveKeys.userDetailsBox).get("latitude") ?? "0";
      localLatitude = double.tryParse(latitudeValue.toString()) ?? 0.0;
    }
    if (Hive.box(HiveKeys.userDetailsBox)
        .get("longitude")
        .toString()
        .isNotEmpty) {
      dynamic longitudeValue =
          Hive.box(HiveKeys.userDetailsBox).get("longitude") ?? "0";
      localLongitude = double.tryParse(longitudeValue.toString()) ?? 0.0;
    }

    Map? placeMark = await Navigator.pushNamed(
        context, Routes.chooseLocaitonMap,
        arguments: {
          "latitude": widget.propertyDetails?['latitude'] != null
              ? double.parse(widget.propertyDetails?['latitude'])
              : null,
          "longitude": widget.propertyDetails?['longitude'] != null
              ? double.parse(widget.propertyDetails?['longitude'])
              : null
        }) as Map?;
    var latlng = placeMark?['latlng'] as LatLng?;
    Placemark? place = placeMark?['place'] as Placemark?;
    if (latlng != null && place != null) {
      _latitudeController.text = latlng.latitude.toString();
      _longitudeController.text = latlng.longitude.toString();
      _cityNameController.text = place.locality ?? "";
      _countryNameController.text = place.country ?? "";
      _stateNameController.text = place.administrativeArea ?? "";
      _addressController.text = "";
      _addressController.text = getAddress(place);

      state.didChange(true);
    } else {
      // state.didChange(false);
    }
  }

  String getAddress(Placemark place) {
    try {
      String address = "";
      if (place.street == null && place.subLocality != null) {
        address = place.subLocality!;
      } else if (place.street == null && place.subLocality == null) {
        address = "";
      } else {
        address = "${place.street ?? ""},${place.subLocality ?? ""}";
      }

      return address;
    } catch (e, st) {
      throw Exception("$st");
    }
  }

  void _onTapContinue() async {
    File? titleImage;
    File? v360Image;
    File? metaTitle;

    if (_pickTitleImage.pickedFile != null) {
      // final mimeType = lookupMimeType(_pickTitleImage.pickedFile!.path);
      // var extension = mimeType!.split("/");

      titleImage = _pickTitleImage.pickedFile;
    }

    if (_pick360deg.pickedFile != null) {
      // final mimeType = lookupMimeType(_pick360deg.pickedFile!.path);
      // var extension = mimeType!.split("/");

      v360Image = _pick360deg.pickedFile;
    }

    if (_pickMetaTitle.pickedFile != null) {
      metaTitle = _pickMetaTitle.pickedFile;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      bool check = _checkIfLocationIsChosen();
      if (check == false) {
        Future.delayed(Duration.zero, () {
          UiUtils.showBlurredDialoge(
            context,
            sigmaX: 5,
            sigmaY: 5,
            dialoge: BlurredDialogBox(
              svgImagePath: AppIcons.warning,
              title: UiUtils.translate(context, "incomplete"),
              showCancleButton: false,
              onAccept: () async {},
              acceptTextColor: context.color.buttonColor,
              content: Text(
                UiUtils.translate(context, "addressError"),
              ),
            ),
          );
        });

        return;
      } else if (titleImage == null && titleImageURL == "") {
        Future.delayed(Duration.zero, () {
          UiUtils.showBlurredDialoge(context,
              sigmaX: 5,
              sigmaY: 5,
              dialoge: BlurredDialogBox(
                  svgImagePath: AppIcons.warning,
                  title: UiUtils.translate(context, "incomplete"),
                  showCancleButton: false,
                  acceptTextColor: context.color.buttonColor,
                  content: Text(
                    UiUtils.translate(context, "uploadImgMsgLbl"),
                  )));
        });
        return;
      }

      var list = mixedPropertyImageList.map((e) {
        if (e is File) {
          return e;
        }
      }).toList()
        ..removeWhere((element) => element == null);
      _clientAddressController.clear();
      _clientAddressController.text = HiveUtils.getUserDetails().address ?? "";
      // return;

      propertyData.addAll({
        "title": _propertyNameController.text,
        "description": _descriptionController.text,
        "city": _cityNameController.text,
        "state": _stateNameController.text,
        "country": _countryNameController.text,
        "latitude": _latitudeController.text,
        "longitude": _longitudeController.text,
        "address": _addressController.text,
        "client_address": _clientAddressController.text,
        "price": _priceController.text,
        "title_image": titleImage,
        "gallery_images": list,
        "remove_gallery_images": removedImageId,
        // "category_id": 1,
        "category_id": widget.propertyDetails == null
            ? (Constant.addProperty['category'] as Category).id
            : widget.propertyDetails?['catId'],
        // "property_type": 1,
        "property_type": propertyType,
        "threeD_image": v360Image,
        "video_link": _videoLinkController.text,

        "meta_title": metaTitleController.text,
        "meta_description": metaDescriptionController.text,
        "meta_keywords": metaKeywordController.text,
        "meta_image": metaTitle,

        if ((widget.propertyDetails == null
                ? propertyType
                : widget.propertyDetails?['propType']) ==
            1)
          "rentduration": selectedRentType,

        "is_premium": isPrivateProperty
      });

      if (widget.propertyDetails?.containsKey("assign_facilities") ?? false) {
        propertyData["assign_facilities"] =
            widget.propertyDetails!['assign_facilities'];
      }
      if (widget.propertyDetails != null) {
        propertyData['id'] = widget.propertyDetails?['id'];
        propertyData['action_type'] = "0";
      }

      log("#### ${propertyData}");

      Future.delayed(
        Duration.zero,
        () {
          _pickTitleImage.pauseSubscription();
          _pickMetaTitle.pauseSubscription();
          Navigator.pushNamed(
            context,
            Routes.setPropertyParametersScreen,
            arguments: {
              "details": propertyData,
              "isUpdate": (widget.propertyDetails != null)
            },
          ).then((value) {
            _pickMetaTitle.resumeSubscription();
            _pickTitleImage.resumeSubscription();
          });
        },
      );
    }
  }

  bool _checkIfLocationIsChosen() {
    if (_cityNameController.text == "" ||
        _stateNameController.text == "" ||
        _countryNameController.text == "" ||
        _latitudeController.text == "" ||
        _longitudeController.text == "") {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _pickMetaTitle.dispose();
    _propertyNameController.dispose();
    _descriptionController.dispose();
    _cityNameController.dispose();
    _stateNameController.dispose();
    _countryNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _clientAddressController.dispose();
    _videoLinkController.dispose();
    _pick360deg.dispose();
    _pickTitleImage.dispose();
    _propertiesImagePicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("okay ${propertyType}");
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: UiUtils.buildButton(context,
              onPressed: _onTapContinue,
              height: 48.rh(context),
              fontSize: context.font.large,
              buttonTitle: UiUtils.translate(context, "next")),
        ),
      ),
      appBar: UiUtils.buildAppBar(
        context,
        title: widget.propertyDetails == null
            ? UiUtils.translate(context, "ddPropertyLbl")
            : UiUtils.translate(context, "updateProperty"),
        actions: const [
          Text("2/4"),
          SizedBox(
            width: 14,
          ),
        ],
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("propertyType".translate(context)),
                SizedBox(
                  height: 15.rh(context),
                ),
                buildPropertyTypeSelector(context),
                SizedBox(
                  height: 15.rh(context),
                ),
                Text(UiUtils.translate(context, "propertyNameLbl")),
                SizedBox(
                  height: 15.rh(context),
                ),
                CustomTextFormField(
                  controller: _propertyNameController,
                  validator: CustomTextFieldValidator.nullCheck,
                  action: TextInputAction.next,
                  hintText: UiUtils.translate(context, "propertyNameLbl"),
                ),
                SizedBox(
                  height: 15.rh(context),
                ),
                Text(UiUtils.translate(context, "descriptionLbl")),
                SizedBox(
                  height: 15.rh(context),
                ),
                CustomTextFormField(
                  action: TextInputAction.next,
                  controller: _descriptionController,
                  validator: CustomTextFieldValidator.nullCheck,
                  hintText: UiUtils.translate(context, "writeSomething"),
                  maxLine: 100,
                  minLine: 6,
                ),
                SizedBox(
                  height: 15.rh(context),
                ),
                Row(
                  children: [
                    const Text("Is Private Property?"),
                    const Spacer(),
                    CupertinoSwitch(
                      value: isPrivateProperty,
                      activeColor: context.color.tertiaryColor,
                      onChanged: (bool value) {
                        isPrivateProperty = value;
                        setState(() {});
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.rh(context),
                ),
                SizedBox(
                  height: 35.rh(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 3,
                          child:
                              Text(UiUtils.translate(context, "addressLbl"))),
                      // const Spacer(),
                      Expanded(
                        flex: 3,
                        child: ChooseLocationFormField(
                          initialValue: false,
                          validator: (bool? value) {
                            //Check if it has already data so we will not validate it.
                            if ((widget.propertyDetails != null)) {
                              return null;
                            }

                            if (value == true) {
                              return null;
                            } else {
                              return "Select location";
                            }
                          },
                          build: (state) {
                            return Container(
                              decoration: BoxDecoration(
                                  // color: context.color.teritoryColor,
                                  border: Border.all(
                                      width: 1.5,
                                      color: state.hasError
                                          ? Colors.red
                                          : Colors.transparent),
                                  borderRadius: BorderRadius.circular(9)),
                              child: MaterialButton(
                                  height: 30,
                                  onPressed: () {
                                    _onTapChooseLocation.call(state);
                                  },
                                  child: FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        UiUtils.getSvg(AppIcons.location,
                                            color:
                                                context.color.textLightColor),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          UiUtils.translate(
                                              context, "chooseLocation"),
                                        )
                                            .size(context.font.normal)
                                            .color(context.color.tertiaryColor)
                                            .underline(),
                                      ],
                                    ),
                                  )),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.rh(context),
                ),
                CustomTextFormField(
                  action: TextInputAction.next,
                  controller: _cityNameController,
                  isReadOnly: false,
                  validator: CustomTextFieldValidator.nullCheck,
                  hintText: UiUtils.translate(context, "city"),
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  action: TextInputAction.next,
                  controller: _stateNameController,
                  isReadOnly: false,
                  validator: CustomTextFieldValidator.nullCheck,
                  hintText: UiUtils.translate(context, "state"),
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  action: TextInputAction.next,
                  controller: _countryNameController,
                  isReadOnly: false,
                  validator: CustomTextFieldValidator.nullCheck,
                  hintText: UiUtils.translate(context, "country"),
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  action: TextInputAction.next,
                  controller: _addressController,
                  hintText: UiUtils.translate(context, "addressLbl"),
                  maxLine: 100,
                  validator: CustomTextFieldValidator.nullCheck,
                  minLine: 4,
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  action: TextInputAction.next,
                  controller: _clientAddressController,
                  validator: CustomTextFieldValidator.nullCheck,
                  hintText: UiUtils.translate(context, "clientaddressLbl"),
                  maxLine: 100,
                  minLine: 4,
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                if ((widget.propertyDetails == null
                        ? propertyType
                        : widget.propertyDetails?['propType']) ==
                    1) ...[
                  Text(UiUtils.translate(context, "rentPrice")),
                ] else ...[
                  Text(UiUtils.translate(context, "price")),
                ],
                SizedBox(
                  height: 10.rh(context),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        action: TextInputAction.next,
                        prefix: Text("${Constant.currencySymbol} "),
                        controller: _priceController,
                        formaters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d*')),
                        ],
                        isReadOnly: false,
                        keyboard: TextInputType.number,
                        validator: CustomTextFieldValidator.nullCheck,
                        hintText: "00",
                      ),
                    ),
                    if ((widget.propertyDetails == null
                            ? propertyType
                            : widget.propertyDetails?['propType']) ==
                        1) ...[
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: context.color.secondaryColor,
                            border: Border.all(
                                color: context.color.borderColor, width: 1.5),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: DropdownButton<String>(
                            value: selectedRentType,
                            dropdownColor: context.color.primaryColor,
                            underline: const SizedBox.shrink(),
                            items: [
                              DropdownMenuItem(
                                value: "Daily",
                                child: Text(
                                  "Daily".translate(context),
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Monthly",
                                child: Text("Monthly".translate(context)),
                              ),
                              DropdownMenuItem(
                                value: "Quarterly",
                                child: Text("Quarterly".translate(context)),
                              ),
                              DropdownMenuItem(
                                value: "Yearly",
                                child: Text("Yearly".translate(context)),
                              ),
                            ],
                            onChanged: (value) {
                              selectedRentType = value ?? "";
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                Row(
                  children: [
                    Text(UiUtils.translate(context, "uploadPictures")),
                    const SizedBox(
                      width: 3,
                    ),
                    Text("maxSize".translate(context))
                        .italic()
                        .size(context.font.small),
                  ],
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                Wrap(
                  children: [
                    if (_pickTitleImage.pickedFile != null) ...[] else ...[],
                    titleImageListener(),
                  ],
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                Text(UiUtils.translate(context, "otherPictures")),
                SizedBox(
                  height: 10.rh(context),
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                propertyImagesListener(),
                SizedBox(
                  height: 10.rh(context),
                ),
                Text(UiUtils.translate(context, "additionals")),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  // prefix: Text("${Constant.currencySymbol} "),
                  controller: _videoLinkController,
                  // isReadOnly: widget.properyDetails != null,
                  hintText: "http://example.com/video.mp4",
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                DottedBorder(
                  color: context.color.textLightColor,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  child: GestureDetector(
                    onTap: () {
                      _pick360deg.pick(pickMultiple: false);
                    },
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      height: 48.rh(context),
                      child:
                          Text(UiUtils.translate(context, "add360degPicture")),
                    ),
                  ),
                ),
                _pick360deg.listenChangesInUI((context, image) {
                  if (image != null) {
                    return Stack(
                      children: [
                        Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.all(5),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: Image.file(
                              image,
                              fit: BoxFit.cover,
                            )),
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, BlurredRouter(
                                builder: (context) {
                                  return PanaromaImageScreen(
                                    imageUrl: image.path,
                                    isFileImage: true,
                                  );
                                },
                              ));
                            },
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.all(5),
                              height: 100,
                              decoration: BoxDecoration(
                                  color:
                                      context.color.tertiaryColor.withOpacity(
                                    0.68,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              child: FittedBox(
                                fit: BoxFit.none,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.color.secondaryColor,
                                  ),
                                  width: 60.rw(context),
                                  height: 60.rh(context),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                            height: 30.rh(context),
                                            width: 40.rw(context),
                                            child: UiUtils.getSvg(
                                                AppIcons.v360Degree,
                                                color: context
                                                    .color.textColorDark)),
                                        Text(UiUtils.translate(context, "view"))
                                            .color(context.color.textColorDark)
                                            .size(context.font.small)
                                            .bold()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Container();
                }),
                SizedBox(
                  height: 15.rh(context),
                ),
                Text("Meta Details".translate(context)),
                SizedBox(
                  height: 15.rh(context),
                ),
                CustomTextFormField(
                  controller: metaTitleController,
                  hintText: "Title".translate(context),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text("metaTitleLength".translate(context))
                      .size(context.font.small - 1.5)
                      .color(context.color.textLightColor),
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  controller: metaDescriptionController,
                  hintText: "Description".translate(context),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text("metaDescriptionLength".translate(context))
                      .size(context.font.small - 1.5)
                      .color(context.color.textLightColor),
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  controller: metaKeywordController,
                  hintText: "Keywords".translate(context),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text("metaKeywordsLength".translate(context))
                      .size(context.font.small - 1.5)
                      .color(context.color.textLightColor),
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                DottedBorder(
                  color: context.color.textLightColor,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  child: GestureDetector(
                    onTap: () {
                      _pickMetaTitle.pick(pickMultiple: false);
                    },
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      height: 48.rh(context),
                      child: Text("Meta Image".translate(context)),
                    ),
                  ),
                ),
                Builder(builder: (context) {
                  Widget currentWidget = Container();
                  if (metaImageUrl != "") {
                    currentWidget = GestureDetector(
                      onTap: () {
                        UiUtils.showFullScreenImage(context,
                            provider: NetworkImage(metaImageUrl));
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.all(5),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: Image.network(
                          metaImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                  if (_pickMetaTitle.pickedFile != null) {
                    currentWidget = Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.all(5),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: Image.file(
                          _pickMetaTitle.pickedFile!,
                          fit: BoxFit.cover,
                        ));
                  }

                  return currentWidget;
                }),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecorator buildPropertyTypeSelector(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
          hintStyle: TextStyle(
              color: context.color.textColorDark.withOpacity(0.7),
              fontSize: context.font.large),
          filled: true,
          fillColor: context.color.secondaryColor,
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.tertiaryColor),
              borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.borderColor),
              borderRadius: BorderRadius.circular(10)),
          border: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.borderColor),
              borderRadius: BorderRadius.circular(10))),
      child: DropdownButton<int>(
        value: propertyType,
        isExpanded: true,
        isDense: true,
        borderRadius: BorderRadius.zero,
        padding: EdgeInsets.zero,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(
            value: 0,
            child: Text("Sell"),
          ),
          DropdownMenuItem(
            value: 1,
            child: Text("Rent"),
          )
        ],
        onTap: () {},
        onChanged: (int? value) {
          propertyType = value!;
          setState(() {});
        },
      ),
    );
  }

  Widget propertyImagesListener() {
    return _propertiesImagePicker.listenChangesInUI((context, file) {
      Widget current = Container();

      current = Wrap(
          children: mixedPropertyImageList
              .map((image) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HelperUtils.unfocus();
                        if (image is String) {
                          UiUtils.showFullScreenImage(context,
                              provider: NetworkImage(image));
                        } else {
                          UiUtils.showFullScreenImage(context,
                              provider: FileImage(image));
                        }
                      },
                      child: Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.all(5),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ImageAdapter(
                            image: image,
                          )),
                    ),

                    // Positioned(
                    //   right: 5,
                    //   top: 5,
                    //   child: Container(
                    //       width: 100,
                    //       height: 100,
                    //       margin: const EdgeInsets.all(5),
                    //       clipBehavior: Clip.antiAlias,
                    //       decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(10)),
                    //       child: Icon(Icons.close)),
                    // ),
                    closeButton(context, () {
                      mixedPropertyImageList.remove(image);

                      if (image is String) {
                        List<Gallery> properyDetail =
                            widget.propertyDetails?['gallary_with_id']
                                as List<Gallery>;
                        var id = properyDetail
                            .where((element) => element.imageUrl == image)
                            .first
                            .id;

                        removedImageId.add(id);
                      }
                      setState(() {});
                    }),

                    // child: GestureDetector(
                    //   onTap: () {
                    //     mixedPropertyImageList.remove(image);
                    //     // removedImageId.add();
                    //
                    //     setState(() {});
                    //   },
                    //   child: Icon(
                    //     Icons.close,
                    //     color: context.color.secondaryColor,
                    //   ),
                    // ),
                    // )
                  ],
                );
              })
              .toList()
              .cast<Widget>());

      // if (propertyImageList.isEmpty && editPropertyImageList.isNotEmpty) {
      //   current = Wrap(
      //       children: editPropertyImageList
      //           .map((image) {
      //             log(image.runtimeType.toString());
      //             return Stack(
      //               children: [
      //                 GestureDetector(
      //                   onTap: () {
      //                     HelperUtils.unfocus();
      //                     UiUtils.showFullScreenImage(context,
      //                         provider: FileImage(image));
      //                   },
      //                   child: Container(
      //                       width: 100,
      //                       height: 100,
      //                       margin: const EHEHEHEHEdgeInsets.all(5),
      //                       clipBehavior: Clip.antiAlias,
      //                       decoration: BoxDecoration(
      //                           borderRadius: BorderRadius.circular(10)),
      //                       child: Image.network(
      //                         image,
      //                         fit: BoxFit.cover,
      //                       )),
      //                 ),
      //                 Positioned(
      //                   right: 5,
      //                   top: 5,
      //                   child: GestureDetector(
      //                     onTap: () {
      //                       editPropertyImageList.remove(image);
      //                       // removedImageId.add();
      //
      //                       setState(() {});
      //                     },
      //                     child: Icon(
      //                       Icons.close,
      //                       color: context.color.secondaryColor,
      //                     ),
      //                   ),
      //                 )
      //               ],
      //             );
      //           })
      //           .toList()
      //           .cast<Widget>());
      // }
      //
      // if (file is List<File>) {
      //   current = Wrap(
      //       children: propertyImageList
      //           .map((image) {
      //             return Stack(
      //               children: [
      //                 GestureDetector(
      //                   onTap: () {
      //                     HelperUtils.unfocus();
      //                     UiUtils.showFullScreenImage(context,
      //                         provider: FileImage(image));
      //                   },
      //                   child: Container(
      //                       width: 100,
      //                       height: 100,
      //                       margin: const EdgeInsets.all(5),
      //                       clipBehavior: Clip.antiAlias,
      //                       decoration: BoxDecoration(
      //                           borderRadius: BorderRadius.circular(10)),
      //                       child: Image.file(
      //                         image,
      //                         fit: BoxFit.cover,
      //                       )),
      //                 ),
      //                 closeButton(context, () {
      //                   propertyImageList.remove(image);
      //                   setState(() {});
      //                 })
      //               ],
      //             );
      //           })
      //           .toList()
      //           .cast<Widget>());
      // }

      return Wrap(
        runAlignment: WrapAlignment.start,
        children: [
          if (file == null && mixedPropertyImageList.isEmpty)
            DottedBorder(
              color: context.color.textLightColor,
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: GestureDetector(
                onTap: () {
                  _propertiesImagePicker.pick(pickMultiple: true);
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  height: 48.rh(context),
                  child: Text(UiUtils.translate(context, "addOtherPicture")),
                ),
              ),
            ),
          current,
          if (file != null || titleImageURL != "")
            uploadPhotoCard(context, onTap: () {
              _propertiesImagePicker.pick(pickMultiple: true);
            })
        ],
      );
    });
  }

  Widget titleImageListener() {
    return Builder(builder: (context) {
      Widget currentWidget = Container();
      if (titleImageURL != "") {
        currentWidget = GestureDetector(
          onTap: () {
            UiUtils.showFullScreenImage(context,
                provider: NetworkImage(titleImageURL));
          },
          child: Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.all(5),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Image.network(
              titleImageURL,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
      if (_pickTitleImage.pickedFile is File) {
        currentWidget = GestureDetector(
          onTap: () {
            UiUtils.showFullScreenImage(context,
                provider: FileImage(_pickTitleImage.pickedFile!));
          },
          child: Column(
            children: [
              Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.all(5),
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Image.file(
                    _pickTitleImage.pickedFile!,
                    fit: BoxFit.cover,
                  )),
            ],
          ),
        );
      }

      return Wrap(
        children: [
          if (_pickTitleImage.pickedFile == null && titleImageURL == "")
            DottedBorder(
              color: context.color.textLightColor,
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: GestureDetector(
                onTap: () {
                  _pickTitleImage.pick(pickMultiple: false);
                  titleImageURL = "";
                  setState(() {});
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  height: 48.rh(context),
                  child: Text(UiUtils.translate(context, "addMainPicture")),
                ),
              ),
            ),
          Stack(
            children: [
              currentWidget,
              closeButton(context, () {
                _pickTitleImage.clearImage();
                titleImageURL = "";
                setState(() {});
              })
            ],
          ),
          if (_pickTitleImage.pickedFile != null || titleImageURL != "")
            uploadPhotoCard(context, onTap: () {
              _pickTitleImage.resumeSubscription();
              _pickTitleImage.pick(pickMultiple: false);
              _pickTitleImage.pauseSubscription();
              titleImageURL = "";
              setState(() {});
            })
          // GestureDetector(
          //   onTap: () {
          //     _pickTitleImage.resumeSubscription();
          //     _pickTitleImage.pick(pickMultiple: false);
          //     _pickTitleImage.pauseSubscription();
          //     titleImageURL = "";
          //     setState(() {});
          //   },
          //   child: Container(
          //     width: 100,
          //     height: 100,
          //     margin: const EdgeInsets.all(5),
          //     clipBehavior: Clip.antiAlias,
          //     decoration:
          //         BoxDecoration(borderRadius: BorderRadius.circular(10)),
          //     child: DottedBorder(
          //         borderType: BorderType.RRect,
          //         radius: Radius.circular(10),
          //         child: Container(
          //           alignment: Alignment.center,
          //           child: Text("Upload \n Photo"),
          //         )),
          //   ),
          // ),
        ],
      );
    });
  }
}

Widget uploadPhotoCard(BuildContext context, {required Function onTap}) {
  return GestureDetector(
    onTap: () {
      onTap.call();
    },
    child: Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.all(5),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: DottedBorder(
          color: context.color.textColorDark.withOpacity(0.5),
          borderType: BorderType.RRect,
          radius: const Radius.circular(10),
          child: Container(
            alignment: Alignment.center,
            child: Text("uploadPhoto".translate(context)),
          )),
    ),
  );
}

PositionedDirectional closeButton(BuildContext context, Function onTap) {
  return PositionedDirectional(
    top: 6,
    end: 6,
    child: GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Container(
        decoration: BoxDecoration(
            color: context.color.primaryColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10)),
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(
            Icons.close,
            size: 24,
            color: Colors.black,
          ),
        ),
      ),
    ),
  );
}

class ChooseLocationFormField extends FormField<bool> {
  ChooseLocationFormField(
      {super.key,
      FormFieldSetter<bool>? onSaved,
      FormFieldValidator<bool>? validator,
      bool? initialValue,
      required Widget Function(FormFieldState<bool> state) build,
      bool autovalidateMode = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return build(state);
            });
}

class ImageAdapter extends StatelessWidget {
  final dynamic image;
  ImageAdapter({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    if (image is String) {
      return Image.network(
        image,
        fit: BoxFit.cover,
      );
    } else if (image is File) {
      return Image.file(
        image,
        fit: BoxFit.cover,
      );
    }
    return Container();
  }
}
