# Flutter Summernote Rich Text Editor

A Flutter Windows desktop application that embeds the Summernote WYSIWYG editor using flutter_inappwebview.

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
    ['style', ['style']],
    ['font', ['bold', 'italic', 'underline']],
    ['fontsize', ['fontsize']],
    ['para', ['ul', 'ol']],
    // Add or remove toolbar groups
]
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