// Formats raw brand / make strings from the API for UI labels (slugs, codes,
// and already-readable names).

String displayBrandNameForUi(String raw) {
  final s = displayMakeNameForUi(raw);
  return s.isEmpty ? '—' : s;
}

String displayMakeNameForUi(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '';

  if (_looksLikeHumanBrandLabel(t)) {
    return t;
  }

  final normalized = t
      .replaceAll('_', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (normalized.isEmpty) return '';

  return normalized
      .split(' ')
      .map(_formatWordForDisplay)
      .join(' ');
}

/// Values that already look display-ready (no slug underscores to expand).
bool _looksLikeHumanBrandLabel(String t) {
  if (t.contains('_')) return false;

  final parts = t.split(RegExp(r'\s+'));
  if (parts.length > 1) {
    // "Volkswagen Group", "Aston Martin"
    return parts.every(
      (p) =>
          p.isEmpty ||
          (p[0].toUpperCase() == p[0] && !RegExp(r'^[a-z]+$').hasMatch(p)),
    );
  }

  final w = parts.single;
  if (w.isEmpty) return false;

  // Needs normalization: all lowercase token ("bmw", "audi")
  if (RegExp(r'^[a-z]+$').hasMatch(w)) return false;

  // Already fine: BMW, Mercedes, McLaren-style
  if (RegExp(r'^[A-Z]+$').hasMatch(w) && w.length <= 5) return true;
  if (RegExp(r'^[A-Z][a-z]+$').hasMatch(w)) return true;

  return false;
}

String _formatWordForDisplay(String word) {
  if (word.isEmpty) return word;

  if (word.contains('-')) {
    return word.split('-').map(_formatWordForDisplay).join('-');
  }

  final lettersOnly = RegExp(r'^[A-Za-z]+$');
  if (!lettersOnly.hasMatch(word)) {
    return word;
  }

  final upper = word.toUpperCase();
  if (word.length <= 5 && word == upper) {
    return upper;
  }

  return word[0].toUpperCase() +
      (word.length > 1 ? word.substring(1).toLowerCase() : '');
}
