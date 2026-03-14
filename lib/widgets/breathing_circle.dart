import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Animates a circle that expands (inhale) and contracts (exhale) according to [inhaleSec] and [exhaleSec].
class BreathingCircle extends StatefulWidget {
  final int inhaleSec;
  final int exhaleSec;
  final bool paused;
  final VoidCallback? onPhaseChange;
  final void Function(bool isInhale)? onBreathPhase;

  const BreathingCircle({
    super.key,
    required this.inhaleSec,
    required this.exhaleSec,
    this.paused = false,
    this.onPhaseChange,
    this.onBreathPhase,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isInhale = true;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.inhaleSec),
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _startCycle();
  }

  void _startCycle() {
    if (widget.paused) return;
    _isInhale = true;
    widget.onBreathPhase?.call(true);
    _controller.duration = Duration(seconds: widget.inhaleSec);
    _controller.forward(from: 0).then((_) {
      if (!mounted || widget.paused) return;
      _isInhale = false;
      widget.onBreathPhase?.call(false);
      widget.onPhaseChange?.call();
      _controller.duration = Duration(seconds: widget.exhaleSec);
      _controller.reverse(from: 1.0).then((_) {
        if (mounted) _startCycle();
      });
    });
  }

  @override
  void didUpdateWidget(BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paused) {
      _controller.stop();
    } else if (oldWidget.paused && !widget.paused) {
      _startCycle();
    } else if (oldWidget.inhaleSec != widget.inhaleSec || oldWidget.exhaleSec != widget.exhaleSec) {
      _controller.stop();
      _controller.duration = Duration(seconds: widget.inhaleSec);
      _startCycle();
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Center(
          child: Container(
            width: 200,
            height: 200,
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: _animation.value,
              heightFactor: _animation.value,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D5A4A).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A box that sizes itself as a fraction of the parent (used for scaling the circle).
class FractionallySizedBox extends StatelessWidget {
  final double widthFactor;
  final double heightFactor;
  final Widget child;

  const FractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.heightFactor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth * widthFactor,
          height: constraints.maxHeight * heightFactor,
          child: child,
        );
      },
    );
  }
}
