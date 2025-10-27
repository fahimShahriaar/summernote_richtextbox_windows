import 'package:flutter/material.dart';
import 'package:summernote_richtextbox/summernote_richtextbox.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Summernote Package Example (Alternative)',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Alternative approach: using controller as parameter
  final SummernoteController _controller = SummernoteController();
  String _displayContent = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alternative Controller Usage'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Display current content length
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Column(
              children: [
                Text(
                  'Editor Ready: ${_controller.isReady}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Content: ${_displayContent.length} characters',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Control buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final content = await _controller.getContent();
                    if (content != null) {
                      setState(() {
                        _displayContent = content;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...')),
                      );
                    }
                  },
                  child: const Text('Get Content'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.setContent('<p><strong>Hello from controller parameter!</strong></p>');
                  },
                  child: const Text('Set Content'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.clearContent();
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.insertText('Text via controller! ');
                  },
                  child: const Text('Insert Text'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.insertHtml('<em>HTML via controller!</em> ');
                  },
                  child: const Text('Insert HTML'),
                ),
              ],
            ),
          ),
          const Divider(),
          // The editor with controller parameter
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SummernoteEditor(
                controller: _controller,
                initialContent: '<p>This example uses controller as a parameter!</p>',
                onContentChanged: (content) {
                  setState(() {
                    _displayContent = content;
                  });
                  print('Content changed: ${content.length} characters');
                },
                onFocus: (content) {
                  setState(() {
                    _displayContent = content;
                  });
                  print('Editor focused with content: ${content.length} characters');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Editor focused - Ready to edit: ${content.length} chars'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                onBlur: (content) {
                  setState(() {
                    _displayContent = content;
                  });
                  print('Editor blurred with content: ${content.length} characters');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Editor lost focus - Content saved: ${content.length} chars'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
