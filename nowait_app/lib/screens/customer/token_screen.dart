import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/queue_service.dart';
import '../../services/api_client.dart';
import '../../services/locale_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class TokenScreen extends StatefulWidget {
  final ShopModel shop;
  final String token;
  final int position;
  final int estimatedWait;
  final String entryId;

  const TokenScreen({
    super.key,
    required this.shop,
    required this.token,
    required this.position,
    required this.estimatedWait,
    required this.entryId,
  });

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late AnimationController _entryController;
  late Animation<double> _pulseAnim;
  late Animation<double> _entryAnim;

  int _peopleAhead = 0;
  final _l = LocaleService.instance;

  @override
  void initState() {
    super.initState();
    _peopleAhead = widget.position - 1;
    _l.addListener(_onLocale);

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _entryAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _l.removeListener(_onLocale);
    _spinController.dispose();
    _pulseController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _onLocale() => setState(() {});

  void _notifyImComing() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_l.tr('shopNotifiedMsg', params: {'shop': widget.shop.name})),
        backgroundColor: AppColors.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _cancelQueue() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _l.tr('leaveQueue'),
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          _l.tr('tokenCancelMsg', params: {'token': widget.token, 'shop': widget.shop.name}),
          style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_l.tr('stay'), style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await QueueService.instance.cancelQueue(widget.entryId);
              } on ApiException catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
                  );
                  return;
                }
              } catch (_) {}
              if (mounted) Navigator.pop(context);
            },
            child: Text(_l.tr('leave'), style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLow,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _l.tr('yourTokenTitle'),
                          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                        ),
                        Text(
                          widget.shop.name,
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  // Live indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _PingDot(),
                        const SizedBox(width: 5),
                        Text(
                          _l.tr('live'),
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    // ── Token circle ────────────────────────────────────────
                    ScaleTransition(
                      scale: _entryAnim,
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _spinController,
                              builder: (context, child) => Transform.rotate(
                                angle: _spinController.value * 2 * pi,
                                child: CustomPaint(
                                  size: const Size(200, 200),
                                  painter: _DashedCirclePainter(),
                                ),
                              ),
                            ),
                            ScaleTransition(
                              scale: _pulseAnim,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient135,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _l.tr('yourToken'),
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.token,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      letterSpacing: -2,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.tertiaryFixed.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _l.tr('positionLabel', params: {'n': '${widget.position}'}),
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.tertiary,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Queue info bento ─────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _StatCell(
                            icon: Icons.people_outline_rounded,
                            value: '$_peopleAhead',
                            suffix: _peopleAhead == 1 ? _l.tr('person') : _l.tr('people'),
                            label: _l.tr('aheadOfYou'),
                            highlight: _peopleAhead <= 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCell(
                            icon: Icons.schedule_rounded,
                            value: '~${widget.estimatedWait}',
                            suffix: _l.tr('mins'),
                            label: _l.tr('estWaitTime'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Now serving ──────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixed.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.how_to_reg_outlined, color: AppColors.tertiary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _l.tr('nowServing'),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.tertiary,
                                  ),
                                ),
                                Text(
                                  'Token #${widget.shop.currentToken.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              _peopleAhead == 0
                                  ? _l.tr('yourTurnMsg')
                                  : _l.tr('moreAhead', params: {'n': '$_peopleAhead'}),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _peopleAhead == 0
                                    ? AppColors.tertiary
                                    : AppColors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Notification reminder ────────────────────────────────
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
                            child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _l.tr('stayNearbyHint'),
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── I'm Coming button ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        label: _l.tr('imComing'),
                        onPressed: _notifyImComing,
                        icon: Icons.directions_walk_rounded,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _cancelQueue,
                        child: Text(
                          _l.tr('cancelQueue'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String suffix;
  final String label;
  final bool highlight;

  const _StatCell({
    required this.icon,
    required this.value,
    required this.suffix,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: highlight ? Border.all(color: AppColors.primary.withValues(alpha: 0.2)) : null,
        boxShadow: [
          BoxShadow(color: AppColors.shadowPrimary, blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const WidgetSpan(child: SizedBox(width: 4)),
                TextSpan(
                  text: suffix,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _PingDot extends StatefulWidget {
  @override
  State<_PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<_PingDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
    _anim = Tween(begin: 0.0, end: 1.0).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (context, child) => Transform.scale(
              scale: 1 + _anim.value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiary.withValues(alpha: 1 - _anim.value),
                ),
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.tertiary),
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 2;
    const dashCount = 20;
    const dashLength = 0.12;
    const gapLength = 0.2;
    const total = dashLength + gapLength;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * total * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength * pi,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
