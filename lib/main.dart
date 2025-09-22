import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'rich_text_editor.dart';

void main() {
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
      home: const MyHomePage(title: 'Rich Text Editor'),
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
        actions: [
          IconButton(
            onPressed: _getContent,
            icon: const Icon(Icons.content_copy, color: Color(0xFF64748B)),
            tooltip: 'Get Content',
          ),
          IconButton(
            onPressed: _clearContent,
            icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
            tooltip: 'Clear Content',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildToolbarButton(
                  icon: Icons.format_bold,
                  label: 'Bold',
                  onPressed: () => _editorKey.currentState?.execCommand('bold'),
                ),
                _buildToolbarButton(
                  icon: Icons.format_italic,
                  label: 'Italic',
                  onPressed: () => _editorKey.currentState?.execCommand('italic'),
                ),
                _buildToolbarButton(
                  icon: Icons.format_underlined,
                  label: 'Underline',
                  onPressed: () => _editorKey.currentState?.execCommand('underline'),
                ),
                const SizedBox(width: 16),
                _buildToolbarButton(
                  icon: Icons.format_list_bulleted,
                  label: 'Bullet List',
                  onPressed: () => _editorKey.currentState?.execCommand('insertUnorderedList'),
                ),
                _buildToolbarButton(
                  icon: Icons.format_list_numbered,
                  label: 'Number List',
                  onPressed: () => _editorKey.currentState?.execCommand('insertOrderedList'),
                ),
              ],
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
                child: RichTextEditor(
                  key: _editorKey,
                  onContentChanged: (content) {
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

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: const Color(0xFF475569)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getContent() async {
    final content = await _editorKey.currentState?.getContent();
    if (content != null) {
      Clipboard.setData(ClipboardData(text: content));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _clearContent() {
    _editorKey.currentState?.clearContent();
  }
}