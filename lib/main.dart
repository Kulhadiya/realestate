import 'package:ebroker/app/register_cubits.dart';
import 'package:flutter/material.dart';

import 'Ui/screens/ChatNew/MessageTypes/registerar.dart';
import 'exports/main_export.dart';

/////////////////
////V-1.1.3/////
///////////////

///

void main() async {
  await getAppSettings();
  initApp();
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({
    Key? key,
  }) : super(key: key);
  @override
  EntryPointState createState() => EntryPointState();
}

class EntryPointState extends State<EntryPoint> {
  @override
  void initState() {
    super.initState();
    ChatMessageHandler.handle();
    ChatGlobals.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          ...RegisterCubits().register(),
        ],
        child: Builder(builder: (BuildContext context) {
          return const App();
        }));
  }
}
