import 'context_trigger_result.dart';

/// Interface for listening to Context Trigger events
abstract class ContextTriggerListener {
  /// Called when a context trigger condition is met
  void onContextTriggered(ContextTriggerResult result);
} 