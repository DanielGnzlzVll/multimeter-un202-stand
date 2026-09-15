# Unity UN202 multimeter stand

A compact folding kickstand for the Unity UN202 clamp multimeter, using
the existing top case screw (the one just below the jaw) as the mount
point. Three printed parts (pick one of the two base options) plus,
for the screw-based base, one M3 screw and nut:

- **`base_tab()`** — a small, thin tab that slides sideways under the
  *loosened* top case screw (you don't remove it, just back it off a
  couple of turns) and sits flush against the case once retightened.
- **`base_plug()`** — a hardware-free alternative: a peg that presses
  tightly into the screw's recess (~5.6mm) instead of using the screw
  at all. Simpler assembly, but it means pulling the screw out
  permanently and relying on friction alone to hold the peg in place.
- **`leg()`** — attaches to whichever base through a printed knuckle
  hinge, pinned with an M3 screw and nut. This is the part that
  actually folds flat against the meter when stowed and swings out to
  prop it up when deployed. **The M3 nut is the friction adjustment**
  — tighter clamps the knuckles together harder, holding the leg at
  whatever angle you leave it, including flush against the case.

Render/print with:

```
openscad --render -o stand.stl stand.scad
```

All parts are laid out flat side-by-side at the bottom of the file,
ready to print with no supports. Every M3 hinge bore uses a teardrop
profile (circle + a 45° point on top) instead of a plain round hole,
so it prints cleanly with no bridging/support even lying flat with the
bore axis horizontal.

## Why two hinges' worth of thinking, but only one moving joint

The case screw's axis points straight into the case, so anything
pivoting directly on it can only sweep flat across the back (like a
clock hand) — it can't lift away from the surface to prop the meter
up. So the *base* (tab or plug) just anchors a fixed attachment point,
and a **separate** knuckle hinge (axis parallel to the case surface,
pinned by the M3 hardware) is what actually lets the leg fold out.
That second hinge is the only moving joint.

## Leg length math

With the meter resting on its bottom edge and tilted back to
`tilt_angle`, the top screw sits at height `screw_height_from_bottom *
sin(tilt_angle)` above the table. Swinging the leg out from
flush-against-the-case by `deploy_hinge_angle` needs a leg length of:

```
leg_length = screw_height_from_bottom * sin(tilt_angle) / sin(tilt_angle - deploy_hinge_angle)
```

(`deploy_hinge_angle` must stay less than `tilt_angle`, or the leg
never reaches the table no matter how long it is.) All three inputs
are adjustable at the top of `stand.scad`.

## Before printing: verify these assumptions

- `screw_height_from_bottom` (115mm default): distance from the
  meter's bottom edge, along the back, up to the top screw. Estimated
  from product photos, not measured on your actual unit — **measure
  this**, it directly drives the leg length.
- `shank_d` (2.6mm default): diameter of the screw shank under the
  head. Only the head (5.1mm) and the recess it sits in (~5.6mm) were
  actually measured.
- `base_t` (1.6mm default): must be thinner than the gap you actually
  get by loosening the screw a couple of turns. Thin it down if the
  tab won't slide in. (Only matters for `base_tab`.)
- `peg_len` (5mm default) and `peg_interference` (0.15mm default): how
  deep the screw's recess actually is, and how much oversized to print
  the peg for a tight press fit. Both are guesses — start with a test
  print of just `base_plug()` before committing to a full print.
  (Only matters for `base_plug`.)
- `deploy_hinge_angle` (15° default): arbitrary choice balancing leg
  length against how far the leg has to swing out. Adjust and
  re-derive `leg_length` (automatic) if you want a shorter/longer leg.

## Assembly

**With `base_tab` (screw stays in the meter):**
1. Loosen (don't remove) the top case screw a couple of turns.
2. Slide `base_tab` in sideways so the slot captures the shank, then
   retighten the screw to clamp it flush.

**With `base_plug` (no hardware, screw comes out):**
1. Remove the top case screw entirely.
2. Press `base_plug`'s peg firmly into the empty recess until the
   flange seats against the case. Sand the peg slightly if it won't
   go in; it should take real force to remove once seated.

**Both:**
3. Sandwich `leg`'s knuckle between the base's two knuckles, push the
   M3 screw through, add the nut.
4. Tighten the nut until the leg holds its position under the meter's
   weight but you can still reposition it by hand.

## History

`renders/v1-rigid-prototype/` has renders of the very first design
iteration (a rigid, fixed-angle prop) that was replaced by the current
folding-hinge approach — kept for reference only.
