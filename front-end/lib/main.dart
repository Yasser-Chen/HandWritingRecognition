import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'dart:typed_data';
import 'dart:ui' as ui; // Import the ui package
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WriteVision',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      HomePage(),
      HandwritingRecognitionPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'WriteVision' : 'Handwriting Recognition', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () => _onItemTapped(0),
            child: Text('WriteVision', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
          TextButton(
            onPressed: () => _onItemTapped(1),
            child: Text('Handwriting Recognition', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth > 800 ? 800 : constraints.maxWidth),
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Handwriting Recognition Application 🌟',
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          SizedBox(height: 10),
          Text(
            'Discover the Magic of AI in the Palm of Your Hand!',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          SizedBox(height: 20),
          Text(
            'Welcome to our Handwriting Recognition App, a cutting-edge blend of technology and creativity. Whether you\'re exploring the wonders of AI or just looking for an engaging way to interact with numbers, this app offers a seamless experience designed for everyone.',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Text(
            '---',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          SizedBox(height: 20),
          Text(
            'What Makes Our App Unique?',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          SizedBox(height: 10),
          Text(
            '✨ Interactive Canvas\nDraw your numbers naturally on a digital canvas. Your strokes are instantly transformed into data for AI analysis—no need for perfection, just creativity!',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Text(
            '🤖 AI-Powered Accuracy\nPowered by TensorFlow, our advanced machine learning model interprets your handwritten digits with impressive precision. Behind the scenes, a robust neural network decodes your input into meaningful predictions.',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Text(
            '💻 Built for Speed & Simplicity\n- Express Server: Ensures fast and reliable communication between your input and the AI model.\n- Flutter Interface: A sleek, user-friendly design that makes interacting with the app a delight on any device.',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Text(
            '📚 Educational & Fun\nPerfect for students, educators, and AI enthusiasts! Experiment with different styles of writing, learn how AI recognizes patterns, and uncover the magic of machine learning.',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Text(
            '---',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          SizedBox(height: 20),
          Text(
            'How It Works',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          SizedBox(height: 10),
          VideoPlayerWidget(),
          SizedBox(height: 20),
          Text(
            '---',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          SizedBox(height: 20),
          Text(
            'Why You\'ll Love It',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          SizedBox(height: 10),
          Text(
            '- Instant Feedback: Get predictions in real time.\n- Explore AI: A hands-on way to see machine learning in action.\n- Cross-Platform Compatibility: Enjoy on any device with Flutter\'s responsive design.',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Text(
            '---',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          SizedBox(height: 20),
          Text(
            'Step into the Future of Handwriting Recognition\nExperience the perfect combination of technology, fun, and learning. Download now and see how AI interprets your handwriting—no matter how unique your style is!',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Text(
            'Try It Now!',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Let’s draw, learn, and explore together. ✍️',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/how_it_works.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : CircularProgressIndicator(),
    );
  }
}

class HandwritingRecognitionPage extends StatefulWidget {
  @override
  _HandwritingRecognitionPageState createState() => _HandwritingRecognitionPageState();
}

class _HandwritingRecognitionPageState extends State<HandwritingRecognitionPage> {
  bool _isDrawing = false;
  bool _isImporting = false;
  Uint8List? _imageData;
  List<Offset> _points = [];
  bool _canvasVisible = false;

  void _reset() {
    setState(() {
      _isDrawing = false;
      _isImporting = false;
      _imageData = null;
      _points.clear();
    });
  }

  void _submit() async {
    Uint8List? imageData;
    if (_isImporting && _imageData != null) {
      imageData = _imageData;
    } else {
      imageData = await _captureCanvas();
    }

    if (imageData != null) {
      final response = await http.post(
        Uri.parse('YOUR_ENDPOINT_URL'),
        body: imageData,
        headers: {'Content-Type': 'image/png'},
      );

      if (response.statusCode == 200) {
        print('Image sent successfully');
      } else {
        print('Failed to send image');
      }
    }
  }

  Future<Uint8List?> _captureCanvas() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < _points.length - 1; i++) {
      canvas.drawLine(_points[i], _points[i + 1], paint);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(400, 500);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  void _draw() {
    setState(() {
      _isDrawing = true;
      _isImporting = false;
      _canvasVisible = true;
    });
  }

  void _import() async {
    setState(() {
      _isDrawing = false;
      _isImporting = true;
      _canvasVisible = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      Uint8List? imageData = result.files.single.bytes;
      if (imageData != null) {
        img.Image? image = img.decodeImage(imageData);
        if (image != null) {
          img.Image resizedImage = img.copyResize(image, width: 400, height: 500);
          setState(() {
            _imageData = Uint8List.fromList(img.encodePng(resizedImage));
          });
        }
      }
    }
  }

  void _addPoint(Offset point) {
    setState(() {
      _points = List.from(_points)..add(point);
    });
  }

  void _addPointWithOffset(Offset point, Offset offset) {
    setState(() {
      _points = List.from(_points)..add(point + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: _reset,
                child: Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: _draw,
                child: Text('Draw'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: _import,
                child: Text('Import'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (_canvasVisible)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 500,
                    width: 400,
                    margin: EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _isImporting
                        ? _imageData != null
                            ? Image.memory(
                                _imageData!,
                                fit: BoxFit.contain,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.upload_file, size: 50),
                                    onPressed: _import,
                                  ),
                                  Text(
                                    'Drag and drop an image here or click to select a file',
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                        : GestureDetector(
                            onPanUpdate: (details) {
                              RenderBox renderBox = context.findRenderObject() as RenderBox;
                              _addPointWithOffset(renderBox.globalToLocal(details.globalPosition), details.delta);
                            },
                            onPanEnd: (details) {
                              setState(() {
                                if (_points.isNotEmpty) {
                                  _points.removeLast(); // Remove the last point to avoid extra line
                                }
                              });
                            },
                            child: CustomPaint(
                              painter: DrawingPainter(_points),
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 500,
                    width: 400,
                    color: Colors.grey[200],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter other) => other.points != points;
}
