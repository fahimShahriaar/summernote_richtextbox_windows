import 'package:flutter/material.dart';
import 'package:summernote_richtextbox/summernote_richtextbox.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the logger
  await CustomLogger.instance.initialize();
  CustomLogger.instance.info('Example application starting...');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Summernote Rich Text Editor Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const MyHomePage(
        title: 'Summernote Rich Text Editor Example',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<SummernoteEditorState> _editorKey = GlobalKey();
  String _content = '';

  @override
  void initState() {
    super.initState();
    CustomLogger.instance.info('Example MyHomePage initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final content = await _editorKey.currentState?.getContent();
              if (content != null) {
                CustomLogger.instance.info('Saved content: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Content saved to logs!')),
                );
              }
            },
            tooltip: 'Save Content',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _editorKey.currentState?.clearContent();
            },
            tooltip: 'Clear Content',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              _content.isEmpty ? 'Start typing in the editor below...' : 'Content length: ${_content.length} characters',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SummernoteEditor(
                  key: _editorKey,
                  initialContent: '<p>Welcome to <strong>Summernote Rich Text Editor</strong>!</p><p>You can format text, add images, links, and more.</p>',
                  onContentChanged: (content) {
                    CustomLogger.instance.debug('Content changed - Length: ${content.length}');
                    setState(() {
                      _content = content;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _editorKey.currentState?.insertText('Hello from Flutter! ');
        },
        label: const Text('Insert Text'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
