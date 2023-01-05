// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as p;

// class WaveForm extends StatefulWidget {
//   WaveForm({super.key, required this.uri, required this.duration});
//   Uri uri;
//   Duration duration;
//   @override
//   _WaveFormState createState() => _WaveFormState();
// }

// class _WaveFormState extends State<WaveForm> {
//   late Future<List<double>?> _waveformData;

//   @override
//   void initState() {
//     super.initState();

//     // Load the waveform data for an audio file
//     _waveformData = Future.value(extractWaveformData(p.fromUri(widget.uri)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder(
//         future: _waveformData,
//         builder: (context, AsyncSnapshot<List<double>?> snapshot) {
//           if (snapshot.hasData) {
//             // Waveform data is available, so we can display it using a CustomPaint widget
//             return CustomPaint(
//               painter: WaveformPainter(waveformData: snapshot.data!),
//               child: Container(),
//             );
//           } else {
//             // Waveform data is not yet available, so we show a loading indicator
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// class WaveformPainter extends CustomPainter {
//   WaveformPainter({required this.waveformData});

//   final List<double> waveformData;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.red
//       ..strokeWidth = 1.0
//       ..strokeCap = StrokeCap.round;

//     for (int i = 0; i < waveformData.length - 1; i++) {
//       final x1 = i / waveformData.length * size.width;
//       final y1 = (1.0 - waveformData[i]) / 2 * size.height;
//       final x2 = (i + 1) / waveformData.length * size.width;
//       final y2 = (1.0 - waveformData[i + 1]) / 2 * size.height;
//       canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(WaveformPainter oldDelegate) {
//     return oldDelegate.waveformData != waveformData;
//   }
// }

// List<double>? extractWaveformData(String filePath) {
//   // Read the raw audio data from the file
//   final audioData = File(filePath).readAsBytesSync();
//   final audioByteData = ByteData.view(audioData.buffer);

//   // Process the audio data to generate the waveform data
//   final waveformData = <double>[];
//   for (int i = 0; i < audioByteData.lengthInBytes; i += 2) {
//     final sample = audioByteData.getInt16(i);
//     waveformData.add(sample / 32768);
//   }

//   return waveformData;
// }

// Future<ByteData> _loadAudio(String audioPath) async {
//   // Open the audio file at the specified file path
//   File audioFile = File(audioPath);

//   // Read the contents of the file into a List<int>
//   List<int> audioBytes = await audioFile.readAsBytes();

//   // Create a ByteData object from the audio bytes
//   return ByteData.view(Uint8List.fromList(audioBytes).buffer);
// }

// // Convert the ByteData object into a List<int>
// Future<List<int>> _getAudioBytes(String audioPath) async {
//   try {
//     ByteData data = await _loadAudio(audioPath);
//     return data.buffer.asUint8List();
//   } catch (e) {
//     print('Error loading audio file: $e');
//     return [];
//   }
// }
