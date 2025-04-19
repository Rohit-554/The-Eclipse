import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_eclipse/utils/string_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../connection/SSH.dart';
import '../providers/ApiKeyService.dart';
import '../providers/connection_providers.dart';
import '../utils/theme.dart';
import '../widget/show_connection.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {


  TextEditingController ipController = TextEditingController(text: '');
  TextEditingController usernameController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');
  TextEditingController portController = TextEditingController(text: '');
  TextEditingController rigsController = TextEditingController(text: '');
  TextEditingController apiKeyController = TextEditingController(text: '');


  late SSH ssh;
  initTextControllers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ipController.text = ref.read(ipProvider);
    usernameController.text = ref.read(usernameProvider);
    passwordController.text = ref.read(passwordProvider);
    portController.text = ref.read(portProvider).toString();
    rigsController.text = ref.read(rigsProvider).toString();
    apiKeyController.text = ref.read(apiKeyProvider).toString();
   /* var userName = prefs.getString('usr_name');
    if(userName!.isNotEmpty){
      usrNameController.text = userName;
    }else{
      usrNameController.text = ref.read(userNameProvider);
    }*/
  }
  /*void _doSomething() async {
    Timer(Duration(seconds: 3), () {
      _btnController.success();
    });
  }*/

  Future<void> _loadApiKey() async {
    final savedApiKey = await ApiKeyService.loadApiKey();
    if (savedApiKey.isNotEmpty) {
      ref.read(apiKeyProvider.notifier).state = savedApiKey;
      apiKeyController.text = savedApiKey;
    } else {
      // Use the default value from provider if nothing is saved
      apiKeyController.text = ref.read(apiKeyProvider);
    }
  }


  updateProviders() async{
    ref.read(ipProvider.notifier).state = ipController.text;
    ref.read(usernameProvider.notifier).state = usernameController.text;
    ref.read(passwordProvider.notifier).state = passwordController.text;
    ref.read(portProvider.notifier).state = int.parse(portController.text);
    ref.read(rigsProvider.notifier).state = int.parse(rigsController.text);
    ref.read(apiKeyProvider.notifier).state = apiKeyController.text;
    await ApiKeyService.saveApiKey(apiKeyController.text);
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG(context);
    ref.read(connectedProvider.notifier).state = result!;
    if(ref.read(connectedProvider)){
      ssh.execute();
    }
  }

  /* Future<void> _execute() async {
    SSHSession? session = await ssh.execute();
    if (session != null) {
      print(session.stdout);
    }
  }*/

  @override
  void initState() {
    super.initState();
    initTextControllers();
    _loadApiKey();
    ssh = SSH(ref: ref);
  }

  /*void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('usr_name', usernameController.text);
  }*/

  @override
  Widget build(BuildContext context) {
    bool isConnectedToLg = ref.watch(connectedProvider);
    final theme = ThemesDark();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.tabBarColor,
          elevation: 0,
          title: Text(
            StringConstants.Settings,
            style: GoogleFonts.spaceGrotesk(
              color: theme.oppositeColor,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.pop(context),
            color: theme.oppositeColor,
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.tabBarColor,
                  theme.tabBarColor.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: theme.normalColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.normalColor,
                theme.normalColor.withOpacity(0.95),
                theme.normalColor.withOpacity(0.9),
              ],
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Connection Status Card
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isConnectedToLg
                          ? [
                        Colors.teal.shade800.withOpacity(0.8),
                        Colors.teal.shade900,
                      ]
                          : [
                        Colors.red.shade800.withOpacity(0.7),
                        Colors.red.shade900,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ShowConnection(status: isConnectedToLg),
                  ),
                ),

                // Input Fields
                _buildInputCard(
                  children: [
                    _customInput(ipController, "IP Address", Icons.network_check),
                    _customInput(usernameController, "Username", Icons.person),
                    _customInput(passwordController, "Password", Icons.lock),
                    _customInput(portController, "Port", Icons.settings_ethernet),
                    _customInput(rigsController, "Rigs", Icons.hardware),
                    _customInput(apiKeyController, "Gemini API Key", Icons.api),
                  ],
                ),

                // Connect Button
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade700,
                        Colors.blue.shade900,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade900.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async{
                      await updateProviders();
                      if (!isConnectedToLg) _connectToLG();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        isConnectedToLg ? 'Reconnect to LG' : 'Connect to LG',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ThemesDark().normalColor.withOpacity(0.7),
        border: Border.all(
          color: Colors.grey.shade800.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _customInput(TextEditingController controller, String labelText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        style: GoogleFonts.spaceGrotesk(
          color: ThemesDark().oppositeColor,
          fontSize: 16,
        ),
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.spaceGrotesk(
            color: ThemesDark().oppositeColor.withOpacity(0.7),
          ),
          prefixIcon: Icon(icon, color: ThemesDark().oppositeColor.withOpacity(0.7)),
          filled: true,
          fillColor: ThemesDark().normalColor.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade800.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.blue.shade400.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Future<void> _cleanKml() async {
    SSHSession? session = await SSH(ref: ref).cleanKML(context);
    if (session != null) {
      print(session.stdout);
    }else{
      print('Session is null');
    }
  }

  Future<void> _cleanBalloon() async {

    SSHSession? session = await SSH(ref: ref).cleanBalloon(context);
    if (session != null) {
      print(session.stdout);
    }else{
      print('Session is null');
    }
  }

  @override
  void dispose() {
    ipController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    portController.dispose();
    rigsController.dispose();
    apiKeyController.dispose();

    super.dispose();
  }
}