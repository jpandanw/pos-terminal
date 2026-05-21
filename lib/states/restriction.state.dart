import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:signals/signals_flutter.dart';

enum BypassType {
  none,
  byCount,
  byTime,
  bySession,
}

class RestrictionState implements Disposable {
  final bypassType = signal<BypassType>(BypassType.none);
  final remainingCount = signal<int>(0);
  final expiryTime = signal<DateTime?>(null);

  Timer? _timer;

  bool get isAuthorized {
    switch (bypassType.value) {
      case BypassType.none:
        return false;
      case BypassType.byCount:
        return remainingCount.value > 0;
      case BypassType.byTime:
        if (expiryTime.value == null) return false;
        final now = DateTime.now();
        if (now.isBefore(expiryTime.value!)) {
          return true;
        } else {
          // Time expired, reset
          _reset();
          return false;
        }
      case BypassType.bySession:
        return true;
    }
  }

  void _reset() {
    bypassType.value = BypassType.none;
    remainingCount.value = 0;
    expiryTime.value = null;
    _timer?.cancel();
    _timer = null;
  }

  void useAuthorization() {
    if (bypassType.value == BypassType.byCount) {
      remainingCount.value--;
      if (remainingCount.value <= 0) {
        _reset();
      }
    }
  }

  void authorizeByCount(int count) {
    bypassType.value = BypassType.byCount;
    remainingCount.value = count;
    expiryTime.value = null;
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (bypassType.value == BypassType.byTime) {
        if (expiryTime.value != null && DateTime.now().isAfter(expiryTime.value!)) {
          _reset();
        } else {
          // Force signal notification to trigger UI updates in real-time
          expiryTime.set(expiryTime.value, force: true);
        }
      } else {
        timer.cancel();
      }
    });
  }

  void authorizeByTime(Duration duration) {
    bypassType.value = BypassType.byTime;
    expiryTime.value = DateTime.now().add(duration);
    remainingCount.value = 0;
    _startTimer();
  }

  void authorizeBySession() {
    bypassType.value = BypassType.bySession;
    remainingCount.value = 0;
    expiryTime.value = null;
    _timer?.cancel();
    _timer = null;
  }

  void clearBypass() {
    _reset();
  }

  String get statusText {
    switch (bypassType.value) {
      case BypassType.none:
        return "Restricted Mode";
      case BypassType.byCount:
        return "Bypassed (${remainingCount.value} operations left)";
      case BypassType.byTime:
        if (expiryTime.value == null) return "Bypassed";
        final diff = expiryTime.value!.difference(DateTime.now());
        if (diff.isNegative) return "Restricted Mode";
        final mins = diff.inMinutes;
        final secs = diff.inSeconds % 60;
        return "Bypassed (${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} left)";
      case BypassType.bySession:
        return "Bypassed (Session)";
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    bypassType.dispose();
    remainingCount.dispose();
    expiryTime.dispose();
  }
}

final restrictionStateRef = Ref.scoped((context) => RestrictionState());
