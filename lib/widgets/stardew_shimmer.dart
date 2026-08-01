import 'package:flutter/material.dart';
import '../theme/stardew_theme.dart';

class StardewShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const StardewShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  State<StardewShimmer> createState() => _StardewShimmerState();
}

class _StardewShimmerState extends State<StardewShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.2 + (_controller.value * 0.4);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                StardewColors.cardBackground,
                StardewColors.iridiumPurple.withValues(alpha: opacity),
                StardewColors.cardBackground,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: StardewColors.cardBorder.withValues(alpha: opacity),
              width: 1,
            ),
          ),
        );
      },
    );
  }
}

class SaveDashboardSkeleton extends StatelessWidget {
  const SaveDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Skeleton
          const StardewShimmer(width: double.infinity, height: 110, borderRadius: 20),
          const SizedBox(height: 24),

          // Partidas Carousel Skeleton
          Row(
            children: const [
              StardewShimmer(width: 220, height: 90, borderRadius: 14),
              SizedBox(width: 12),
              StardewShimmer(width: 220, height: 90, borderRadius: 14),
              SizedBox(width: 12),
              StardewShimmer(width: 220, height: 90, borderRadius: 14),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Grid Skeleton
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: List.generate(4, (_) => const StardewShimmer(width: double.infinity, height: 100, borderRadius: 16)),
          ),
          const SizedBox(height: 24),

          // Overview Cards Skeleton
          Row(
            children: const [
              Expanded(child: StardewShimmer(width: double.infinity, height: 200, borderRadius: 16)),
              SizedBox(width: 16),
              Expanded(child: StardewShimmer(width: double.infinity, height: 200, borderRadius: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
