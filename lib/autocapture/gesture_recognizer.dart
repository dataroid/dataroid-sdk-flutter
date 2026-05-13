import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';

const double _kSwipeThresholdDistance = 50.0;
const double _kSwipeThresholdVelocity = 0.3;
const int _kDoubleTapDelayMs = 300;
const int _kLongPressDurationMs = 500;
const double _kTouchSlop = 10.0;

class GesturePoint {
  final double x;
  final double y;

  const GesturePoint(this.x, this.y);
}

class SwipeData {
  final GesturePoint start;
  final GesturePoint end;

  const SwipeData({required this.start, required this.end});
}

typedef GesturePointCallback = void Function(GesturePoint point);
typedef SwipeCallback = void Function(SwipeData swipe);

class DataroidGestureRecognizerConfig {
  final GesturePointCallback? onTouch;
  final GesturePointCallback? onDoubleTap;
  final GesturePointCallback? onLongPress;
  final SwipeCallback? onSwipe;

  const DataroidGestureRecognizerConfig({
    this.onTouch,
    this.onDoubleTap,
    this.onLongPress,
    this.onSwipe,
  });
}

class DataroidGestureRecognizer {
  final DataroidGestureRecognizerConfig _config;

  double? _startX;
  double? _startY;
  int? _startTime;
  bool _moved = false;
  bool _longPressFired = false;
  bool _didFireNonTap = false;
  Timer? _longPressTimer;

  GesturePoint? _lastTapPoint;
  int? _lastTapTime;

  Timer? _pendingSingleTapTimer;
  GesturePoint? _pendingSingleTapPoint;

  /// `true` between `onPointerDown` and the next `onPointerDown` if the
  /// current touch resolved as a swipe or long-press (i.e. anything other
  /// than a tap). The auto-capture host reads this on `pointer-up` to skip
  /// firing a `collectButtonClick` / `collectToggleChange` for a touch that
  /// was actually a non-tap gesture.
  bool get didFireNonTap => _didFireNonTap;

  DataroidGestureRecognizer(this._config);

  void onPointerDown(double x, double y) {
    _cancelLongPress();

    _startX = x;
    _startY = y;
    _startTime = clock.now().millisecondsSinceEpoch;
    _moved = false;
    _longPressFired = false;
    _didFireNonTap = false;

    _longPressTimer = Timer(
      const Duration(milliseconds: _kLongPressDurationMs),
      () {
        if (!_moved && _startX != null) {
          _longPressFired = true;
          _didFireNonTap = true;
          _config.onLongPress?.call(GesturePoint(_startX!, _startY!));
        }
      },
    );
  }

  void onPointerMove(double x, double y) {
    if (_startX == null) return;

    final dx = (x - _startX!).abs();
    final dy = (y - _startY!).abs();
    if (dx > _kTouchSlop || dy > _kTouchSlop) {
      _moved = true;
      _cancelLongPress();
    }
  }

  void onPointerUp(double x, double y) {
    _cancelLongPress();
    if (_startX == null || _startTime == null) return;

    final endTime = clock.now().millisecondsSinceEpoch;
    final duration = endTime - _startTime!;
    final dx = x - _startX!;
    final dy = y - _startY!;
    final distance = sqrt(dx * dx + dy * dy);
    final velocity = duration > 0 ? distance / duration : 0.0;

    if (_longPressFired) {
      _reset();
      return;
    }

    if (distance >= _kSwipeThresholdDistance &&
        velocity >= _kSwipeThresholdVelocity) {
      _didFireNonTap = true;
      _config.onSwipe?.call(SwipeData(
        start: GesturePoint(_startX!, _startY!),
        end: GesturePoint(x, y),
      ));
      _lastTapPoint = null;
      _lastTapTime = null;
    } else if (!_moved) {
      final now = endTime;
      if (_lastTapPoint != null &&
          _lastTapTime != null &&
          (now - _lastTapTime!) < _kDoubleTapDelayMs &&
          (x - _lastTapPoint!.x).abs() < _kTouchSlop * 2 &&
          (y - _lastTapPoint!.y).abs() < _kTouchSlop * 2) {
        _cancelPendingSingleTap();
        _config.onDoubleTap?.call(GesturePoint(x, y));
        _lastTapPoint = null;
        _lastTapTime = null;
      } else {
        _flushPendingSingleTap();
        _lastTapPoint = GesturePoint(x, y);
        _lastTapTime = now;
        _pendingSingleTapPoint = GesturePoint(x, y);
        _pendingSingleTapTimer = Timer(
          const Duration(milliseconds: _kDoubleTapDelayMs),
          _flushPendingSingleTap,
        );
      }
    }

    _reset();
  }

  void _cancelLongPress() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  /// Fires the pending single-tap `onTouch` immediately and clears the
  /// timer. Called when a new (non-double-tap) tap arrives or on disposal
  /// so buffered events are never silently dropped.
  void _flushPendingSingleTap() {
    _pendingSingleTapTimer?.cancel();
    _pendingSingleTapTimer = null;
    final point = _pendingSingleTapPoint;
    _pendingSingleTapPoint = null;
    if (point != null) {
      _config.onTouch?.call(point);
    }
  }

  /// Cancels a pending single-tap without firing the callback. Used when
  /// a double-tap is confirmed — the first tap should not emit `onTouch`.
  void _cancelPendingSingleTap() {
    _pendingSingleTapTimer?.cancel();
    _pendingSingleTapTimer = null;
    _pendingSingleTapPoint = null;
  }

  void _reset() {
    _startX = null;
    _startY = null;
    _startTime = null;
    _moved = false;
    _longPressFired = false;
  }

  void dispose() {
    _cancelLongPress();
    _flushPendingSingleTap();
    _reset();
  }
}
