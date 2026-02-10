import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int _selectedDuration = 25 * 60;
  int _remainingTime = 0;

  Timer? _timer;
  bool _isRunning = false;
  bool _timerStarted = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _customTimeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // ---------------- TIMER LOGIC ----------------

  void _startTimer() {
    if (!_timerStarted) {
      _remainingTime = _selectedDuration;
      _timerStarted = true;
    }

    setState(() => _isRunning = true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
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

  // ---------------- COMPLETION ----------------

  void _onTimerComplete() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [500, 1000], repeat: 0);
    }

    try {
      await _audioPlayer.play(AssetSource("sounds/alarm.mp3"));
    } catch (_) {}

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Icon(Icons.celebration, size: 50),
        content: const Text(
          "Session Complete!\nTake a break, you earned it.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Vibration.cancel();
              _audioPlayer.stop();
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text("Nice"),
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }

  double get _progress =>
      _remainingTime / _selectedDuration;

  // ---------------- CUSTOM TIME ----------------

  void _showCustomTimeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Custom Time (minutes)"),
        content: TextField(
          controller: _customTimeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "e.g. 30",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: _setCustomTime,
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }

  void _setCustomTime() {
    final minutes =
        int.tryParse(_customTimeController.text);

    if (minutes == null || minutes <= 0) return;

    setState(() {
      _selectedDuration = minutes * 60;
      _timerStarted = false;
    });

    Navigator.pop(context);
    _startTimer();
  }

  // ---------------- DISPOSE ----------------

  @override
  void dispose() {
    _timer?.cancel();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1B1B2F),
              Color(0xFF2D2D55),
              Color(0xFF3A3A72),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _timerStarted
                ? _buildTimerUI()
                : _buildDurationSelectionUI(),
          ),
        ),
      ),
    );
  }

  // ---------------- DURATION SELECTION ----------------

  Widget _buildDurationSelectionUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Pomodoro Mode",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          "Choose your focus session",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),

        const SizedBox(height: 30),

        Wrap(
          spacing: 12,
          children: [
            _durationChip("25 min", 25 * 60),
            _durationChip("50 min", 50 * 60),
            ActionChip(
              label: const Text("Custom"),
              onPressed: _showCustomTimeDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _durationChip(String label, int seconds) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedDuration == seconds,
      selectedColor: Colors.deepPurpleAccent,
      onSelected: (_) {
        setState(() => _selectedDuration = seconds);
        _startTimer();
      },
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Colors.white24,
    );
  }

  // ---------------- TIMER UI ----------------

  Widget _buildTimerUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Deep Focus Session",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white70,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 18),

        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1, end: _progress),
          duration: const Duration(milliseconds: 400),
          builder: (_, value, __) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 14,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation(
                      Colors.deepPurpleAccent,
                    ),
                  ),
                ),

                Text(
                  _formatTime(_remainingTime),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        FloatingActionButton.extended(
          backgroundColor: Colors.deepPurpleAccent,
          onPressed: _isRunning ? _pauseTimer : _startTimer,
          icon: Icon(
            _isRunning ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          label: Text(
            _isRunning ? "Pause Session" : "Start Session",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        IconButton(
          onPressed: _resetTimer,
          icon: const Icon(
            Icons.restart_alt,
            size: 34,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
