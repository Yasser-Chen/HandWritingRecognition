import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'dart:typed_data';
import 'dart:ui' as ui; // Import the ui package
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:html' as html; // For OS-level drag-and-drop in Flutter web
import 'package:intl/intl.dart'; // Import for date formatting

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hand Writing Recognition',
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

  String? _userFullName; // Add a nullable field for the logged in user
  int? _userId; // new

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Initialize with HomePage and HandwritingRecognitionPage
    _widgetOptions = [
      HomePage(),
      HandwritingRecognitionPage(userId: _userId),
      HistoryPage(userId: _userId),
    ];
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    // Update widgetOptions whenever setState is called
    _widgetOptions = [
      HomePage(),
      HandwritingRecognitionPage(userId: _userId),
      HistoryPage(userId: _userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController userCtrl = TextEditingController();
        TextEditingController passCtrl = TextEditingController();
        return AlertDialog(
          title: Text('Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: userCtrl,
                  decoration: InputDecoration(labelText: 'Username')),
              TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password')),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Login'),
              onPressed: () async {
                final success = await _login(userCtrl.text, passCtrl.text);
                if (success) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController userCtrl = TextEditingController();
        TextEditingController passCtrl = TextEditingController();
        TextEditingController emailCtrl = TextEditingController();
        TextEditingController nameCtrl = TextEditingController();
        TextEditingController familyNameCtrl = TextEditingController();
        return AlertDialog(
          title: Text('Register'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: userCtrl,
                    decoration: InputDecoration(labelText: 'Username')),
                TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password')),
                TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(labelText: 'Email')),
                TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: 'Name')),
                TextField(
                    controller: familyNameCtrl,
                    decoration: InputDecoration(labelText: 'Family Name')),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Register'),
              onPressed: () async {
                final success = await _register(userCtrl.text, passCtrl.text,
                    emailCtrl.text, nameCtrl.text, familyNameCtrl.text);
                if (success) Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _register(String username, String password, String email,
      String name, String familyName) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "email": email,
          "name": name,
          "family_name": familyName
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) {
          setState(() {
            _userId = data["userId"];
            _userFullName = "$name $familyName";
          });
          return true;
        } else {
          // Show error message from response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["error"] ?? "Registration failed.")),
          );
        }
      } else {
        // Show generic error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Registration failed with status code ${response.statusCode}.")),
        );
      }
    } catch (e) {
      print(e);
      // Show exception message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred during registration.")),
      );
    }
    return false;
  }

  Future<bool> _login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) {
          setState(() {
            _userId = data["user"]["id"];
            _userFullName =
                "${data["user"]["name"]} ${data["user"]["family_name"]}";
          });
          return true;
        } else {
          // Show error message from response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["error"] ?? "Login failed.")),
          );
        }
      } else {
        // Show generic error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed !")),
        );
      }
    } catch (e) {
      print(e);
      // Show exception message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred during login.")),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          // Make title clickable
          onTap: () {
            setState(() {
              _selectedIndex = 0; // Navigate to HomePage
            });
          },
          child: Text(
            'Handwriting Recognition',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          if (_userFullName != null)
            Row(
              children: [
                Center(
                  child: Text(
                    _userFullName!,
                    style: TextStyle(
                        color: Colors.white, fontStyle: FontStyle.italic),
                  ),
                ),
                VerticalDivider(color: Colors.white, thickness: 1),
              ],
            ),
          if (_userId != null)
            TextButton(
              onPressed: () {
                setState(() => _selectedIndex = 1);
              },
              child: Text('Handwriting', style: TextStyle(color: Colors.white)),
            ),
          if (_userId != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 2; // go to history tab (new)
                });
              },
              child: Text('History', style: TextStyle(color: Colors.white)),
            ),
          if (_userId != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _userId = null;
                  _userFullName = null;
                  _selectedIndex = 0;
                });
              },
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          if (_userId == null)
            TextButton(
              onPressed: _showLoginDialog,
              child: Text('Login', style: TextStyle(color: Colors.white)),
            ),
          if (_userId == null)
            TextButton(
              onPressed: _showRegisterDialog,
              child: Text('Register', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth:
                      constraints.maxWidth > 800 ? 800 : constraints.maxWidth),
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
            style: GoogleFonts.poppins(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          SizedBox(height: 10),
          Text(
            'Discover the Magic of AI in the Palm of Your Hand!',
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
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
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
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
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
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
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
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
            style: GoogleFonts.poppins(
                fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
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
    _controller = VideoPlayerController.asset('videos/handwritinrecord.mp4')
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
  final int? userId; // Add userId parameter

  const HandwritingRecognitionPage({Key? key, this.userId})
      : super(key: key); // Constructor

  @override
  _HandwritingRecognitionPageState createState() =>
      _HandwritingRecognitionPageState();
}

class _HandwritingRecognitionPageState
    extends State<HandwritingRecognitionPage> {
  bool _isDrawing = false;
  bool _isImporting = false;
  Uint8List? _imageData;
  List<Offset> _points = [];
  bool _canvasVisible = false;
  bool _isDragOver = false; // New variable to track drag state
  String? _prediction;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isDrawing = true; // Automatically enter draw mode
    _canvasVisible = true;
  }

  void _reset() {
    setState(() {
      _isDrawing = false;
      _isImporting = false;
      _imageData = null;
      _points.clear();
      _prediction = null;
    });
  }

  void _submit() async {
    if (widget.userId == null) {
      // Ensure user is logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to submit.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    Uint8List? imageData;
    if (_isImporting && _imageData != null) {
      imageData = _imageData;
    } else {
      imageData = await _captureCanvas();
    }

    if (imageData != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/traiter-canvas'),
      );

      request.fields['userId'] = widget.userId.toString(); // Include userId
      request.files.add(http.MultipartFile.fromBytes(
        'canvas',
        imageData,
        filename: 'canvas.png',
        contentType: MediaType('image', 'png'),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseString = await http.Response.fromStream(response);
        final responseData = json.decode(responseString.body);
        setState(() {
          _prediction = responseData["text"].toString();
        });
      } else {
        print('Failed to send image');
      }
    }
    setState(() => _isLoading = false);
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
      _points.clear(); // Clear points when starting new drawing
      _canvasVisible = true;
    });
  }

  void _import() async {
    setState(() {
      _isDrawing = false;
      _isImporting = true;
      _canvasVisible = true;
    });
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      Uint8List? imageData = result.files.single.bytes;
      if (imageData != null) {
        img.Image? image = img.decodeImage(imageData);
        if (image != null) {
          img.Image resizedImage =
              img.copyResize(image, width: 400, height: 500);
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  // Remove old DragTarget & replace with HtmlDropZone
                  child: HtmlDropZone(
                    onDropBytes: (bytes) {
                      setState(() {
                        _isDragOver = false;
                        _isImporting = true;
                        final decoded = img.decodeImage(bytes);
                        if (decoded != null) {
                          final resizedImage =
                              img.copyResize(decoded, width: 400, height: 500);
                          _imageData =
                              Uint8List.fromList(img.encodePng(resizedImage));
                        }
                      });
                    },
                    onDragStateChange: (dragOver) {
                      setState(() => _isDragOver = dragOver);
                    },
                    child: Container(
                      height: 500,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isDragOver ? Colors.blue : Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _isImporting
                          ? _imageData != null
                              ? Image.memory(_imageData!, fit: BoxFit.contain)
                              : Column(
                                  // ...existing code...
                                  children: <Widget>[
                                    // ...existing code...
                                  ],
                                )
                          : GestureDetector(
                              onPanUpdate: (details) {
                                RenderBox renderBox =
                                    context.findRenderObject() as RenderBox;
                                Offset localPosition = details.localPosition;
                                final size = renderBox.size;
                                // Clamp to container boundaries
                                final dx =
                                    localPosition.dx.clamp(0.0, size.width);
                                final dy =
                                    localPosition.dy.clamp(0.0, size.height);
                                _addPoint(Offset(dx, dy));
                              },
                              onPanStart: (details) {
                                RenderBox renderBox =
                                    context.findRenderObject() as RenderBox;
                                Offset localPosition = details.localPosition;
                                final size = renderBox.size;
                                // Clamp to container boundaries
                                final dx =
                                    localPosition.dx.clamp(0.0, size.width);
                                final dy =
                                    localPosition.dy.clamp(0.0, size.height);
                                _addPoint(Offset(dx, dy));
                              },
                              onPanEnd: (details) {
                                setState(() {
                                  _points.add(
                                      Offset.zero); // Prevent connecting lines
                                });
                              },
                              child: CustomPaint(
                                painter: DrawingPainter(_points),
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: 500,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : _prediction == null
                              ? Text(
                                  "Waiting for your submission...",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "$_prediction",
                                  style: TextStyle(
                                      fontSize: 370,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                    ),
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
    canvas.clipRect(Rect.fromLTWH(
        0, 0, size.width, size.height)); // Clip to canvas boundaries
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12.0; // Increased stroke width

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter other) => other.points != points;
}

// Minimal widget for handling OS-level file drops on Flutter web
class HtmlDropZone extends StatefulWidget {
  final Widget child;
  final ValueChanged<Uint8List> onDropBytes;
  final ValueChanged<bool> onDragStateChange;

  const HtmlDropZone({
    Key? key,
    required this.child,
    required this.onDropBytes,
    required this.onDragStateChange,
  }) : super(key: key);

  @override
  _HtmlDropZoneState createState() => _HtmlDropZoneState();
}

class _HtmlDropZoneState extends State<HtmlDropZone> {
  @override
  void initState() {
    super.initState();
    html.document.addEventListener('dragover', _onDragOver);
    html.document.addEventListener('drop', _onDrop);
    html.document.addEventListener('dragleave', _onDragLeave); // new
  }

  @override
  void dispose() {
    html.document.removeEventListener('dragover', _onDragOver);
    html.document.removeEventListener('drop', _onDrop);
    html.document.removeEventListener('dragleave', _onDragLeave);
    super.dispose();
  }

  void _onDragOver(html.Event event) {
    event.preventDefault();
    widget.onDragStateChange(true);
  }

  void _onDrop(html.Event event) async {
    event.preventDefault();
    widget.onDragStateChange(false);

    final dropEvent = event as dynamic; // Remove 'as html.DragEvent'
    final files = dropEvent.dataTransfer?.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        if (reader.result != null) {
          widget.onDropBytes(reader.result as Uint8List);
        }
      });
    }
  }

  void _onDragLeave(html.Event event) {
    event.preventDefault();
    widget.onDragStateChange(false);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Simple page to display all images belonging to the logged user
class HistoryPage extends StatefulWidget {
  final int? userId;
  const HistoryPage({Key? key, this.userId}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> _images = [];

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _fetchImages(); // Refetch images when userId changes
    }
  }

  void _fetchImages() async {
    if (widget.userId != null) {
      final response = await http
          .get(Uri.parse('http://localhost:3000/images/${widget.userId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) {
          setState(() {
            _images = data["images"];
          });
        } else {
          setState(() {
            _images = [];
          });
        }
      } else {
        setState(() {
          _images = [];
        });
      }
    } else {
      setState(() {
        _images = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _images.isEmpty
        ? Center(child: Text("No uploads found"))
        : LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              double width = constraints.maxWidth;
              if (width > 1200) {
                crossAxisCount = 3;
              } else if (width > 800) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 1;
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Responsive columns
                  crossAxisSpacing: 10, // Horizontal spacing
                  mainAxisSpacing: 10, // Vertical spacing
                  childAspectRatio: 1, // Fixed aspect ratio
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final imgRec = _images[index];
                  // Format the created_at timestamp
                  final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(
                    DateTime.parse(imgRec["created_at"]),
                  );
                  return Container(
                    width: 150, // Fixed width
                    height: 150, // Fixed height
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            'http://localhost:3000/input-folder/${imgRec["path"]}',
                            fit: BoxFit.contain, // Use BoxFit.contain
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                "Uploaded on: $formattedDate",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Prediction: ${imgRec["prediction"]}",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
  }
}
