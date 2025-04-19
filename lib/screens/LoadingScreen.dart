import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_eclipse/screens/HomeScreen.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatefulWidget {
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  @override
  void initState()
  {
    Future.delayed(Duration(seconds: 6),() async{
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: CupertinoColors.black,
      body: Stack(

        children: [
          // Centered Lottie animation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/galaxy.json',
                  width: 400,
                  height:  400,

                ),
                SizedBox(),
               Lottie.asset('assets/lottie/loading_anim.json',
               width: 80,
               height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
