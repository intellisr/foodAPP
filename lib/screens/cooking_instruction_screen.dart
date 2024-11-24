import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart'; // Import speech_to_text package
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class CookingInstructionScreen extends StatefulWidget {
  final List<String> ingredients;
  final String steps;

  const CookingInstructionScreen({Key? key, required this.ingredients, required this.steps})
      : super(key: key);

  @override
  _CookingInstructionScreenState createState() => _CookingInstructionScreenState();
}

class _CookingInstructionScreenState extends State<CookingInstructionScreen> {
  Timer? _timer;
  int _start = 60; // Default timer duration in seconds
  bool _isRunning = false;
  bool _isPaused = false;
  final TextEditingController _timeController = TextEditingController();

  // Speech recognition and text-to-speech
  late SpeechToText _speechToText;
  bool _speechEnabled = false;
  String _lastWords = '';
  late FlutterTts _flutterTts;
  int _currentStepIndex = 0;

  List<String> steps = [];

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _speechToText = SpeechToText();
    _initSpeech();

    // Initialize steps
    steps = widget.steps.split('\n');
  }

  /// Initialize speech recognition
  Future<void> _initSpeech() async {
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle permission denial
      print('Microphone permission denied');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    // Initialize speech recognition
    bool available = await _speechToText.initialize(
      onStatus: (status) => print('Speech status: $status'),
      // onError: (errorNotification) => _errorHandler(errorNotification),
    );

    if (available) {
      setState(() {
        _speechEnabled = true;
      });
      print('Speech recognition initialized successfully');
    } else {
      setState(() {
        _speechEnabled = false;
      });
      print('Speech recognition not available');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  /// Error handler for speech recognition
  // Future<void> _errorHandler(Error errorNotification) async {
  //   print(
  //       'Speech recognition error: ${errorNotification.errorMsg}, permanent: ${errorNotification.permanent}');
  //   if (errorNotification.errorMsg == "error_no_match") {
  //     // Restart listening if no speech was recognized
  //     if (_isRunning && !_speechToText.isListening) {
  //       _flutterTts.speak('I did not catch that. Please try again.');
  //       _startListening();
  //     }
  //   } else {
  //     // Handle other errors
  //     _flutterTts.speak('An error occurred. Please try again later.');
  //   }
  // }

  /// Start the timer and begin listening for voice commands
  Future<void> startTimer() async {
    if (_isRunning) return;

    if (_isPaused) {
      // Resume the timer
      resumeTimer();
      return;
    }

    int stime=int.tryParse(_timeController.text)??1;

    setState(() {
      _start = stime * 60;
    });

    _isRunning = true;
    _isPaused = false;

    if (_speechEnabled) {
      _startListening();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition not available')),
      );
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _isRunning = false;
        });
        _stopListening();
        _flutterTts.speak('Timer finished.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Timer finished!')),
        );
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  /// Pause the timer and stop listening
  void pauseTimer() {
    if (_timer != null && _isRunning) {
      _timer!.cancel();
      setState(() {
        _isRunning = false;
        _isPaused = true;
      });
      _stopListening();
    }
  }

  /// Resume the timer and start listening
  void resumeTimer() {
    if (_isPaused) {
      _isRunning = true;
      _isPaused = false;

      if (_speechEnabled) {
        _startListening();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech recognition not available')),
        );
      }

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _isRunning = false;
          });
          _stopListening();
          _flutterTts.speak('Timer finished.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Timer finished!')),
          );
        } else {
          setState(() {
            _start--;
          });
        }
      });
    }
  }

  /// Reset the timer and stop listening
  void resetTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _start = 60; // Reset to default duration
      _isRunning = false;
      _isPaused = false;
      _timeController.clear(); // Clear the input field
    });
    _stopListening();
  }

  /// Start listening for voice commands
  void _startListening() async {
    if (!_speechToText.isListening) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        // listenFor: Duration(minutes: 30),
        // pauseFor: Duration(seconds: 5),
        partialResults: true,
        onSoundLevelChange: (level) => print('Sound level: $level'),
        localeId: 'en_US', // Adjust locale as needed
      );
      setState(() {});
    }
  }

  /// Stop listening for voice commands
  void _stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      setState(() {});
    }
  }

  /// Process the speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });

    if (result.finalResult) {
      String command = result.recognizedWords.toLowerCase();
      print('Recognized command: $command');

      if (command.contains('start')) {
        _currentStepIndex = 0; // Reset index to start
        _speakCurrentStep();
      } else if (command.contains('next')) {
        _currentStepIndex++;
        if (_currentStepIndex < steps.length) {
          _speakCurrentStep();
        } else {
          _flutterTts.speak('No more steps.');
        }
      } else if (command.contains('back')) {
        if (_currentStepIndex > 0) {
          _currentStepIndex--;
          _speakCurrentStep();
        } else {
          _flutterTts.speak('This is the first step.');
        }
      } else if (command.contains('repeat')) {
        _speakCurrentStep();
      } else if (command.contains('pause')) {
        pauseTimer();
        _flutterTts.speak('Timer paused.');
      } else if (command.contains('resume')) {
        resumeTimer();
        _flutterTts.speak('Timer resumed.');
      } else if (command.contains('stop')) {
        pauseTimer();
        _stopListening();
        _flutterTts.speak('Timer and listening stopped.');
      } else {
        _flutterTts.speak(
            'Command not recognized. Please say start, next, back, repeat, pause, resume, or stop.');
      }
    }

    // Restart listening if the app is still running
    if (_isRunning && !_speechToText.isListening) {
      _startListening();
    }
  }

  /// Use text-to-speech to speak the current step
  void _speakCurrentStep() async {
    // Check if the current index is within bounds
    if (_currentStepIndex < steps.length) {
      String step = steps[_currentStepIndex];
      await _flutterTts.speak(step);
      setState(() {}); // Update UI to highlight current step
    }
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    _speechToText.stop();
    _flutterTts.stop();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        '${(_start ~/ 60).toString().padLeft(2, '0')}:${(_start % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text("Cooking Instructions"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Ingredients',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Container(
              height: 100, // Adjust as needed
              child: ListView.builder(
                itemCount: widget.ingredients.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(widget.ingredients[index]),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Steps',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(
                      index == _currentStepIndex
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: index == _currentStepIndex ? Colors.blue : Colors.grey,
                    ),
                    title: Text(
                      steps[index],
                      style: TextStyle(
                        fontWeight: index == _currentStepIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Timer',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Divider(),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Set Timer (in Minutes)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            if (_isRunning && _speechToText.isListening)
              Text(
                'Listening...',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startTimer,
                  child: Text(_isPaused ? 'Resume' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: pauseTimer,
                  child: Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Colors.orange,
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: resetTimer,
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}