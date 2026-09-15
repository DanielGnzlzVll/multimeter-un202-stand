# Project instructions: multimeter-un202-stand

## Render and review before every commit

Before committing any change to `stand.scad`, always:

1. Render the change (`openscad --render -o /tmp/check.stl stand.scad`) and confirm
   `Simple: yes` with no manifold warnings.
2. Generate an actual image render of the affected part(s) (isometric view at
   minimum; add a top-down/orthographic or cross-section view if the change is
   hard to judge from an angle) and look at it with the Read tool.
3. For anything involving the hinge (knuckle fingers, the leg's own knuckle,
   or the M3 bore), also re-run the screw-shaft collision check: model the M3
   screw as a solid cylinder along the hinge axis and intersect it with the
   part, confirming an empty result.
4. For anything touching the hinge's moving parts, reason explicitly about
   the leg's actual swept rotation path (it pivots about the Y axis through
   the knuckle, sweeping through the X-Z plane) before adding any fixed
   material near that axis -- material that looks like harmless reinforcement
   from a single static render can still physically block the rotation. A
   past mistake here (a "hinge bridge" meant to stiffen the fingers) sat
   directly in the leg's swept path and broke the hinge entirely, even though
   it looked fine and passed every geometry/collision check that didn't
   account for rotation.
5. Only commit after the render has actually been looked at and confirmed
   correct -- don't commit based on the collision/manifold check alone.

This applies to every step, not just major redesigns.
