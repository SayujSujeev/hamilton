import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'get_started_primary_button.dart';

/// Returned when the user confirms tyre choice on the sheet.
class TyreBrandSelectionResult {
  const TyreBrandSelectionResult({
    required this.brandName,
    required this.quantity,
    required this.unitPrice,
  });

  final String brandName;
  final int quantity;
  final double unitPrice;

  double get lineTotal => quantity * unitPrice;
}

class _TyreBrand {
  const _TyreBrand({required this.name, required this.price});

  final String name;
  final double price;
}

Future<TyreBrandSelectionResult?> showSelectTyreBrandSheet(
    BuildContext context) {
  return showModalBottomSheet<TyreBrandSelectionResult?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (sheetContext) => const _SelectTyreBrandSheetBody(),
  );
}

class _SelectTyreBrandSheetBody extends StatefulWidget {
  const _SelectTyreBrandSheetBody();

  @override
  State<_SelectTyreBrandSheetBody> createState() =>
      _SelectTyreBrandSheetBodyState();
}

class _SelectTyreBrandSheetBodyState extends State<_SelectTyreBrandSheetBody> {
  static const List<_TyreBrand> _brands = [
    _TyreBrand(name: 'MICHELIN PRIMACY 4', price: 280),
    _TyreBrand(name: 'BRIDGESTONE TURANZA', price: 280),
    _TyreBrand(name: 'CONTINENTAL PREMIUM CONTACT', price: 280),
  ];

  int? _selectedIndex;
  final List<int> _qty = List<int>.filled(3, 0);

  bool get _canSubmit =>
      _selectedIndex != null && _qty[_selectedIndex!] > 0;

  void _selectBrand(int i) {
    setState(() {
      if (_selectedIndex != i) {
        for (var j = 0; j < _qty.length; j++) {
          if (j != i) _qty[j] = 0;
        }
      }
      _selectedIndex = i;
    });
  }

  void _increment(int i) {
    setState(() {
      _selectedIndex = i;
      for (var j = 0; j < _qty.length; j++) {
        if (j != i) _qty[j] = 0;
      }
      _qty[i]++;
    });
  }

  void _decrement(int i) {
    if (_qty[i] <= 0) return;
    setState(() {
      _qty[i]--;
      if (_qty[i] == 0) _selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Select Tyre Brand',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSerifText(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1B1B1B),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 22),
                ...List.generate(_brands.length, (i) {
                  final b = _brands[i];
                  final selected = _selectedIndex == i;
                  final q = _qty[i];
                  return Padding(
                    padding: EdgeInsets.only(bottom: i == _brands.length - 1 ? 0 : 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _selectBrand(i),
                          behavior: HitTestBehavior.opaque,
                          child: _TyreRadio(selected: selected),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectBrand(i),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.name,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                    color: const Color(0xFF2A2A2A),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Q ${b.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF08A34D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _QtyPill(
                          quantity: q,
                          onMinus: () => _decrement(i),
                          onPlus: () => _increment(i),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: _canSubmit
                      ? GetStartedPrimaryButton(
                          width: double.infinity,
                          height: 52,
                          label: 'Add Tyres to Service',
                          onPressed: () {
                            final i = _selectedIndex!;
                            final brand = _brands[i];
                            Navigator.of(context).pop(
                              TyreBrandSelectionResult(
                                brandName: brand.name,
                                quantity: _qty[i],
                                unitPrice: brand.price,
                              ),
                            );
                          },
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFBDBDBD),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Text(
                              'Add Tyres to Service',
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TyreRadio extends StatelessWidget {
  const _TyreRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF08A34D) : Colors.transparent,
        border: Border.all(
          color: selected ? const Color(0xFF08A34D) : const Color(0xFFB8B8B8),
          width: 1.6,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _QtyPill extends StatelessWidget {
  const _QtyPill({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyIcon(label: '−', onTap: onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
          ),
          _QtyIcon(label: '+', onTap: onPlus),
        ],
      ),
    );
  }
}

class _QtyIcon extends StatelessWidget {
  const _QtyIcon({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3D3D3D),
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
