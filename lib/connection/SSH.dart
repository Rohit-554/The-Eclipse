import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:the_eclipse/providers/connection_providers.dart';
import 'package:the_eclipse/widget/widgets.dart';

import '../kml/KmlMaker.dart';
import '../kml/NamePlaceBallon.dart';
import '../utils/constants.dart';

class SSH {
  final WidgetRef ref;

  SSH({required this.ref});

  SSHClient? _client;
  final CustomWidgets customWidgets = CustomWidgets();

  //connect with rigs
  Future<bool?> connectToLG(BuildContext context) async {
    try {
      final socket = await SSHSocket.connect(
          ref.read(ipProvider), ref.read(portProvider),
          timeout: const Duration(seconds: 5));
      ref
          .read(sshClientProvider.notifier)
          .state = SSHClient(
        socket,
        username: ref.read(usernameProvider),
        onPasswordRequest: () => ref.read(passwordProvider),
      );
      ref
          .read(connectedProvider.notifier)
          .state = true;
      return true;
    } catch (e) {
      ref
          .read(connectedProvider.notifier)
          .state = false;
      print('Failed to connect: $e');
      customWidgets.showSnackBar(
          context: context, message: e.toString(), color: Colors.red);
      return false;
    }
  }

  shutdownLG(context) async {
    try {
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i "echo ${ref.read(passwordProvider)} | sudo -S poweroff"');
      }
    } catch (error) {
      customWidgets.showSnackBar(
          context: context, message: error.toString(), color: Colors.red);
    }
  }

  //relaunch Lg
  relunchLG() async {
    try {
      _client = ref.read(sshClientProvider);
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        String cmd = """RELAUNCH_CMD="\\
          if [ -f /etc/init/lxdm.conf ]; then
            export SERVICE=lxdm
          elif [ -f /etc/init/lightdm.conf ]; then
            export SERVICE=lightdm
          else
            exit 1
          fi
          if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
            echo ${ref.read(passwordProvider)} | sudo -S service \\\${SERVICE} start
          else
            echo ${ref.read(passwordProvider)} | sudo -S service \\\${SERVICE} restart
          fi
          " && sshpass -p ${ref.read(
            passwordProvider)} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await ref.read(sshClientProvider)?.execute(
            '"/home/${ref.read(usernameProvider)}/bin/lg-relaunch" > /home/${ref
                .read(usernameProvider)}/log.txt');
        await ref.read(sshClientProvider)?.execute(cmd);
      }

      /*if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session = await _client!.execute('lg-relaunch');
      return session;*/
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> makeOrbit() async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "playtour=Orbit" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  initialConnect({int i = 0}) async {
    if (i == 0) {
      await ref.read(sshClientProvider)?.run(
          "echo '${BalloonMakers
              .blankBalloon()}' > /var/www/html/kml/slave_${ref.read(
              rightmostRigProvider)}.kml");
      await ref.read(sshClientProvider)?.run(
          "echo '${KMLMakers.screenOverlayImage(Const.overLayImageLink,
              Const.splashAspectRatio)}' > /var/www/html/kml/slave_${ref.read(
              leftmostRigProvider)}.kml");
    }
  }

  Future<SSHSession?> locatePlace(String place) async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "search=$place" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> planetEarth() async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "planet=earth" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> planetMoon() async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "planet=moon" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> execute() async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "search=Lleida" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> search(String place) async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "search=$place" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  cleanKML(context) async {
    try {
      String blank = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
  </Document>
</kml>''';
      _client = ref.read(sshClientProvider);
      await stopOrbit(context);
      await ref.read(sshClientProvider)?.execute("echo '$blank' > /var/www/html/kml/slave_3.kml");
      /*await ref.read(sshClientProvider)?.execute(
          "echo '$blank' > /var/www/html/kml/slave_3.kml");*/
    } catch (error) {
      // showSnackBar(
      //     context: context, message: error.toString(), color: Colors.red);
    }
  }

  cleanSlaves(context) async {
    String blank = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
  </Document>
</kml>''';
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        await ref
            .read(sshClientProvider)
            ?.run("echo '$blank' > /var/www/html/kml/slave_$i.kml");
      }
    } catch (error) {
      await cleanSlaves(context);
    }
  }

  disconnect(context, {bool snackBar = true}) async {
    ref.read(sshClientProvider)?.close();
    ref
        .read(sshClientProvider.notifier)
        .state = null;
    if (snackBar) {
      /* showSnackBar(
          context: context,
          message: translate('settings.disconnection_completed'));*/
    }
    ref
        .read(connectedProvider.notifier)
        .state = false;
  }

  Future ChatResponseBalloon(String data) async {
    print("Andar hai ");
    int rigs = 4;
    _client = ref.read(sshClientProvider);
    rigs = ref.read(rightmostRigProvider);
    String openLogoKML =
    '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
 <name>About Data</name>
 <Style id="about_style">
   <BalloonStyle>
     <textColor>ffffffff</textColor>
     <text>
        <h2>$data</h2>
       
        
     </text>
     <bgColor>ff15151a</bgColor>
   </BalloonStyle>
 </Style>
 <Placemark id="ab">
   <description>
   </description>
   <LookAt>
     <longitude>0</longitude>
     <latitude>0</latitude>
    
   </LookAt>
   <styleUrl>#about_style</styleUrl>
   <gx:balloonVisibility>1</gx:balloonVisibility>
   <Point>
     <coordinates>0,0,0</coordinates>
   </Point>
 </Placemark>
</Document>
</kml>''';
    try {
      await _client?.execute("echo '$openLogoKML' > /var/www/html/kml/slave_2.kml");
    } catch (e) {
      return Future.error(e);
    }
  }

  cleanBalloon(context) async {
    try {
      String blank = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
  </Document>
</kml>''';
      await ref.read(sshClientProvider)?.run(
          "echo '${BalloonMakers
              .blankBalloon()}' > /var/www/html/kml/slave_${ref.read(
              leftmostRigProvider)}.kml");
    } catch (error) {
      // await connectionRetry(context);
      await cleanBalloon(context);
    }
  }

  setRefresh(context) async {
    _client = ref.read(sshClientProvider);
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        String search = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';
        String replace =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';

        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref
                .read(
                passwordProvider)} | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml\'');
        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref
                .read(
                passwordProvider)} | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml\'');
      }
    } catch (error) {
      /*showSnackBar(
          context: context, message: error.toString(), color: Colors.red);
    }*/
    }
  }


    showOverlay(context) async {
      try {
        _client = ref.read(sshClientProvider);
      } catch (error) {
        await showOverlay(context);
      }
    }

    Future<SSHSession?> planetMars() async {
      try {
        _client = ref.read(sshClientProvider);
        if (_client == null) {
          print('SSH client is not initialized.');
          return null;
        }
        final session = await ref
            .read(sshClientProvider)!
            .execute('echo "planet=mars" >/tmp/query.txt');
        return session;
      } catch (e) {
        print('An error occurred while executing the command: $e');
        return null;
      }
    }

    //render kml in provided slave
    Future<String> renderInSlave(context, int slaveNo, String kml) async {
      try {
        await ref
            .read(sshClientProvider)
            ?.run("echo '$kml' > /var/www/html/kml/slave_$slaveNo.kml");
        return kml;
      } catch (error) {
        customWidgets.showSnackBar(
            context: context, message: error.toString(), color: Colors.red);
        return BalloonMakers.blankBalloon();
      }
    }

    //use to fly to particular orbit and orbit around
    flyToOrbit(context, double latitude, double longitude, double zoom,
        double tilt, double bearing) async {
      print("flytoorbit");
      try {
        print("inside");
        await ref.read(sshClientProvider)?.execute(
            'echo "flytoview=${KMLMakers.orbitLookAtLinear(
                latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
      } catch (error) {
        print("error$error");
        // await connectionRetry(context);
        // await flyToOrbit(context, latitude, longitude, zoom, tilt, bearing);
      }
    }

    //this is used to fly to particular view linearly
    flyTo(context, double latitude, double longitude, double zoom, double tilt,
        double bearing) async {
      try {
        Future.delayed(Duration.zero).then((x) async {
          ref
              .read(lastGMapPositionProvider.notifier)
              .state = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: zoom,
            tilt: tilt,
            bearing: bearing,
          );
        });
        await ref.read(sshClientProvider)?.run(
            'echo "flytoview=${KMLMakers.lookAtLinear(
                latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
      } catch (error) {
        try {
          // await connectionRetry(context);
          await flyTo(context, latitude, longitude, zoom, tilt, bearing);
        } catch (e) {}
      }
    }

    stopOrbit(context) async {
      try {
        await ref.read(sshClientProvider)?.execute(
            'echo "exittour=true" > /tmp/query.txt');
      } catch (error) {
        stopOrbit(context);
      }
    }
  }