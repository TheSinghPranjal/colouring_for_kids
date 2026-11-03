import 'dart:math' as math;
import 'dart:ui';

import '../../models/coloring_region.dart';
import '../../models/coloring_template.dart';

/// Finds which fillable region a template-space point belongs to.
///
/// 1. Exact containment, checked front-to-back (highest z first). Regions are
///    a planar partition, so at most one normally matches; z-order only
///    breaks ties on a shared boundary, deterministically.
/// 2. If the point is on the outer side of an outline (e.g. a finger lands
///    on the black line around the picture), nearby points within
///    [tolerance] are sampled. The region covering the most samples wins
///    (ties: higher z). Tolerance only ever *recovers* a near miss; a point
///    that is clearly inside a region is never reassigned to a neighbour, and
///    nothing further away than [tolerance] can be selected.
class RegionHitTester {
  RegionHitTester(this.template) : _frontToBack = template.fillableRegions.toList().reversed.toList();

  final ColoringTemplate template;
  final List<ColoringRegion> _frontToBack;

  static const int _samplesPerRing = 12;

  ColoringRegion? regionAt(Offset p, {double tolerance = 0}) {
    final exact = _containing(p);
    if (exact != null) return exact;
    if (tolerance <= 0) return null;
    if (!template.viewBox.inflate(tolerance).contains(p)) return null;

    final votes = <ColoringRegion, int>{};
    for (final ringRadius in [tolerance * 0.5, tolerance]) {
      for (var i = 0; i < _samplesPerRing; i++) {
        final a = 2 * math.pi * i / _samplesPerRing;
        final sample = p + Offset(math.cos(a), math.sin(a)) * ringRadius;
        final hit = _containing(sample);
        if (hit != null) votes[hit] = (votes[hit] ?? 0) + 1;
      }
    }
    if (votes.isEmpty) return null;
    ColoringRegion? best;
    var bestVotes = 0;
    for (final r in _frontToBack) {
      final v = votes[r] ?? 0;
      if (v > bestVotes) {
        best = r;
        bestVotes = v;
      }
    }
    return best;
  }

  ColoringRegion? _containing(Offset p) {
    for (final r in _frontToBack) {
      if (r.contains(p)) return r;
    }
    return null;
  }
}
