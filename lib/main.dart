import 'package:flutter/material.dart';
import 'dart:developer';

import 'rich_text_editor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Summernote Rich Text Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const MyHomePage(
        title: 'Rich Text Editor',
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
  final GlobalKey<RichTextEditorState> _editorKey = GlobalKey();
  String _content = '';

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
      ),
      body: Column(
        children: [
          Text(
            _content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
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
                child: RichTextEditor(
                  key: _editorKey,
                  onContentChanged: (content) {
                    // log('[+]Content changed: $content');
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
    );
  }
}
