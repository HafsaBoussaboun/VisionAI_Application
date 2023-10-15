import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'home.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    flutterTts.setLanguage('en-US');
    flutterTts.setSpeechRate(0.5); //speed of speech
    flutterTts.setVolume(1.0); //volume of speech
    flutterTts.setPitch(1);
    flutterTts.setCompletionHandler(() {
      Navigator.of(context).pushReplacementNamed('/home');
    });

    _speak('Your application will be displayed in 3 seconds. Please wait...');
    _controller.forward();
  }

  Future<void> _speak(String text) async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/seeing.png', // Replace with the path to your image
              width: 120.0,
              height: 120.0,
            ),
            const SizedBox(height: 15),
            const Text(
              'VISION AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'See Through AI',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (BuildContext context, Widget? child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  // ignore: prefer_const_constructors
                  child: Text(
                    'Your application will be displayed in 3 seconds. Please wait...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
