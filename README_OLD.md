# Summernote Rich Text Box

A Flutter package that provides a rich text editor using Summernote with WebView integration for Windows desktop applications.

## Features

- 🖋️ **Rich Text Editing**: Full WYSIWYG editor powered by Summernote.js
- 🪟 **Windows Optimized**: Specifically designed for Windows desktop applications
- 🔧 **WebView Integration**: Uses flutter_inappwebview for seamless HTML rendering
- 📝 **Content Management**: Easy methods to get, set, and clear content
- 🎯 **Command Execution**: Support for Summernote commands (bold, italic, etc.)
- 📊 **Comprehensive Logging**: Built-in logging system for debugging
- 🚀 **Production Ready**: Handles both debug and release/Inno Setup builds

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  summernote_richtextbox:
    path: ../summernote_richtextbox # Adjust path as needed
```

## Usage

### Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:summernote_richtextbox/summernote_richtextbox.dart';

class MyEditor extends StatefulWidget {
  @override
  State<MyEditor> createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  final GlobalKey<SummernoteEditorState> _editorKey = GlobalKey();
  String _content = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rich Text Editor')),
      body: SummernoteEditor(
        key: _editorKey,
        initialContent: '<p>Welcome to the editor!</p>',
        onContentChanged: (content) {
          setState(() {
            _content = content;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final content = await _editorKey.currentState?.getContent();
          print('Current content: $content');
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
```

### Available Methods

```dart
// Get current HTML content
String? content = await _editorKey.currentState?.getContent();

// Set HTML content
await _editorKey.currentState?.setContent('<p>New content</p>');

// Clear all content
await _editorKey.currentState?.clearContent();

// Execute Summernote commands
await _editorKey.currentState?.execCommand('bold');
await _editorKey.currentState?.execCommand('italic');

// Insert plain text
await _editorKey.currentState?.insertText('Hello World');
```

## Requirements

- Flutter SDK >=3.0.0
- Windows desktop target
- WebView2 Runtime (usually pre-installed on Windows 11)

## Assets

The package includes all necessary assets:

- Summernote.js library
- Bootstrap CSS framework
- Bootstrap Icons
- jQuery library

## Logging

The package includes a comprehensive logging system that writes to `C:\summernotelogs\`. To enable logging:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging
  await CustomLogger.instance.initialize();

  runApp(MyApp());
}
```

## Troubleshooting

### "Loading editor..." Issue

If you see infinite loading in production builds:

1. Ensure WebView2 Runtime is installed
2. Check logs in `C:\summernotelogs\`
3. Verify asset paths are correct

### WebView2 Runtime

Download and install from: https://developer.microsoft.com/en-us/microsoft-edge/webview2/

## Example

See the `/example` folder for a complete implementation example.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Features

- **Rich Text Editing**: Full-featured WYSIWYG editor with Summernote
- **Native Integration**: Seamless communication between Flutter and JavaScript
- **Windows Desktop**: Optimized for Windows desktop with native window controls
- **Minimal UI**: Clean, modern interface focused on content creation
- **Toolbar Actions**: Flutter-based toolbar with common formatting options
- **Content Management**: Get, set, and clear content programmatically

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Windows 10/11
- Visual Studio 2019 or later with C++ desktop development tools

### Installation

1. Clone or download this project
2. Run `flutter pub get` to install dependencies
3. Enable Windows desktop support:
   ```bash
   flutter config --enable-windows-desktop
   ```
4. Run the application:
   ```bash
   flutter run -d windows
   ```

## Usage

### Basic Operations

- **Text Formatting**: Use the toolbar buttons for bold, italic, underline
- **Lists**: Create bulleted and numbered lists
- **Content Export**: Click the copy button to copy HTML content to clipboard
- **Clear Content**: Use the clear button to reset the editor

### API Integration

The `RichTextEditor` widget provides these methods:

```dart
// Get current content
String? content = await editorKey.currentState?.getContent();

// Set content
await editorKey.currentState?.setContent('<p>Hello World</p>');

// Clear content
await editorKey.currentState?.clearContent();

// Execute formatting commands
await editorKey.currentState?.execCommand('bold');
```

## Architecture

- **main.dart**: Application entry point and main UI
- **rich_text_editor.dart**: WebView wrapper with Flutter-JavaScript bridge
- **assets/summernote.html**: Embedded HTML with Summernote configuration
- **Communication**: JavaScript handlers for bidirectional data flow

## Customization

### Modifying Summernote Toolbar

Edit the `toolbar` configuration in `assets/summernote.html`:

```javascript
toolbar: [
  ["style", ["style"]],
  ["font", ["bold", "italic", "underline"]],
  ["fontsize", ["fontsize"]],
  ["para", ["ul", "ol"]],
  // Add or remove toolbar groups
];
```

### Styling

Customize the editor appearance by modifying the CSS in `summernote.html` or updating the Flutter theme in `main.dart`.

## Dependencies

- `flutter_inappwebview`: ^6.0.0 - WebView implementation
- CDN Resources:
  - jQuery 3.6.0
  - Bootstrap 5.3.0
  - Summernote 0.8.18

## Building for Release

```bash
flutter build windows --release
```

The built application will be available in `build/windows/runner/Release/`.

## Troubleshooting

### WebView not loading

- Ensure internet connectivity for CDN resources
- Check Windows Defender/antivirus settings
- Verify flutter_inappwebview installation

### JavaScript errors

- Check browser console in debug mode
- Verify HTML file is properly included in assets
- Ensure pubspec.yaml includes asset declarations

## License

This project is open source and available under the MIT License.
