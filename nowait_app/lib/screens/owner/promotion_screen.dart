import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/promotion_service.dart';
import '../../services/api_client.dart';
import '../../services/locale_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class PromotionScreen extends StatefulWidget {
  final ShopModel shop;

  const PromotionScreen({super.key, required this.shop});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  int _selectedDays = 7;
  bool _isPaid = false;
  bool _isLoading = false;
  final _l = LocaleService.instance;

  @override
  void initState() {
    super.initState();
    _l.addListener(_onLocale);
  }

  @override
  void dispose() {
    _l.removeListener(_onLocale);
    super.dispose();
  }

  void _onLocale() => setState(() {});

  int get _totalCost => _selectedDays * 20;

  void _payAndActivate() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm Payment', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient135,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$_selectedDays days × ₹20/day', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                  Text('₹$_totalCost', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your shop will appear in the Promotions section for $_selectedDays days.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                final validUntil = DateTime.now()
                    .add(Duration(days: _selectedDays))
                    .toUtc()
                    .toIso8601String();
                await PromotionService.instance.createPromotion(
                  widget.shop.id,
                  title: 'Featured Promotion',
                  description: 'Shop promoted for $_selectedDays day${_selectedDays == 1 ? '' : 's'}',
                  validUntil: validUntil,
                );
                if (mounted) {
                  setState(() { _isPaid = true; _isLoading = false; });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓  Promotion activated for $_selectedDays days!'),
                      backgroundColor: AppColors.tertiary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } on ApiException catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
                  );
                }
              } catch (_) {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: Text('Pay ₹$_totalCost', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        title: Text('Promote Shop', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Status
            if (_isPaid || widget.shop.isPromoted) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryFixed.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.tertiary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Promotion is currently active',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.tertiary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Hero
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient135,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.rocket_launch_outlined, color: Colors.white, size: 28),
                  const SizedBox(height: 12),
                  Text(
                    'Boost Your Visibility',
                    style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your shop will appear in the featured Promotions section — the first thing customers see when they open your category.',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Duration selector
            Text(
              'Select Duration',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [1, 3, 7, 14, 30].map((days) {
                final selected = _selectedDays == days;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDays = days),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: selected ? AppColors.primaryGradient135 : null,
                      color: selected ? null : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Colors.transparent : AppColors.outline.withValues(alpha: 0.3),
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$days',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.onSurface,
                          ),
                        ),
                        Text(
                          days == 1 ? 'Day' : 'Days',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: selected ? Colors.white70 : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Cost summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppColors.shadowPrimary, blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Cost', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      Text(
                        '₹$_totalCost',
                        style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rate', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      Text('₹20/day', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                      Text('for $_selectedDays day${_selectedDays == 1 ? '' : 's'}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // Pinned CTA button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient135,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        ),
                      ),
                    )
                  : GradientButton(
                      label: _isPaid || widget.shop.isPromoted ? 'Extend Promotion' : 'Pay & Activate  ₹$_totalCost',
                      onPressed: _payAndActivate,
                      icon: Icons.payment_rounded,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
