import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:speech_to_text/speech_to_text.dart';

Future main() async {
  Logger.level = Level.debug;
  Logger logger = Logger();

  runApp(MyApp(logger: logger));
}

class MyApp extends StatelessWidget {
  final Logger logger;
  const MyApp({super.key, required this.logger});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Button Example',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(logger: logger),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Logger logger;

  const MyHomePage({super.key, required this.logger});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _speechData = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedwig'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _handleButtonPress,
          icon: const Icon(Icons.mic),
          label: const Text('Dictate'),
        ),
      ),
    );
  }

  /// This has to happen only once per app
  Future _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  Future _startSpeechRecognition() async {
    _speechToText.listen(
      onResult: (result) {
        setState(() {
          _speechData = result.recognizedWords;
        });
      },
    );
  }

  Future _stopSpeechRecognition() async {
    _speechToText.stop();
  }

  Future<void> _handleButtonPress() async {
    // Handle button press event here
    widget.logger.d('Button pressed!');
    // Retrieve the API key from the environment variables
    const apiKey = 'my whisper key';

    if (!_speechToText.isListening) {
      await _startSpeechRecognition();
    }

    await _stopSpeechRecognition();

    // Make an HTTP POST request to the Whisper API
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/whisper/transcriptions'),
      headers: {'Authorization': 'Bearer $apiKey'},
      body: {'audio': _speechData},
    );

    // Handle the response from the Whisper API
    if (response.statusCode == 200) {
      // Success, do something with the response
      widget.logger.i('Whisper API response: ${response.body}');
    } else {
      // Error, handle accordingly
      widget.logger.e(
          'Error Code: ${response.statusCode}, Error Message: ${response.body}');
    }
  }
}
