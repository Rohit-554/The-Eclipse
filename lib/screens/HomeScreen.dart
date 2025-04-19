import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:the_eclipse/screens/ChatSectionUI.dart';
import 'package:the_eclipse/screens/SettingsScreen.dart';
import 'package:the_eclipse/utils/colors.dart';
import 'package:particles_flutter/particles_engine.dart';

import '../connection/SSH.dart';
import '../kml/BaloonLoader.dart';
import '../providers/connection_providers.dart';
import '../widget/widgets.dart';

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const apikey = '';//TODO:Put your own Gemini Api Key

  @override
  void initState() {
    super.initState();
    SSH(ref: ref).cleanSlaves(context);

  }

  /*Future<void> cleanLG() async {
    setState(() async {
      await SSH(ref: ref).cleanSlaves(context);
      await SSH(ref: ref).cleanKML(context);
      await SSH(ref: ref).cleanBalloon(context);
    });

  }*/


  Future<void> _relaunchLG() async {
    await SSH(ref: ref).relunchLG();
  }

  Future<void> _shutdownLg() async{
    await SSH(ref: ref).shutdownLG(context);
  }

  Future<void> _cleanKml() async {
    await SSH(ref: ref).cleanKML(context);
    await SSH(ref: ref).cleanBalloon(context);
    await SSH(ref: ref).cleanSlaves(context);
    await SSH(ref:ref).setRefresh(context);
  }
  Future<void> _stopOrbit() async{
    await SSH(ref: ref).stopOrbit(context);
  }


  Future<void> showPlace() async {
    await SSH(ref: ref).execute();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: home_background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 20,top: 40),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.rocket),
                            color: ref.watch(connectedProvider)?Colors.greenAccent:Colors.redAccent,
                            onPressed: () {
                              print("this is working");
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ConnectionScreen()),
                              );
                            },
                          ),
                          Text(
                            ref.watch(connectedProvider)?'Connected':'Disconnected',
                            style: GoogleFonts.spaceGrotesk(
                              textStyle: TextStyle(
                                color: ref.watch(connectedProvider)?Colors.white:Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                      Padding(
                        padding: const EdgeInsets.only(right: 20,top: 20),
                        child: IconButton(
                          icon: const Icon(Icons.settings),
                          color: Colors.white,
                          onPressed: () {
                            print("this is working");
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ConnectionScreen()),
                            );
                          },
                        ),
                      ),
                    ]
                  ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'The Eclipse',
                  style: GoogleFonts.spaceGrotesk(
                    textStyle: TextStyle(
                      color: Colors.white, // Single color
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2, // Added for better readability
                    ),
                  ),
                ),
              ),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(isNewChat.notifier).state = true;
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '+ New Chat',
                    style: GoogleFonts.spaceGrotesk(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // Left side with circular buttons
                    Container(
                      width: 80, // Adjust width as needed
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // Change mainAxisAlignment
                        children: [
                          CircularButton(
                            iconData: Icons.refresh_sharp,
                            onPressed: () {
                              showAlertDialog(context,1);
                            },
                          ),
                          CircularButton(
                              iconData: Icons.power_settings_new_sharp,
                              onPressed: () {
                                showAlertDialog(context,2);
                              }),
                          CircularButton(
                            iconData: Icons.cleaning_services_outlined,
                            onPressed: () {
                              showAlertDialog(context,3);
                            },
                          ),
                          /*CircularButton(
                            iconData: Icons.stop,
                            onPressed: () {
                              showAlertDialog(context,4);
                            },
                          ),*/
                          CircularButton(
                            iconData: ref.watch(isSpeaking)
                                ? Icons.volume_up
                                : Icons.volume_off,
                            color: ref.watch(isSpeaking)
                                ? Colors.green
                                : Colors
                                    .white, // Change color based on isSpeaking
                            onPressed: () {
                              if (!ref.watch(isSpeaking) &&
                                  ref.watch(isVoiceStopped)) {
                                CustomWidgets().showSnackBar(context: context, message: "Nothing is playing...", );
                              } else {
                                if (ref.read(isSpeaking)) {
                                  ref.read(isVoiceStopped.notifier).state =
                                      true;
                                  ref.read(isSpeaking.notifier).state = false;
                                } else {
                                  ref.read(isVoiceStopped.notifier).state =
                                      false;
                                  ref.read(isSpeaking.notifier).state = true;
                                }
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    // Right side with chat section
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 32, left: 0, right: 0),
                          child: ChatScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  showAlertDialog(
      BuildContext context,
      int ind,
      ) {
    String message;
    if (ind == 1) {
      message = "Are you sure you want to relaunch Lg?";
    } else if (ind == 2) {
      message = "Are you sure you want to shutdown Lg?";
    } else if (ind == 3) {
      message = "Clean Kml ?";
    } else if (ind == 4) {
      message = "Locate lleida?";
    } else {
      message = "Default message for other indices";
    }

    Widget cancelButton = TextButton(
      child: Text("Cancel",
          style: GoogleFonts.spaceGrotesk(
            textStyle: const TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          )),
      onPressed: () {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pop();
        });
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue",
          style: GoogleFonts.spaceGrotesk(
            textStyle: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          )),
      onPressed: () {
        Navigator.of(context).pop();
        if (ind == 1) {
          _relaunchLG();
        } else if (ind == 2) {
          _shutdownLg();
        } else if (ind == 3){
          _cleanKml();
        } else if (ind == 4){
          _stopOrbit();
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text("Confirmation",
          style: GoogleFonts.spaceGrotesk(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )),
      content: Text(
        message,
        style: GoogleFonts.spaceGrotesk(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class CircularButton extends StatelessWidget {
  final IconData? iconData;
  final VoidCallback? onPressed;
  final Color? color;

  const CircularButton(
      {Key? key, this.iconData, this.onPressed, this.color = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white),
          ),
          child: Icon(
            iconData,
            color: color,
          ),
        ),
      ),
    );
  }


}
