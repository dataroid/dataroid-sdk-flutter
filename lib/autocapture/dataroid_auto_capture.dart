import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart'
    show
        EditableText,
        TextEditingController,
        TextField,
        TextFormField,
        Scaffold,
        Navigator;
import 'package:flutter/rendering.dart';
import 'package:dataroid_plugin_flutter/autocapture/gesture_recognizer.dart';
import 'package:dataroid_plugin_flutter/autocapture/widget_identifier.dart';
import 'package:dataroid_plugin_flutter/dataroid_plugin_flutter.dart';
import 'package:dataroid_plugin_flutter/logger/dataroid_internal_logger.dart';

class DataroidAutoCaptureConfig {
  final bool componentInteractions;
  final bool gestures;

  /// When `true` (the default) every emitted event carries a `screenTracker`
  /// computed from the wired-in [navigatorObserver]. Set to `false` to
  /// suppress screen context on every event without removing the observer
  /// (handy for screens where you want auto-capture but not screen
  /// correlation, e.g. anonymous onboarding flows).
  final bool screenTracking;

  /// Widget runtime type names to exclude from auto-capture.
  ///
  /// Matched against `Object.runtimeType.toString()`. **This filter has no
  /// effect in obfuscated builds** (`flutter build --obfuscate`), where
  /// runtime type names are mangled at compile time. For reliable exclusion
  /// in release builds, use [ignoredComponentIds] instead.
  final List<String> ignoredWidgets;

  /// Component IDs to exclude from auto-capture.
  ///
  /// Matched against `ValueKey<String>` values and `Semantics.identifier`.
  /// Unlike [ignoredWidgets], this works in obfuscated builds because
  /// keys and semantics identifiers are user-supplied strings.
  ///
  /// Example:
  /// ```dart
  /// DataroidAutoCaptureConfig(
  ///   ignoredComponentIds: ['skip-this-button'],
  /// )
  /// // Then in your widget tree:
  /// ElevatedButton(
  ///   key: const ValueKey('skip-this-button'),
  ///   onPressed: () {},
  ///   child: const Text('Hidden'),
  /// )
  /// ```
  final List<String> ignoredComponentIds;

  final DataroidNavigatorObserver? navigatorObserver;

  const DataroidAutoCaptureConfig({
    this.componentInteractions = true,
    this.gestures = true,
    this.screenTracking = true,
    this.ignoredWidgets = const [],
    this.ignoredComponentIds = const [],
    this.navigatorObserver,
  });
}

class _ComponentHit {
  final WidgetInfo _info;
  final Coordinates? _coordinates;
  final Element _element;
  const _ComponentHit(this._info, this._coordinates, this._element);
}

class DataroidAutoCapture extends StatefulWidget {
  final Widget child;
  final DataroidAutoCaptureConfig config;

  const DataroidAutoCapture({
    super.key,
    required this.child,
    this.config = const DataroidAutoCaptureConfig(),
  });

  @override
  State<DataroidAutoCapture> createState() => _DataroidAutoCaptureState();
}

class _DataroidAutoCaptureState extends State<DataroidAutoCapture> {
  late final DataroidGestureRecognizer _gestureRecognizer;
  late final DataroidWidgetIdentifier _widgetIdentifier;
  final DataroidPluginFlutter _sdk = DataroidPluginFlutter();

  static const _textChangeDebounceDuration = Duration(milliseconds: 500);

  TextEditingController? _trackedTextController;
  String? _trackedTextInitialValue;
  WidgetInfo? _trackedTextInfo;
  Coordinates? _trackedTextCoordinates;
  Timer? _textChangeDebounceTimer;

  /// Component hit captured at `pointer-down` and dispatched only on
  /// `pointer-up` if no swipe / long-press won the gesture arena. Mirrors
  /// the native pattern (Android `View.OnClickListener.onClick` and iOS
  /// `UIControlEventTouchUpInside`) where the platform itself only fires
  /// the click after confirming the touch was a tap. Text inputs are not
  /// stored here — they need their controller hooked on pointer-down so
  /// keystrokes are captured before the dispatch decision.
  _ComponentHit? _pendingComponentHit;

  @override
  void initState() {
    super.initState();
    _widgetIdentifier = DataroidWidgetIdentifier(
      ignoredWidgets: widget.config.ignoredWidgets,
      ignoredComponentIds: widget.config.ignoredComponentIds,
    );
    _gestureRecognizer = DataroidGestureRecognizer(
      DataroidGestureRecognizerConfig(
        onTouch: widget.config.gestures ? _onTouch : null,
        onDoubleTap: widget.config.gestures ? _onDoubleTap : null,
        onLongPress: widget.config.gestures ? _onLongPress : null,
        onSwipe: widget.config.gestures ? _onSwipe : null,
      ),
    );
    DataroidInternalLogger.debug('DataroidAutoCapture: initialized');
  }

  @override
  void dispose() {
    // Flush instead of just cancelling so any text typed within the debounce
    // window before disposal is still reported (otherwise the event is lost
    // when the user navigates away immediately after typing).
    _flushTrackedTextChange();
    _gestureRecognizer.dispose();
    DataroidInternalLogger.debug('DataroidAutoCapture: disposed');
    super.dispose();
  }

  ScreenTracker? _getScreenTracker() {
    if (!widget.config.screenTracking) {
      return null;
    }
    final screen = widget.config.navigatorObserver?.currentScreen;
    if (screen == null) {
      return null;
    }
    return ScreenTracker(label: screen, viewClass: screen);
  }

  void _onTouch(GesturePoint point) {
    _sdk.collectTouch(TouchAttributes(
      className: 'Screen',
      touchPoint: TouchPoint(point.x.toInt(), point.y.toInt()),
      screenTracker: _getScreenTracker(),
    ));
  }

  void _onDoubleTap(GesturePoint point) {
    _sdk.collectDoubleTap(DoubleTapAttributes(
      className: 'Screen',
      touchPoint: TouchPoint(point.x.toInt(), point.y.toInt()),
      screenTracker: _getScreenTracker(),
    ));
  }

  void _onLongPress(GesturePoint point) {
    _sdk.collectLongPress(LongPressAttributes(
      className: 'Screen',
      touchPoint: TouchPoint(point.x.toInt(), point.y.toInt()),
      screenTracker: _getScreenTracker(),
    ));
  }

  void _onSwipe(SwipeData swipe) {
    _sdk.collectSwipe(SwipeAttributes(
      className: 'Screen',
      swipePoints: SwipePoints(
        start: TouchPoint(swipe.start.x.toInt(), swipe.start.y.toInt()),
        end: TouchPoint(swipe.end.x.toInt(), swipe.end.y.toInt()),
      ),
      screenTracker: _getScreenTracker(),
    ));
  }

  void _handlePointerDown(PointerDownEvent event) {
    _gestureRecognizer.onPointerDown(
      event.position.dx,
      event.position.dy,
    );
    _pendingComponentHit = null;

    if (widget.config.componentInteractions) {
      _stageComponentHit(event.position);
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _gestureRecognizer.onPointerMove(
      event.position.dx,
      event.position.dy,
    );
  }

  void _handlePointerUp(PointerUpEvent event) {
    _gestureRecognizer.onPointerUp(
      event.position.dx,
      event.position.dy,
    );

    final pending = _pendingComponentHit;
    _pendingComponentHit = null;
    // Only fire the deferred component event if the gesture arena settled on
    // a tap. If a swipe or long-press won, the user did not actually click
    // this button or toggle, and emitting the event would corrupt
    // engagement metrics.
    if (pending != null && !_gestureRecognizer.didFireNonTap) {
      try {
        _dispatchComponentEvent(pending._info, pending._coordinates);
      } catch (e) {
        DataroidInternalLogger.error(
            'DataroidAutoCapture: component dispatch failed: $e');
      }
    }
  }

  /// Hit-tests the touched widget on `pointer-down`. Text inputs are wired
  /// to their controller immediately (so keystrokes are captured), button
  /// and toggle hits are stored in `_pendingComponentHit` and only
  /// dispatched on a confirmed tap (see `_handlePointerUp`).
  void _stageComponentHit(Offset position) {
    try {
      final hit = _findComponentAtPosition(position);
      final isTextInput =
          hit?._info.interactionType == WidgetInteractionType.textInput;

      if (!isTextInput) _flushTrackedTextChange();
      if (hit == null) {
        return;
      }

      if (isTextInput) {
        _startTrackingTextField(hit._info, hit._coordinates, hit._element);
      } else {
        _pendingComponentHit = hit;
      }
    } catch (e) {
      DataroidInternalLogger.error(
          'DataroidAutoCapture: component identification failed: $e');
    }
  }

  _ComponentHit? _findComponentAtPosition(Offset position) {
    final renderObj = context.findRenderObject();
    if (renderObj is! RenderBox) {
      return null;
    }

    final result = BoxHitTestResult();
    try {
      renderObj.hitTest(result, position: position);
    } catch (e) {
      DataroidInternalLogger.error('DataroidAutoCapture: hit test failed: $e');
      return null;
    }

    // Build a priority map: RenderObject → index in the hit-test path.
    // Index 0 is the innermost (most specific) target — highest priority.
    final targetPriority = <RenderObject, int>{};
    var pathIndex = 0;
    for (final entry in result.path) {
      final t = entry.target;
      if (t is RenderObject && !targetPriority.containsKey(t)) {
        targetPriority[t] = pathIndex;
      }
      pathIndex++;
    }

    if (targetPriority.isEmpty) {
      return null;
    }

    // Single DFS walk with integrated identification. Instead of calling
    // _findElementForRenderObject (full subtree DFS) once per hit-test
    // entry — O(n × m) — we walk the element tree exactly once and
    // identify inline, tracking the innermost (lowest-index) identifiable
    // match. When the innermost target is matched the walk exits early,
    // making the common case (tap on a button) significantly cheaper.
    int bestIndex = pathIndex; // worse than any real index
    _ComponentHit? bestHit;

    void visitor(Element element) {
      if (bestIndex == 0) return; // can't improve — stop traversal

      final ro = element.renderObject;
      if (ro != null) {
        final idx = targetPriority[ro];
        if (idx != null && idx < bestIndex) {
          // Consume this target so deeper elements sharing the same
          // renderObject (ComponentElements inherit their descendant's
          // RenderObject) cannot re-match. This mirrors the old per-entry
          // behaviour where _findElementForRenderObject returned only the
          // outermost element for each RenderObject.
          targetPriority.remove(ro);

          final info = _widgetIdentifier.identify(element);
          if (info != null) {
            bestHit = _ComponentHit(info, _extractCoordinates(ro), element);
            bestIndex = idx;
            if (bestIndex == 0) return; // early exit
          }
        }
      }

      element.visitChildElements(visitor);
    }

    visitor(context as Element);
    return bestHit;
  }

  static Coordinates? _extractCoordinates(RenderObject target) {
    if (target is! RenderBox || !target.hasSize) {
      return null;
    }
    try {
      final topLeft = target.localToGlobal(Offset.zero);
      final size = target.size;
      return Coordinates(
        left: topLeft.dx.toInt(),
        top: topLeft.dy.toInt(),
        right: (topLeft.dx + size.width).toInt(),
        bottom: (topLeft.dy + size.height).toInt(),
      );
    } catch (_) {
      // The render object may detach during a hit test; coordinates are optional.
      return null;
    }
  }

  void _startTrackingTextField(
      WidgetInfo info, Coordinates? coordinates, Element hitElement) {
    _flushTrackedTextChange();

    _trackedTextInfo = info;
    _trackedTextCoordinates = coordinates;
    _trackedTextController = _findTextFieldController(hitElement);
    _trackedTextInitialValue = _trackedTextController?.text ?? '';

    _trackedTextController?.addListener(_onTrackedTextChanged);
  }

  /// Builds a text-change event whose `textValue` matches what the native
  /// SDKs emit:
  /// - sensitive field (password input or visible-password keyboard) → empty string
  ///   and no `placeholder`, mirroring iOS `dtr_isSecureText` and Android's
  ///   `containsSensitiveInformation` branch in `AutoCaptureEventCollectorImpl`.
  /// - everything else → the actual `controller.text` and the field's
  ///   `placeholder`, again matching the native SDKs.
  TextChangeAttributes _buildTextChangeAttributes(String currentValue) {
    final info = _trackedTextInfo!;
    final captureValues = !info.isSensitive;
    return TextChangeAttributes(
      className: info.className,
      accessibilityLabel: info.accessibilityLabel,
      textValue: captureValues ? currentValue : '',
      placeholder: captureValues ? info.placeholder : null,
      componentId: info.componentId,
      coordinates: _trackedTextCoordinates,
      screenTracker: _getScreenTracker(),
    );
  }

  void _onTrackedTextChanged() {
    _textChangeDebounceTimer?.cancel();
    _textChangeDebounceTimer = Timer(_textChangeDebounceDuration, () {
      if (_trackedTextController == null || _trackedTextInfo == null) {
        return;
      }
      final currentValue = _trackedTextController!.text;
      // Emit on any change, including a clear (empty after non-empty), to
      // match Android's `DebounceTextWatcher.afterTextChanged` and iOS's
      // `textValueDidEndEditing`. Sensitivity gating happens in
      // `_buildTextChangeAttributes` so the event still fires but `textValue`
      // is empty for password fields.
      if (currentValue != _trackedTextInitialValue) {
        _sdk.collectTextChange(_buildTextChangeAttributes(currentValue));
        _trackedTextInitialValue = currentValue;
      }
    });
  }

  void _flushTrackedTextChange() {
    _textChangeDebounceTimer?.cancel();
    _textChangeDebounceTimer = null;

    if (_trackedTextController == null || _trackedTextInfo == null) {
      return;
    }

    _trackedTextController!.removeListener(_onTrackedTextChanged);

    final currentValue = _trackedTextController!.text;
    if (currentValue != _trackedTextInitialValue) {
      _sdk.collectTextChange(_buildTextChangeAttributes(currentValue));
    }

    _trackedTextController = null;
    _trackedTextInitialValue = null;
    _trackedTextInfo = null;
    _trackedTextCoordinates = null;
  }

  TextEditingController? _findTextFieldController(Element hitElement) {
    // Walk UP from the hit element (inner GestureDetector) to find the
    // TextField ancestor, then get its controller
    Element? textFieldElement;
    hitElement.visitAncestorElements((ancestor) {
      final w = ancestor.widget;
      if (w is TextField || w is TextFormField) {
        textFieldElement = ancestor;
        return false;
      }
      if (w is Scaffold || w is Navigator) {
        return false;
      }
      return true;
    });

    // The hit element itself might be the TextField
    textFieldElement ??=
        (hitElement.widget is TextField || hitElement.widget is TextFormField)
            ? hitElement
            : null;

    if (textFieldElement == null) {
      return null;
    }

    // Try explicit controller first
    final w = textFieldElement!.widget;
    if (w is TextField && w.controller != null) {
      return w.controller;
    }

    // Walk DOWN the TextField's subtree to find EditableText's controller
    TextEditingController? controller;
    void visit(Element el) {
      if (controller != null) {
        return;
      }
      if (el.widget is EditableText) {
        controller = (el.widget as EditableText).controller;
        return;
      }
      el.visitChildElements(visit);
    }

    textFieldElement!.visitChildElements(visit);
    return controller;
  }

  void _dispatchComponentEvent(WidgetInfo info, [Coordinates? coordinates]) {
    final screen = _getScreenTracker();

    switch (info.interactionType) {
      case WidgetInteractionType.button:
        _sdk.collectButtonClick(ButtonClickAttributes(
          className: info.className,
          accessibilityLabel: info.accessibilityLabel,
          label: info.label,
          componentId: info.componentId,
          coordinates: coordinates,
          screenTracker: screen,
        ));
        break;
      case WidgetInteractionType.textInput:
        break;
      case WidgetInteractionType.toggle:
        _sdk.collectToggleChange(ToggleChangeAttributes(
          className: info.className,
          accessibilityLabel: info.accessibilityLabel,
          isChecked: info.isChecked ?? false,
          label: info.label,
          componentId: info.componentId,
          coordinates: coordinates,
          screenTracker: screen,
        ));
        break;
      case WidgetInteractionType.radio:
        _sdk.collectRadioButtonSelect(RadioButtonSelectAttributes(
          className: info.className,
          accessibilityLabel: info.accessibilityLabel,
          label: info.label,
          groupName: info.groupName,
          elementName: info.elementName,
          elementType: info.elementType ?? 'radio',
          componentId: info.componentId,
          coordinates: coordinates,
          screenTracker: screen,
        ));
        break;
      case WidgetInteractionType.unknown:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      child: widget.child,
    );
  }
}
