import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:veto/data/enums/view_model_state.dart';

part '../../widgets/ake_view_model_builder.dart';

/// Base view model class.
abstract class AkeBaseViewModel<E extends Object?> {
  /// Holds arguments of type [E] provided by the [ViewModelBuilder._argumentBuilder].
  late final E? arguments;

  /// Callback that is used by [rebuild] to rebuild the widgets inside the parent [ViewModelBuilder].
  late Function(VoidCallback fn)? _rebuild;

  /// Callback that is used by [isMounted] to check whether the parent [ViewModelBuilder] is mounted.
  late bool Function()? _mounted;

  /// Whether the parent [ViewModelBuilder] is mounted.
  bool get isMounted => _mounted?.call() ?? false;

  /// Provides non-leaking access to the [context].
  late DisposableBuildContext? _disposableBuildContext;

  /// Underlying notifier that sets whether the [AkeBaseViewModel] has been initialised.
  final ValueNotifier<bool> _isInitialisedNotifier = ValueNotifier(false);

  /// Listenable that listens to whether the [AkeBaseViewModel] has been initialised.
  ValueListenable<bool> get isInitialisedListenable => _isInitialisedNotifier;

  /// Used to fetch whether the [AkeBaseViewModel] has been initialised.
  bool get isInitialised => _isInitialisedNotifier.value;

  /// Underlying notifier that sets whether the [AkeBaseViewModel] is busy.
  late final ValueNotifier<bool> _isBusyNotifier = ValueNotifier(false);

  /// Listenable that listens to whether the [AkeBaseViewModel] is busy.
  ValueListenable<bool> get isBusyListenable => _isBusyNotifier;

  /// Used to fetch whether the [AkeBaseViewModel] is busy.
  bool get isBusy => _isBusyNotifier.value;

  /// Used to indicate whether the [AkeBaseViewModel] has an error.
  late final ValueNotifier<bool> _hasErrorNotifier = ValueNotifier(false);

  /// Listenable that listens to whether the [AkeBaseViewModel] has an error.
  ValueListenable<bool> get hasErrorListenable => _hasErrorNotifier;

  /// Used to fetch whether the [AkeBaseViewModel] is has an error.
  bool get hasError => _hasErrorNotifier.value;

  /// Underlying notifier that sets the current [ViewModelState] of the [AkeBaseViewModel].
  final ValueNotifier<ViewModelState> _stateNotifier =
      ValueNotifier(ViewModelState.isInitialising);

  /// Listenable that listens to the current [ViewModelState] of the [AkeBaseViewModel].
  ValueListenable<ViewModelState> get stateListenable => _stateNotifier;

  /// Used to fetch the current [ViewModelState] of the [AkeBaseViewModel].
  ViewModelState get state => _stateNotifier.value;

  /// Used to perform any initialising logic for the [AkeBaseViewModel].
  ///
  /// This method is called in the [ViewModelBuilderState.initState] method and sets the
  /// [_isInitialisedNotifier] and thus the [isInitialisedListenable] and [isInitialised] to true.
  @mustCallSuper
  initialise() {
    _isInitialisedNotifier.value = true;
    _stateNotifier.value = ViewModelState.isInitialised;
  }

  /// Used to perform any disposing logic for the [AkeBaseViewModel].
  ///
  /// This method is called in the [ViewModelBuilderState.initState] method.
  void dispose() {
    _disposableBuildContext!.dispose();
    _disposableBuildContext = null;
    _mounted = null;
    _rebuild = null;
  }

  /// Used to notify whether the [AkeBaseViewModel] has an error.
  ///
  /// This method sets the [_isBusyNotifier] and thus the [isBusyListenable] and
  /// [AkeBaseViewModel.isBusy] to true.
  void setError(bool hasError) {
    _hasErrorNotifier.value = hasError;
    if (hasError) {
      _stateNotifier.value = ViewModelState.hasError;
    } else {
      _restoreViewModelState();
    }
  }

  /// Used to notify whether the [AkeBaseViewModel] is busy.
  ///
  /// This method sets the [_isBusyNotifier] and thus the [isBusyListenable] and
  /// [AkeBaseViewModel.isBusy] to true.
  void setBusy(bool isBusy) {
    _isBusyNotifier.value = isBusy;
    if (isBusy) {
      if (!_hasErrorNotifier.value || _isInitialisedNotifier.value) {
        _stateNotifier.value = ViewModelState.isBusy;
      }
    } else {
      _restoreViewModelState();
    }
  }

  /// Used to restore the [ViewModelState] value of [_stateNotifier].
  ///
  /// Uses the [_hasErrorNotifier], [_isBusyNotifier] and [_isInitialisedNotifier] as backbone where
  /// showing an error comes before showing busy and showing busy comes before showing initialised.
  void _restoreViewModelState() {
    if (hasError) {
      _stateNotifier.value = ViewModelState.hasError;
    } else if (isBusy) {
      _stateNotifier.value = ViewModelState.isBusy;
    } else {
      if (isInitialised) {
        _stateNotifier.value = ViewModelState.isInitialised;
      } else {
        _stateNotifier.value = ViewModelState.isInitialising;
      }
    }
  }

  /// Used to rebuild the widgets inside the parent [ViewModelBuilder].
  void rebuild() => _rebuild?.call(() {});

  /// Provides the current [ViewModelBuilderState]'s [BuildContext].
  BuildContext? get context => _disposableBuildContext?.context;

  /// Helper method to call a [Future.delayed] with given [milliseconds].
  Future<void> wait(int milliseconds) async =>
      await Future.delayed(Duration(milliseconds: milliseconds));

  /// Helper method to easily perform a [SchedulerBinding.addPostFrameCallback] with given [frameCallback].
  void addPostFrameCallback(FrameCallback frameCallback) =>
      _asNullable(SchedulerBinding.instance)!
          .addPostFrameCallback(frameCallback);

  T? _asNullable<T>(T? value) => value;
}