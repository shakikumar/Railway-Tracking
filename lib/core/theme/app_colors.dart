import 'package:flutter/material.dart';

/// Centralized Color Tokens for Railway Tracker.
/// Phase 5 / PR 1 Base Palette.
/// Can be customized by team members as design evolves.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand & Structural Tokens
  // ---------------------------------------------------------------------------
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color secondarySlate = Color(0xFF1E293B);
  static const Color tertiarySlate = Color(0xFF334155);
  static const Color brandBlue = Color(0xFF2563EB);
  static const Color brandBlueLight = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // Transit Status Indicators
  // ---------------------------------------------------------------------------
  static const Color statusOnTime = Color(0xFF10B981);
  static const Color statusOnTimeBg = Color(0xFFECFDF5);

  static const Color statusDelayed = Color(0xFFF59E0B);
  static const Color statusDelayedBg = Color(0xFFFFFBEB);

  static const Color statusStopped = Color(0xFFEF4444);
  static const Color statusStoppedBg = Color(0xFFFEF2F2);

  static const Color statusScheduled = Color(0xFF06B6D4);
  static const Color statusScheduledBg = Color(0xFFECFEFF);

  // ---------------------------------------------------------------------------
  // Light Mode Surfaces & Text
  // ---------------------------------------------------------------------------
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------------
  // Dark Mode Surfaces & Text
  // ---------------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF070B14);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkSurfaceElevated = Color(0xFF16213B);
  static const Color darkBorder = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
}
