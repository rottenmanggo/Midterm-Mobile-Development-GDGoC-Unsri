import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

/// Shimmer-based loading skeleton for the bento grid.
class BentoLoadingIndicator extends StatelessWidget {
  const BentoLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                _shimmerCard(flex: 2, height: 140),
                const SizedBox(width: 12),
                _shimmerCard(flex: 1, height: 140),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _shimmerCard(flex: 1, height: 100),
                const SizedBox(width: 12),
                _shimmerCard(flex: 1, height: 100),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _shimmerCard(flex: 1, height: 160),
                const SizedBox(width: 12),
                _shimmerCard(flex: 2, height: 160),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _shimmerCard(flex: 1, height: 120),
                const SizedBox(width: 12),
                _shimmerCard(flex: 1, height: 120),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerCard({required int flex, required double height}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/// Simple inline shimmer for a single-line placeholder.
class ShimmerLine extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerLine({
    super.key,
    this.width = double.infinity,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
