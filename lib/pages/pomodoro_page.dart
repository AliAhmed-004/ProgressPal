import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int _selectedDuration = 25 * 60; // Default: 25 minutes
  int _remainingTime = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _timerStarted = false;
  final TextEditingController _customTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _startTimer() {
    setState(() {
      if (!_timerStarted) {
        _remainingTime = _selectedDuration; // Only set this when starting fresh
        _timerStarted = true;
      }
      _isRunning = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _timer?.cancel();
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    setState(() => _isRunning = false);
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _remainingTime = _selectedDuration;
      _isRunning = false;
      _timerStarted = false;
    });
    _timer?.cancel();
  }

  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance
  void _onTimerComplete() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [500, 1000], repeat: 0);
    }

    // Play alarm sound
    await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text("Time's Up!"),
            content: Text("Take a break!"),
            actions: [
              TextButton(
                onPressed: () {
                  Vibration.cancel(); // Stop vibration
                  _audioPlayer.stop(); // Stop sound
                  Navigator.pop(context);
                  _resetTimer();
                },
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  void _setCustomTime() {
    int? minutes = int.tryParse(_customTimeController.text);
    if (minutes != null && minutes > 0) {
      setState(() {
        _selectedDuration = minutes * 60;
        _timerStarted = true;
        _remainingTime = _selectedDuration;
        _isRunning = true;
      });

      Navigator.pop(context);

      // Start the timer immediately
      _startTimer();
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _timerStarted ? _buildTimerUI() : _buildDurationSelectionUI(),
      ),
    );
  }

  Widget _buildDurationSelectionUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Pomodoro Mode"),
          SizedBox(height: 20),
          Text(
            "Select Duration",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDurationButton("25m", 25 * 60),
              SizedBox(width: 8),
              _buildDurationButton("50m", 50 * 60),
              SizedBox(width: 8),
              _buildCustomTimeButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Pomodoro Mode",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 30),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: _remainingTime / _selectedDuration,
                strokeWidth: 10,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
            Text(
              _formatTime(_remainingTime),
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(
              _isRunning ? "Pause" : "Start",
              _isRunning ? _pauseTimer : _startTimer,
            ),
            SizedBox(width: 10),
            _buildButton("Reset", _resetTimer),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationButton(String label, int seconds) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedDuration = seconds;
          _startTimer();
        });
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCustomTimeButton() {
    return ElevatedButton(
      onPressed: () => _showCustomTimeDialog(),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        "Custom",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showCustomTimeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Custom Time (minutes)"),
          content: TextField(
            controller: _customTimeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "e.g. 30"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(onPressed: _setCustomTime, child: Text("OK")),
          ],
        );
      },
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
