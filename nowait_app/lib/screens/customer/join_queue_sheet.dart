import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/locale_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import 'shop_details_screen.dart';

class JoinQueueSheet extends StatelessWidget {
  final ShopModel shop;

  const JoinQueueSheet({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final l = LocaleService.instance;
    final yourPosition = shop.queueCount + 1;
    final estimatedWait = shop.avgWaitMinutes + (shop.queueCount * 2);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Shop name
                  Text(
                    shop.name,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.tr('joinQueue'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bento info
                  Row(
                    children: [
                      Expanded(child: _InfoCell(
                        icon: Icons.confirmation_number_outlined,
                        value: '#$yourPosition',
                        label: l.tr('yourPosition'),
                        gradient: true,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCell(
                        icon: Icons.schedule_rounded,
                        value: '~$estimatedWait min',
                        label: l.tr('estimatedWait'),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Live updates card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.tr('liveUpdatesEnabled'),
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                              ),
                              Text(
                                l.tr('liveUpdatesSubtitle'),
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded, color: AppColors.tertiary, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      label: l.tr('confirmJoin'),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ShopDetailsScreen(shop: shop)),
                        );
                      },
                      icon: Icons.check_rounded,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text(
                        l.tr('cancel'),
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool gradient;

  const _InfoCell({required this.icon, required this.value, required this.label, this.gradient = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient ? AppColors.primaryGradient135 : null,
        color: gradient ? null : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColors.shadowPrimary, blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gradient ? Colors.white : AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: gradient ? Colors.white : AppColors.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: gradient ? Colors.white70 : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
