import 'package:ebroker/Ui/screens/widgets/Erros/something_went_wrong.dart';
import 'package:ebroker/data/cubits/project/fetch_projects.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../Ui/screens/splash_screen.dart';
import '../data/Repositories/personalized_feed_repository.dart';
import '../data/cubits/Personalized/fetch_personalized_properties.dart';
import '../data/model/Personalized/personalized_settings.dart';
import '../data/model/app_settings_datamodel.dart';
//import '../firebase_options.dart';
import '../main.dart';
import '../utils/Network/apiCallTrigger.dart';
import '../utils/api.dart';
import '../utils/guestChecker.dart';
import '../utils/ui_utils.dart';
import 'default_app_setting.dart';

PersonalizedInterestSettings personalizedInterestSettings =
    PersonalizedInterestSettings.empty();
AppSettingsDataModel appSettings = fallbackSettingAppSettings;

///

getAppSettings() async {
  await LoadAppSettings().load();
}

Future getLanguage() async {
  await getDefaultLanguage(
    () {},
  );
}

void initApp() async {
  ///Note: this file's code is very necessary and sensitive if you change it, this might affect whole app , So change it carefully.
  ///This must be used do not remove this line
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await HiveUtils.initBoxes();
  // await Isolate.spawn(getLanguage, languageSettingReceivePort.sendPort);

  Api.initInterceptors();

  ///This is the widget to show uncaught runtime error in this custom widget so that user can know in that screen something is wrong instead of grey screen
  SomethingWentWrong.asGlobalErrorBuilder();

  // if (Firebase.apps.isNotEmpty) {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // } else {
  //   await Firebase.initializeApp();
  // }
  //
  // FirebaseMessaging.onBackgroundMessage(
  //     NotificationService.onBackgroundMessageHandler);
  // HydratedBloc.storage = await HydratedStorage.build(
  //   storageDirectory: await getApplicationDocumentsDirectory(),
  // );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    runApp(const EntryPoint());
  });
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    ///Here Fetching property report reasons
    context.read<FetchPropertyReportReasonsListCubit>().fetch();
    context.read<LanguageCubit>().loadCurrentLanguage();
    AppTheme currentTheme = HiveUtils.getCurrentTheme();

    ///Initialized notification services
    LocalAwsomeNotification().init(context);
    ///////////////////////////////////////
    NotificationService.init(context);

    /// Initialized dynamic links for share properties feature
    context.read<AppThemeCubit>().changeTheme(currentTheme);

    APICallTrigger.onTrigger(
      () {
        //THIS WILL be CALLED WHEN USER WILL LOGIN FROM ANONYMOUS USER.
        context.read<LikedPropertiesCubit>().emptyCubit();
        context.read<GetApiKeysCubit>().fetch();

        loadInitialData(context, loadWithoutDelay: true);
      },
    );

    UiUtils.setContext(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Continuously watching theme change
    AppTheme currentTheme = context.watch<AppThemeCubit>().state.appTheme;
    return BlocListener<GetApiKeysCubit, GetApiKeysState>(
      listener: (context, state) {
        context.read<GetApiKeysCubit>().setAPIKeys();
      },
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, languageState) {
          return MaterialApp(
            initialRoute: Routes
                .splash, // App will start from here splash screen is first screen,
            navigatorKey: Constant
                .navigatorKey, //This navigator key is used for Navigate users through notification
            title: Constant.appName,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: Routes.onGenerateRouted,
            theme: appThemeData[currentTheme],
            builder: (context, child) {
              TextDirection direction;
              //here we are languages direction locally
              if (languageState is LanguageLoader) {
                if (Constant.totalRtlLanguages
                    .contains((languageState).languageCode)) {
                  direction = TextDirection.rtl;
                } else {
                  direction = TextDirection.ltr;
                }
              } else {
                direction = TextDirection.ltr;
              }
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                  // textScaleFactor:
                  //     1.0, //set text scale factor to 1 so that this will not resize app's text while user change their system settings text scale
                ),
                child: Directionality(
                  textDirection:
                      direction, //This will convert app direction according to language
                  child: child!,
                ),
              );
            },
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: loadLocalLanguageIfFail(languageState),
          );
        },
      ),
    );
  }

  dynamic loadLocalLanguageIfFail(LanguageState state) {
    if ((state is LanguageLoader)) {
      return Locale(state.languageCode);
    } else if (state is LanguageLoadFail) {
      return const Locale("en");
    }
  }
}

void loadInitialData(BuildContext context,
    {bool? loadWithoutDelay, bool? forceRefresh}) {
  context.read<FetchProjectsCubit>().fetchProjects();
  context.read<SliderCubit>().fetchSlider(context,
      loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context.read<FetchCategoryCubit>().fetchCategories(
      loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context
      .read<FetchMostViewedPropertiesCubit>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context
      .read<FetchPromotedPropertiesCubit>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);

  context
      .read<FetchMostLikedPropertiesCubit>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context
      .read<FetchNearbyPropertiesCubit>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context.read<FetchCityCategoryCubit>().fetchCityCategory(
      loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context
      .read<FetchRecentPropertiesCubit>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context
      .read<FetchPersonalizedPropertyList>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context.read<GetChatListCubit>().setContext(context);
  context.read<GetChatListCubit>().fetch();

  // if (widget.from != "login") {
  PersonalizedFeedRepository().getUserPersonalizedSettings().then((value) {
    personalizedInterestSettings = value;
  });
  GuestChecker.listen().addListener(() {
    if (GuestChecker.value == false) {
      PersonalizedFeedRepository().getUserPersonalizedSettings().then((value) {
        personalizedInterestSettings = value;
      });
    }
  });

//    // }
}
