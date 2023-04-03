import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_example/commands.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    //this is the function that will be called when the app starts to initialize the speech recognition
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    //this is the function that will be called when the user taps the microphone button to start listening
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    //this is the function that will be called when the user taps the microphone button again to stop listening
    await _speechToText.stop();
    setState(() {});
  }

  //this is the function that will be called when the speech recognition service returns a result
  //and it is used to update the text in the app in _startListening function
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      detectIfTextContainsOpenOrClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Recognized words:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(_lastWords),
                // child: Text(
                //   // If listening is active show the recognized words
                //   _speechToText.isListening
                //       ? '$_lastWords'
                //       // If listening isn't active but could be tell the user
                //       // how to start it, otherwise indicate that speech
                //       // recognition is not yet ready or not supported on
                //       // the target device
                //       : _speechEnabled
                //           ? 'Tap the microphone to start listening...'
                //           : 'Speech not available',
                // ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 50.0,
        duration: const Duration(milliseconds: 2000),
        // shape: BoxShape.rectangle,
        glowColor: Theme.of(context).primaryColor,
        animate: _speechToText.isListening ? true : false,
        child: FloatingActionButton(
          // shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(16.0))),
          // onPressed:
          //     _speechToText.isNotListening ? _startListening : _stopListening
          // ,
          onPressed: () async {
            if (_speechToText.isNotListening) {
              _startListening();
            } else {
              _stopListening();
            }
            // detectIfTextContainsOpenOrClose();
          },
          tooltip: 'Listen',
          child: Icon(
            !_speechToText.isNotListening ? Icons.mic_off : Icons.mic,
            size: 30,
          ),
        ),
      ),
    );
  }

  detectIfTextContainsOpenOrClose() {
    if (_lastWords.contains("open")) {
      if (_lastWords.contains("one") ||
          _lastWords.contains("1") ||
          _lastWords.contains("first")) {
        print("open one");
      } else if (_lastWords.contains("two") ||
          _lastWords.contains("2") ||
          _lastWords.contains("second") ||
          _lastWords.contains("to")) {
        print("open two");
      } else if (_lastWords.contains("three") ||
          _lastWords.contains("3") ||
          _lastWords.contains("third")) {
        print("open three");
      } else if (_lastWords.contains("four") ||
          _lastWords.contains("4") ||
          _lastWords.contains("fourth") ||
          _lastWords.contains("for")) {
        print("open four");
      }
    }
    if (_lastWords.contains("close")) {
      if (_lastWords.contains("one") ||
          _lastWords.contains("1") ||
          _lastWords.contains("first")) {
        print("close one");
      } else if (_lastWords.contains("two") ||
          _lastWords.contains("2") ||
          _lastWords.contains("second") ||
          _lastWords.contains("to")) {
        print("close two");
      } else if (_lastWords.contains("three") ||
          _lastWords.contains("3") ||
          _lastWords.contains("third")) {
        print("close three");
      } else if (_lastWords.contains("four") ||
          _lastWords.contains("4") ||
          _lastWords.contains("fourth") ||
          _lastWords.contains("for")) {
        print("close four");
      }
    }
  }
}
