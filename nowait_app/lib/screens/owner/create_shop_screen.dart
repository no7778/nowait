import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/shop_service.dart';
import '../../services/staff_service.dart';
import '../../services/api_client.dart';
import '../../services/locale_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _openingHoursController = TextEditingController(text: '9:00 AM - 8:00 PM');
  String _selectedCategory = 'Salon';
  int _galleryCount = 0;
  bool _isLoading = false;

  final List<Map<String, TextEditingController>> _services = [];
  final List<TextEditingController> _staffControllers = [];
  final _staffInputController = TextEditingController();
  final _l = LocaleService.instance;

  final _categories = ['Salon', 'Beauty Parlour', 'Hospital/Clinic', 'Garage'];

  @override
  void initState() {
    super.initState();
    _l.addListener(_onLocale);
    _addService();
  }

  void _onLocale() => setState(() {});

  @override
  void dispose() {
    _l.removeListener(_onLocale);
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _openingHoursController.dispose();
    for (final s in _services) {
      s['name']?.dispose();
      s['price']?.dispose();
    }
    for (final c in _staffControllers) {
      c.dispose();
    }
    _staffInputController.dispose();
    super.dispose();
  }

  void _addService() {
    setState(() {
      _services.add({
        'name': TextEditingController(),
        'price': TextEditingController(),
      });
    });
  }

  void _removeService(int index) {
    setState(() {
      _services[index]['name']?.dispose();
      _services[index]['price']?.dispose();
      _services.removeAt(index);
    });
  }

  void _addStaffEntry(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _staffControllers.add(TextEditingController(text: trimmed));
      _staffInputController.clear();
    });
  }

  void _removeStaffEntry(int index) {
    setState(() {
      _staffControllers[index].dispose();
      _staffControllers.removeAt(index);
    });
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty &&
      _cityController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l.tr('fillAllFields'))),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final servicesList = _services
          .where((s) => s['name']!.text.trim().isNotEmpty)
          .map((s) => {
                'name': s['name']!.text.trim(),
                'price': double.tryParse(s['price']!.text) ?? 0.0,
                'duration_minutes': 30,
              })
          .toList();

      final shop = await ShopService.instance.createShop(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        services: servicesList,
      );

      // Add any staff members entered inline
      for (final ctrl in _staffControllers) {
        final staffName = ctrl.text.trim();
        if (staffName.isNotEmpty) {
          try {
            await StaffService.instance.addStaffByName(shop.id, staffName);
          } catch (_) {} // best-effort; don't fail shop creation
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓  ${_nameController.text} has been successfully set up.'),
          backgroundColor: AppColors.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l.tr('somethingWrong'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
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
                      Text(
                        _l.tr('createNewShop'),
                        style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('General Details'),
                        const SizedBox(height: 14),
                        _buildSection([
                          _underlineField(_nameController, 'SHOP NAME', 'e.g. Luxe Cuts Studio'),
                          const SizedBox(height: 16),
                          _categoryDropdown(),
                          const SizedBox(height: 16),
                          _underlineField(_addressController, 'ADDRESS', 'Street, locality'),
                          const SizedBox(height: 16),
                          _underlineField(_cityController, 'CITY', 'Your city', TextCapitalization.words),
                          const SizedBox(height: 16),
                          _underlineField(_openingHoursController, 'OPENING HOURS', '9:00 AM - 8:00 PM'),
                        ]),
                        const SizedBox(height: 24),
                        _sectionTitle('Gallery'),
                        const SizedBox(height: 14),
                        _buildSection([
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: _galleryCount + 1,
                            itemBuilder: (_, i) {
                              if (i == _galleryCount) {
                                return GestureDetector(
                                  onTap: () => setState(() => _galleryCount = (_galleryCount + 1).clamp(0, 8)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.outline.withValues(alpha: 0.3),
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 26),
                                        SizedBox(height: 4),
                                        Text('Add', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary.withValues(alpha: 0.5), AppColors.secondary.withValues(alpha: 0.5)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    const Center(child: Icon(Icons.photo_outlined, color: Colors.white54, size: 28)),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _galleryCount--),
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, color: Colors.white, size: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ]),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _sectionTitle('Services'),
                            const Spacer(),
                            GestureDetector(
                              onTap: _addService,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text('Add', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildSection([
                          ...List.generate(_services.length, (i) => Column(
                            children: [
                              if (i > 0) Divider(color: AppColors.outline.withValues(alpha: 0.2), height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _underlineField(_services[i]['name']!, 'SERVICE NAME', 'e.g. Haircut'),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: _underlineField(
                                      _services[i]['price']!,
                                      'PRICE (₹)',
                                      '0',
                                      TextCapitalization.none,
                                      TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_services.length > 1)
                                    GestureDetector(
                                      onTap: () => _removeService(i),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.errorContainer,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.onErrorContainer),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          )),
                        ]),
                        const SizedBox(height: 24),
                        _sectionTitle('Staff Members'),
                        const SizedBox(height: 6),
                        Text(
                          'Staff names are shown to customers on your shop page.',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 14),
                        _buildSection([
                          // Input row
                          Row(
                            children: [
                              Expanded(
                                child: _underlineField(
                                  _staffInputController,
                                  'STAFF NAME',
                                  'e.g. Rahul',
                                  TextCapitalization.words,
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _addStaffEntry(_staffInputController.text),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient135,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('Add', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                          // Staff chips
                          if (_staffControllers.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(_staffControllers.length, (i) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 22, height: 22,
                                      decoration: BoxDecoration(gradient: AppColors.primaryGradient135, shape: BoxShape.circle),
                                      child: Center(
                                        child: Text(
                                          _staffControllers[i].text.isNotEmpty ? _staffControllers[i].text[0].toUpperCase() : '?',
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(_staffControllers[i].text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _removeStaffEntry(i),
                                      child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              )),
                            ),
                          ],
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sticky button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.surface.withValues(alpha: 0), AppColors.surface, AppColors.surface],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
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
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          ),
                        ),
                      )
                    : GradientButton(
                        label: _l.tr('continueBtn'),
                        onPressed: _submit,
                        icon: Icons.check_circle_outline_rounded,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient135,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadowPrimary, blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _underlineField(
    TextEditingController controller,
    String label,
    String hint, [
    TextCapitalization cap = TextCapitalization.sentences,
    TextInputType keyboard = TextInputType.text,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          textCapitalization: cap,
          keyboardType: keyboard,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
            filled: false,
            border: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outline, width: 0.5)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.4), width: 0.8)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.only(bottom: 6),
          ),
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _categoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY',
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          onChanged: (v) => setState(() => _selectedCategory = v!),
          decoration: InputDecoration(
            filled: false,
            border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.4), width: 0.8)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.4), width: 0.8)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.only(bottom: 6),
          ),
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurface),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        ),
      ],
    );
  }
}
