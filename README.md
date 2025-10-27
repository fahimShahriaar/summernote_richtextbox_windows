# Summernote Rich Text Editor for Flutter

A Flutter package that provides a rich text editor widget using Summernote.js. This package is specifically designed for Windows desktop applications and uses WebView to render the Summernote editor.

## Features

- 🎨 Rich text editing with Summernote.js
- 📱 Full formatting toolbar (bold, italic, underline, colors, etc.)
- �️ Image insertion support
- � Copy/paste functionality
- 🔗 Link insertion and editing
- 📝 HTML content support
- 💻 Windows desktop optimized
- 📊 Logging system for debugging

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  summernote_richtextbox: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:summernote_richtextbox/summernote_richtextbox.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<SummernoteEditorState> _editorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SummernoteEditor(
        key: _editorKey,
        onContentChanged: (content) {
          print('Content changed: $content');
        },
        onFocus: (content) {
          print('Editor gained focus with content: $content');
        },
        onBlur: (content) {
          print('Editor lost focus with content: $content');
        },
        initialContent: '<p>Welcome to Summernote!</p>',
      ),
    );
  }
}
```

### Getting and Setting Content

```dart
// Get current content
final controller = _editorKey.currentState?.getController();
final content = await controller?.getContent();

// Set content
controller?.setContent('<p>New content here</p>');

// Clear content
controller?.clearContent();
```

### Advanced Operations

```dart
// Insert text at cursor position
controller?.insertText('Hello World!');

// Insert HTML at cursor position
controller?.insertHtml('<strong>Bold text</strong>');

// Execute Summernote commands
controller?.execCommand('bold');        // Toggle bold
controller?.execCommand('italic');      // Toggle italic
controller?.execCommand('underline');   // Toggle underline

// Focus control
controller?.focus();  // Focus the editor
controller?.blur();   // Remove focus
```

### Using Focus and Blur Callbacks

The `onFocus` and `onBlur` callbacks are triggered when the editor gains or loses focus and provide the current content:

```dart
SummernoteEditor(
  key: _editorKey,
  onContentChanged: (content) {
    print('Content changed: ${content.length} characters');
  },
  onFocus: (content) {
    // This is called when the user clicks into the editor
    print('Editor gained focus with content: ${content.length} characters');
    // You can show editing hints, analytics, etc.
    showEditingHints();
  },
  onBlur: (content) {
    // This is called when the user clicks outside the editor
    print('Editor lost focus with content: ${content.length} characters');
    // You can save the content, show notifications, etc.
    saveContent(content);
  },
)
```

### Using with Controller Parameter (Alternative)

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final SummernoteController _controller = SummernoteController();

  @override
  Widget build(BuildContext context) {
    return SummernoteEditor(
      controller: _controller,
      onContentChanged: (content) {
        print('Content changed: $content');
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## API Reference

### SummernoteController Methods

| Method                        | Description                  | Returns           |
| ----------------------------- | ---------------------------- | ----------------- |
| `getContent()`                | Gets current HTML content    | `Future<String?>` |
| `setContent(String content)`  | Sets HTML content            | `Future<void>`    |
| `clearContent()`              | Clears all content           | `Future<void>`    |
| `insertText(String text)`     | Inserts plain text at cursor | `Future<void>`    |
| `insertHtml(String html)`     | Inserts HTML at cursor       | `Future<void>`    |
| `execCommand(String command)` | Executes Summernote command  | `Future<void>`    |
| `focus()`                     | Focuses the editor           | `Future<void>`    |
| `blur()`                      | Unfocuses the editor         | `Future<void>`    |

### SummernoteEditor Properties

| Property           | Type                    | Description                                                |
| ------------------ | ----------------------- | ---------------------------------------------------------- |
| `controller`       | `SummernoteController?` | Optional controller for editor operations                  |
| `onContentChanged` | `Function(String)?`     | Callback when content changes                              |
| `onFocus`          | `Function(String)?`     | Callback when editor gains focus, receives current content |
| `onBlur`           | `Function(String)?`     | Callback when editor loses focus, receives current content |
| `initialContent`   | `String?`               | Initial HTML content                                       |

## Requirements

- Flutter SDK >=3.0.0
- Windows desktop target
- WebView2 Runtime (usually pre-installed on Windows 11)

## Logging

The package includes a comprehensive logging system that writes to `C:\summernotelogs\`. Initialize logging in your main function:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CustomLogger.instance.initialize();
  runApp(MyApp());
}
```

## Example

See the `/example` folder for complete implementation examples.

## License

This project is licensed under the MIT License.
