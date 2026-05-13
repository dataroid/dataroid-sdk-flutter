import 'package:flutter/material.dart';

class WidgetInfo {
  final String className;
  final String? label;
  final String? accessibilityLabel;
  final String? componentId;
  final String? placeholder;
  final bool? isChecked;
  final String? groupName;
  final String? elementName;
  final String? elementType;

  /// `true` when the resolved widget is a password-style text input. Mirrors
  /// the `containsSensitiveInformation` heuristic on the Android SDK and
  /// `dtr_isSecureText` on the iOS SDK: triggered by `obscureText: true`
  /// or `keyboardType: TextInputType.visiblePassword`. Used by the
  /// auto-capture runtime to suppress the actual text value and the
  /// placeholder from `collectTextChange` payloads.
  final bool isSensitive;

  final WidgetInteractionType interactionType;

  const WidgetInfo({
    required this.className,
    this.label,
    this.accessibilityLabel,
    this.componentId,
    this.placeholder,
    this.isChecked,
    this.groupName,
    this.elementName,
    this.elementType,
    this.isSensitive = false,
    required this.interactionType,
  });
}

enum WidgetInteractionType {
  button,
  textInput,
  toggle,
  radio,
  unknown,
}

class _AccessibilityInfo {
  String? label;
  String? accessibilityLabel;
  String? componentId;
}

class _ToggleClassification {
  final String className;
  final bool isChecked;
  const _ToggleClassification(this.className, this.isChecked);
}

class _RadioClassification {
  final String className;
  const _RadioClassification(this.className);
}

class DataroidWidgetIdentifier {
  /// Widget runtime types to skip during identification.
  ///
  /// Matched against `widget.runtimeType.toString()`, so this only works in
  /// non-obfuscated Flutter builds. Builds compiled with `--obfuscate` mangle
  /// runtime type names and silently bypass this filter.
  final List<String> ignoredWidgets;

  /// Component IDs to skip during identification.
  ///
  /// Matched against the widget's `ValueKey<String>` value and any ancestor
  /// `Semantics.identifier`. Unlike [ignoredWidgets], this survives
  /// obfuscated builds because keys and semantics identifiers are
  /// user-supplied strings, not compiler-generated type names.
  final List<String> ignoredComponentIds;

  const DataroidWidgetIdentifier({
    this.ignoredWidgets = const [],
    this.ignoredComponentIds = const [],
  });

  WidgetInfo? identify(Element element) {
    final widget = element.widget;
    final widgetType = widget.runtimeType.toString();

    if (ignoredWidgets.contains(widgetType)) {
      return null;
    }

    final interactionType = _classifyWidget(widget);

    if (interactionType == WidgetInteractionType.button) {
      final reclassified = _findRadioAncestor(element) ??
          _findToggleAncestor(element) ??
          _findTextInputAncestor(element);
      if (reclassified != null) {
        if (_isIgnoredComponentId(reclassified.componentId)) {
          return null;
        }
        return reclassified;
      }
    }

    if (interactionType == WidgetInteractionType.radio) {
      final reclassified = _findRadioAncestor(element);
      if (reclassified != null) {
        if (_isIgnoredComponentId(reclassified.componentId)) {
          return null;
        }
        return reclassified;
      }
    }

    if (interactionType == WidgetInteractionType.unknown) {
      return null;
    }

    final a11y = _extractAccessibilityInfo(element, widget);

    if (_isIgnoredComponentId(a11y.componentId)) {
      return null;
    }

    a11y.label ??= _extractTextContent(element);

    return _buildWidgetInfo(
      widgetType,
      interactionType,
      widget,
      element,
      a11y,
    );
  }

  _AccessibilityInfo _extractAccessibilityInfo(Element element, Widget widget) {
    final info = _AccessibilityInfo();
    info.componentId = _extractComponentId(widget);

    element.visitAncestorElements((ancestor) {
      if (ancestor.widget is Semantics) {
        final semantics = ancestor.widget as Semantics;
        info.accessibilityLabel ??= semantics.properties.label;
        info.componentId ??= semantics.properties.identifier;
        if (info.accessibilityLabel != null &&
            info.accessibilityLabel!.isNotEmpty) {
          info.label = info.accessibilityLabel;
          return false;
        }
      }
      if (ancestor.widget is Tooltip) {
        info.label = (ancestor.widget as Tooltip).message;
        return false;
      }
      return true;
    });

    return info;
  }

  WidgetInfo _buildWidgetInfo(
    String className,
    WidgetInteractionType interactionType,
    Widget widget,
    Element element,
    _AccessibilityInfo a11y,
  ) {
    String? placeholder;
    bool? isChecked;
    String? elementType;
    bool isSensitive = false;

    if (interactionType == WidgetInteractionType.textInput) {
      placeholder = _extractPlaceholder(widget, element);
      isSensitive = _isSensitiveTextField(widget, element);
    } else if (interactionType == WidgetInteractionType.toggle) {
      isChecked = _extractToggleState(widget);
    } else if (interactionType == WidgetInteractionType.radio) {
      elementType = 'radio';
    }

    return WidgetInfo(
      className: className,
      label: a11y.label,
      accessibilityLabel: a11y.accessibilityLabel,
      componentId: a11y.componentId,
      placeholder: placeholder,
      isChecked: isChecked,
      elementType: elementType,
      isSensitive: isSensitive,
      interactionType: interactionType,
    );
  }

  bool _isIgnoredComponentId(String? componentId) {
    return componentId != null && ignoredComponentIds.contains(componentId);
  }

  static String? _extractComponentId(Widget widget) {
    if (widget.key is ValueKey<String>) {
      return (widget.key as ValueKey<String>).value;
    }
    // Other ValueKey<T> types (`ValueKey<int>(42)` etc.) stringify with
    // Flutter's internal decoration (e.g. `[<42>]`), which would ship as
    // an opaque componentId to analytics. Skip them rather than forward
    // an implementation-detail-shaped string; integrators who need stable
    // ids should use `ValueKey<String>` or `Semantics.identifier`.
    return null;
  }

  WidgetInteractionType _classifyWidget(Widget widget) {
    if (widget is ElevatedButton ||
        widget is TextButton ||
        widget is OutlinedButton ||
        widget is IconButton ||
        widget is FloatingActionButton ||
        widget is InkWell ||
        widget is GestureDetector ||
        widget is PopupMenuButton ||
        widget is DropdownButton ||
        widget is BackButton ||
        widget is CloseButton) {
      return WidgetInteractionType.button;
    }
    if (widget is TextField ||
        widget is TextFormField ||
        widget is EditableText) {
      return WidgetInteractionType.textInput;
    }
    if (widget is Switch || widget is Checkbox) {
      return WidgetInteractionType.toggle;
    }
    if (widget is Radio) {
      return WidgetInteractionType.radio;
    }
    return WidgetInteractionType.unknown;
  }

  static _ToggleClassification? _classifyAsToggle(Widget w) {
    // Toggle dispatch fires from `pointer-down`, before Flutter's gesture
    // arena commits the state change. Reading `widget.value` here would
    // capture the pre-tap value, which analytics consumers naturally
    // misread as "the toggle is now in this state". Derive the expected
    // post-tap value instead so events report the new state the user
    // intended (`Switch`/`Checkbox`: flipped).
    if (w is SwitchListTile) {
      return _ToggleClassification('SwitchListTile', !w.value);
    }
    if (w is CheckboxListTile) {
      return _ToggleClassification('CheckboxListTile', !(w.value ?? false));
    }
    if (w is Switch) {
      return _ToggleClassification('Switch', !w.value);
    }
    if (w is Checkbox) {
      return _ToggleClassification('Checkbox', !(w.value ?? false));
    }
    return null;
  }

  static _RadioClassification? _classifyAsRadio(Widget w) {
    if (w is RadioListTile) {
      return const _RadioClassification('RadioListTile');
    }
    if (w is Radio) {
      return const _RadioClassification('Radio');
    }
    return null;
  }

  _AccessibilityInfo _extractSemanticsInfo(Element ancestor, Widget widget) {
    final info = _AccessibilityInfo();
    info.componentId = _extractComponentId(widget);
    info.label = _extractTextContent(ancestor);

    ancestor.visitAncestorElements((upper) {
      if (upper.widget is Semantics) {
        final semantics = upper.widget as Semantics;
        info.accessibilityLabel ??= semantics.properties.label;
        info.componentId ??= semantics.properties.identifier;
        if (info.accessibilityLabel != null &&
            info.accessibilityLabel!.isNotEmpty) {
          info.label ??= info.accessibilityLabel;
          return false;
        }
      }
      return true;
    });

    return info;
  }

  WidgetInfo? _findToggleAncestor(Element startElement) {
    WidgetInfo? result;

    startElement.visitAncestorElements((ancestor) {
      final w = ancestor.widget;
      final toggle = _classifyAsToggle(w);

      if (toggle != null) {
        final a11y = _extractSemanticsInfo(ancestor, w);
        result = WidgetInfo(
          className: toggle.className,
          label: a11y.label,
          accessibilityLabel: a11y.accessibilityLabel,
          componentId: a11y.componentId,
          isChecked: toggle.isChecked,
          interactionType: WidgetInteractionType.toggle,
        );
        return false;
      }

      if (w is Scaffold || w is Navigator) {
        return false;
      }
      return true;
    });

    return result;
  }

  WidgetInfo? _findRadioAncestor(Element startElement) {
    WidgetInfo? result;

    startElement.visitAncestorElements((ancestor) {
      final w = ancestor.widget;
      final radio = _classifyAsRadio(w);

      if (radio != null) {
        final a11y = _extractSemanticsInfo(ancestor, w);
        result = WidgetInfo(
          className: radio.className,
          label: a11y.label,
          accessibilityLabel: a11y.accessibilityLabel,
          componentId: a11y.componentId,
          elementType: 'radio',
          interactionType: WidgetInteractionType.radio,
        );
        return false;
      }

      if (w is Scaffold || w is Navigator) {
        return false;
      }
      return true;
    });

    return result;
  }

  WidgetInfo? _findTextInputAncestor(Element startElement) {
    WidgetInfo? result;

    startElement.visitAncestorElements((ancestor) {
      final w = ancestor.widget;

      if (w is TextField || w is TextFormField) {
        final a11y = _extractSemanticsInfo(ancestor, w);
        result = WidgetInfo(
          className: w.runtimeType.toString(),
          label: a11y.label,
          accessibilityLabel: a11y.accessibilityLabel,
          componentId: a11y.componentId,
          placeholder: _extractPlaceholder(w, ancestor),
          isSensitive: _isSensitiveTextField(w, ancestor),
          interactionType: WidgetInteractionType.textInput,
        );
        return false;
      }

      if (w is Scaffold || w is Navigator) {
        return false;
      }
      return true;
    });

    return result;
  }

  String? _extractPlaceholder(Widget widget, [Element? element]) {
    if (widget is TextField) {
      return widget.decoration?.hintText;
    }
    if (widget is TextFormField && element != null) {
      // TextFormField forwards its decoration to an internal TextField via
      // its builder. The outer widget itself does not expose the decoration,
      // so walk down one level to read the hintText off the rendered TextField.
      String? hint;
      void visit(Element child) {
        if (hint != null) return;
        final w = child.widget;
        if (w is TextField) {
          hint = w.decoration?.hintText;
          return;
        }
        child.visitChildElements(visit);
      }

      element.visitChildElements(visit);
      return hint;
    }
    return null;
  }

  /// Mirrors Android (`ComponentController.containsSensitiveInformation`,
  /// password input-type variations) and iOS (`UITextField.isSecureTextEntry`):
  /// any text field that obscures input or declares a visible-password
  /// keyboard is treated as sensitive. The auto-capture runtime then drops
  /// `textValue` and `placeholder` from the emitted event so credentials and
  /// other private data never leave the device.
  bool _isSensitiveTextField(Widget widget, Element? element) {
    if (widget is TextField) {
      return widget.obscureText ||
          widget.keyboardType == TextInputType.visiblePassword;
    }
    if (widget is EditableText) {
      return widget.obscureText;
    }
    if (widget is TextFormField && element != null) {
      // TextFormField captures `obscureText` and `keyboardType` in its
      // constructor and forwards them into the inner TextField/EditableText
      // it builds. Read them off the rendered descendants instead.
      bool sensitive = false;
      void visit(Element child) {
        if (sensitive) return;
        final w = child.widget;
        if (w is TextField) {
          sensitive =
              w.obscureText || w.keyboardType == TextInputType.visiblePassword;
          return;
        }
        if (w is EditableText) {
          sensitive = w.obscureText;
          return;
        }
        child.visitChildElements(visit);
      }

      element.visitChildElements(visit);
      return sensitive;
    }
    return false;
  }

  /// See `_classifyAsToggle` for rationale: the dispatch fires before
  /// Flutter commits the tap, so we report the expected post-tap value
  /// (the new state the user intended) rather than the pre-tap value.
  bool? _extractToggleState(Widget widget) {
    if (widget is Switch) {
      return !widget.value;
    }
    if (widget is Checkbox) {
      return !(widget.value ?? false);
    }
    return null;
  }

  /// Maximum descent depth into the widget subtree when looking for a `Text`.
  /// Bounded so a deeply-nested layout cannot blow the call stack on every
  /// pointer-down event. Material widgets (`ElevatedButton`, `ListTile`,
  /// etc.) wrap their child in many builder + theme layers, so the bound is
  /// deliberately generous; the primary guard against runaway payload size
  /// is the per-string length cap below.
  static const int _kMaxTextDepth = 100;

  /// Maximum length of an extracted label. Anything longer is truncated so a
  /// pathological `Text` value cannot ship multi-KB strings to analytics.
  static const int _kMaxTextLength = 200;

  String? _extractTextContent(Element element, {int depth = 0}) {
    if (depth >= _kMaxTextDepth) {
      return null;
    }
    String? text;
    element.visitChildElements((child) {
      if (text != null) {
        return;
      }
      if (child.widget is Text) {
        final data = (child.widget as Text).data;
        if (data != null && data.isNotEmpty) {
          text = data.length > _kMaxTextLength
              ? data.substring(0, _kMaxTextLength)
              : data;
        }
      } else {
        final inner = _extractTextContent(child, depth: depth + 1);
        if (inner != null) {
          text = inner;
        }
      }
    });
    return text;
  }
}
