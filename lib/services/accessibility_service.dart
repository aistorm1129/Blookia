import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class AccessibilityService extends ChangeNotifier {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  // Accessibility settings
  double _textScaleFactor = 1.0;
  bool _highContrastMode = false;
  bool _reduceAnimations = false;
  bool _screenReaderEnabled = false;
  bool _hapticFeedbackEnabled = true;
  bool _soundFeedbackEnabled = true;
  FontWeight _fontWeight = FontWeight.normal;
  double _buttonHeight = 48.0;
  double _minimumTouchTargetSize = 44.0;

  // Color schemes
  late ColorScheme _standardColorScheme;
  late ColorScheme _highContrastColorScheme;

  // Getters
  double get textScaleFactor => _textScaleFactor;
  bool get highContrastMode => _highContrastMode;
  bool get reduceAnimations => _reduceAnimations;
  bool get screenReaderEnabled => _screenReaderEnabled;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  bool get soundFeedbackEnabled => _soundFeedbackEnabled;
  FontWeight get fontWeight => _fontWeight;
  double get buttonHeight => _buttonHeight;
  double get minimumTouchTargetSize => _minimumTouchTargetSize;

  ColorScheme get currentColorScheme =>
      _highContrastMode ? _highContrastColorScheme : _standardColorScheme;

  Future<void> initialize() async {
    await _loadSettings();
    _initializeColorSchemes();
    notifyListeners();
  }

  void _initializeColorSchemes() {
    _standardColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3),
      brightness: Brightness.light,
    );

    _highContrastColorScheme = const ColorScheme.light(
      primary: Color(0xFF000000),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF0066CC),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
      background: Color(0xFFFFFFFF),
      onBackground: Color(0xFF000000),
      error: Color(0xFFCC0000),
      onError: Color(0xFFFFFFFF),
    );
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('accessibility_settings');
    
    _textScaleFactor = box.get('textScaleFactor', defaultValue: 1.0);
    _highContrastMode = box.get('highContrastMode', defaultValue: false);
    _reduceAnimations = box.get('reduceAnimations', defaultValue: false);
    _screenReaderEnabled = box.get('screenReaderEnabled', defaultValue: false);
    _hapticFeedbackEnabled = box.get('hapticFeedbackEnabled', defaultValue: true);
    _soundFeedbackEnabled = box.get('soundFeedbackEnabled', defaultValue: true);
    
    final fontWeightIndex = box.get('fontWeight', defaultValue: FontWeight.normal.index);
    _fontWeight = FontWeight.values[fontWeightIndex];
    
    _buttonHeight = box.get('buttonHeight', defaultValue: 48.0);
    _minimumTouchTargetSize = box.get('minimumTouchTargetSize', defaultValue: 44.0);
  }

  Future<void> _saveSettings() async {
    final box = await Hive.openBox('accessibility_settings');
    
    await box.put('textScaleFactor', _textScaleFactor);
    await box.put('highContrastMode', _highContrastMode);
    await box.put('reduceAnimations', _reduceAnimations);
    await box.put('screenReaderEnabled', _screenReaderEnabled);
    await box.put('hapticFeedbackEnabled', _hapticFeedbackEnabled);
    await box.put('soundFeedbackEnabled', _soundFeedbackEnabled);
    await box.put('fontWeight', _fontWeight.index);
    await box.put('buttonHeight', _buttonHeight);
    await box.put('minimumTouchTargetSize', _minimumTouchTargetSize);
  }

  // Text scaling methods
  Future<void> increaseTextSize() async {
    if (_textScaleFactor < 2.0) {
      _textScaleFactor += 0.1;
      await _saveSettings();
      notifyListeners();
      _provideFeedback('Text size increased');
    }
  }

  Future<void> decreaseTextSize() async {
    if (_textScaleFactor > 0.8) {
      _textScaleFactor -= 0.1;
      await _saveSettings();
      notifyListeners();
      _provideFeedback('Text size decreased');
    }
  }

  Future<void> resetTextSize() async {
    _textScaleFactor = 1.0;
    await _saveSettings();
    notifyListeners();
    _provideFeedback('Text size reset to default');
  }

  // High contrast mode
  Future<void> toggleHighContrast() async {
    _highContrastMode = !_highContrastMode;
    await _saveSettings();
    notifyListeners();
    _provideFeedback(_highContrastMode ? 'High contrast enabled' : 'High contrast disabled');
  }

  // Animation preferences
  Future<void> toggleReduceAnimations() async {
    _reduceAnimations = !_reduceAnimations;
    await _saveSettings();
    notifyListeners();
    _provideFeedback(_reduceAnimations ? 'Animations reduced' : 'Animations enabled');
  }

  // Screen reader support
  Future<void> toggleScreenReader() async {
    _screenReaderEnabled = !_screenReaderEnabled;
    await _saveSettings();
    notifyListeners();
    _provideFeedback(_screenReaderEnabled ? 'Screen reader enabled' : 'Screen reader disabled');
  }

  // Feedback preferences
  Future<void> toggleHapticFeedback() async {
    _hapticFeedbackEnabled = !_hapticFeedbackEnabled;
    await _saveSettings();
    notifyListeners();
    
    if (_hapticFeedbackEnabled) {
      HapticFeedback.lightImpact();
      _provideFeedback('Haptic feedback enabled');
    } else {
      _provideFeedback('Haptic feedback disabled');
    }
  }

  Future<void> toggleSoundFeedback() async {
    _soundFeedbackEnabled = !_soundFeedbackEnabled;
    await _saveSettings();
    notifyListeners();
    _provideFeedback(_soundFeedbackEnabled ? 'Sound feedback enabled' : 'Sound feedback disabled');
  }

  // Font weight adjustment
  Future<void> setFontWeight(FontWeight weight) async {
    _fontWeight = weight;
    await _saveSettings();
    notifyListeners();
    _provideFeedback('Font weight changed');
  }

  // Touch target sizing
  Future<void> increaseTouchTargetSize() async {
    if (_minimumTouchTargetSize < 60.0) {
      _minimumTouchTargetSize += 4.0;
      _buttonHeight = _minimumTouchTargetSize + 4.0;
      await _saveSettings();
      notifyListeners();
      _provideFeedback('Touch targets enlarged');
    }
  }

  Future<void> decreaseTouchTargetSize() async {
    if (_minimumTouchTargetSize > 40.0) {
      _minimumTouchTargetSize -= 4.0;
      _buttonHeight = _minimumTouchTargetSize + 4.0;
      await _saveSettings();
      notifyListeners();
      _provideFeedback('Touch targets reduced');
    }
  }

  // Feedback methods
  void _provideFeedback(String message) {
    if (_hapticFeedbackEnabled) {
      HapticFeedback.lightImpact();
    }
    
    if (_soundFeedbackEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    
    if (_screenReaderEnabled) {
      // In a real app, you would announce this to screen readers
      debugPrint('Screen reader announcement: $message');
    }
  }

  void provideHapticFeedback(HapticFeedbackType type) {
    if (_hapticFeedbackEnabled) {
      switch (type) {
        case HapticFeedbackType.lightImpact:
          HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.mediumImpact:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavyImpact:
          HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selectionClick:
          HapticFeedback.selectionClick();
          break;
      }
    }
  }

  void provideSoundFeedback(SystemSoundType type) {
    if (_soundFeedbackEnabled) {
      SystemSound.play(type);
    }
  }

  // Text style helpers
  TextStyle getAccessibleTextStyle({
    TextStyle? baseStyle,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: (fontSize ?? 14) * _textScaleFactor,
      fontWeight: fontWeight ?? _fontWeight,
      color: color,
      height: _textScaleFactor > 1.2 ? 1.4 : null, // Increase line height for larger text
    ).merge(baseStyle);
  }

  // Button style helpers
  ButtonStyle getAccessibleButtonStyle({
    ButtonStyle? baseStyle,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return ElevatedButton.styleFrom(
      minimumSize: Size(_minimumTouchTargetSize, _buttonHeight),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      textStyle: TextStyle(
        fontSize: 16 * _textScaleFactor,
        fontWeight: _fontWeight,
      ),
    ).merge(baseStyle);
  }

  // Animation duration helper
  Duration getAnimationDuration(Duration baseDuration) {
    if (_reduceAnimations) {
      return Duration(milliseconds: (baseDuration.inMilliseconds * 0.3).round());
    }
    return baseDuration;
  }

  // Semantic helpers
  Widget makeAccessible({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? isButton,
    bool? isHeader,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton ?? false,
      header: isHeader ?? false,
      onTap: onTap,
      child: child,
    );
  }

  // Screen reader announcements
  void announceToScreenReader(String message) {
    if (_screenReaderEnabled) {
      // In a real app, this would use platform-specific screen reader APIs
      debugPrint('Screen reader: $message');
    }
  }

  // Focus management helpers
  Widget buildFocusableContainer({
    required Widget child,
    required VoidCallback onTap,
    String? semanticLabel,
    bool autofocus = false,
  }) {
    return Focus(
      autofocus: autofocus,
      child: Builder(
        builder: (context) {
          final focusNode = Focus.of(context);
          return GestureDetector(
            onTap: () {
              focusNode.requestFocus();
              onTap();
              provideHapticFeedback(HapticFeedbackType.selectionClick);
            },
            child: Container(
              decoration: BoxDecoration(
                border: focusNode.hasFocus
                    ? Border.all(
                        color: _highContrastMode ? Colors.black : Colors.blue,
                        width: 2,
                      )
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Semantics(
                label: semanticLabel,
                button: true,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  // Color contrast helpers
  Color getContrastingColor(Color backgroundColor) {
    if (_highContrastMode) {
      // Simple contrast calculation
      final luminance = backgroundColor.computeLuminance();
      return luminance > 0.5 ? Colors.black : Colors.white;
    }
    return Theme.of(NavigationService.navigatorKey.currentContext!).colorScheme.onSurface;
  }

  bool hasGoodContrast(Color foreground, Color background) {
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    
    final lighter = foregroundLuminance > backgroundLuminance 
        ? foregroundLuminance 
        : backgroundLuminance;
    final darker = foregroundLuminance > backgroundLuminance 
        ? backgroundLuminance 
        : foregroundLuminance;
    
    final contrast = (lighter + 0.05) / (darker + 0.05);
    
    // WCAG AA standard requires 4.5:1 for normal text, 3:1 for large text
    return contrast >= 4.5;
  }

  // Quick settings presets
  Future<void> applyPreset(AccessibilityPreset preset) async {
    switch (preset) {
      case AccessibilityPreset.standard:
        _textScaleFactor = 1.0;
        _highContrastMode = false;
        _reduceAnimations = false;
        _fontWeight = FontWeight.normal;
        _minimumTouchTargetSize = 44.0;
        _buttonHeight = 48.0;
        break;
        
      case AccessibilityPreset.visualImpairment:
        _textScaleFactor = 1.4;
        _highContrastMode = true;
        _fontWeight = FontWeight.w600;
        _minimumTouchTargetSize = 52.0;
        _buttonHeight = 56.0;
        break;
        
      case AccessibilityPreset.motorImpairment:
        _minimumTouchTargetSize = 56.0;
        _buttonHeight = 60.0;
        _hapticFeedbackEnabled = true;
        break;
        
      case AccessibilityPreset.cognitiveSupport:
        _reduceAnimations = true;
        _soundFeedbackEnabled = true;
        _textScaleFactor = 1.2;
        break;
    }
    
    await _saveSettings();
    notifyListeners();
    _provideFeedback('Accessibility preset applied');
  }
}

enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
}

enum AccessibilityPreset {
  standard,
  visualImpairment,
  motorImpairment,
  cognitiveSupport,
}

// Navigation service for context access
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static NavigatorState? get navigator => navigatorKey.currentState;
  static BuildContext? get context => navigatorKey.currentContext;
}