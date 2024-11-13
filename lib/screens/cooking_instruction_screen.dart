import 'dart:async';
import 'package:flutter/material.dart';

class CookingInstructionScreen extends StatefulWidget {
  final List<String> ingredients;

  const CookingInstructionScreen({Key? key, required this.ingredients})
      : super(key: key);

  @override
  _CookingInstructionScreenState createState() =>
      _CookingInstructionScreenState();
}

class _CookingInstructionScreenState extends State<CookingInstructionScreen> {
  Timer? _timer;
  int _start = 60; // Default timer duration in seconds
  bool _isRunning = false;
  final TextEditingController _timeController = TextEditingController();

  void startTimer() {
    if (_isRunning) return;

    setState(() {
      // Set _start to the user-defined time if provided, otherwise default to 60
      _start = int.tryParse(_timeController.text) ?? 60;
    });

    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _isRunning = false;
        });
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

  void pauseTimer() {
    if (_timer != null && _isRunning) {
      _timer!.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void resetTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _start = 60; // Reset to default duration
      _isRunning = false;
      _timeController.clear(); // Clear the input field
    });
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
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
            Expanded(
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
              'Timer',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Divider(),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Set Timer (in seconds)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startTimer,
                  child: Text('Start'),
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
