# Unity UN202 multimeter stand

A rigid, single-piece kickstand for the Unity UN202 clamp multimeter. It
clips onto the existing case screw on the back (no need to remove the
screw) via a keyhole slot, while the meter's bottom edge rests on the
table. Because the geometry is fixed, the meter can't lean back past the
angle set in `tilt_angle` — it's a hard limit, not an adjustable hinge.

Open `stand.scad` in OpenSCAD to preview/edit, or render an STL with:

```
openscad --render -o stand.stl stand.scad
```

## Before printing: verify these assumptions

Several numbers were estimated, not measured, because they were hard to
pin down without disassembling the meter or taking calipers to it. All
of them live in the "ADJUST" sections at the top of `stand.scad`.
Change a value, re-render, reprint the small clip end if needed — the
part is cheap to iterate.

- `screw_height_from_bottom` (35mm default): distance from the meter's
  bottom edge, measured along the back, up to the screw center. This is
  a guess and directly controls the leg length / how the whole stand
  sits. **Measure this on the real meter.**
- `shank_d` (3mm default): diameter of the screw shank right under the
  head. Only the head diameter (5.1mm) was actually measured.
- `hook_ceiling` (0.8mm default): thickness of the thin plastic wall
  that traps the screw head. If the bracket won't slide on, thin this
  down; if it doesn't grip / feels loose, thicken it slightly.
- `pocket_dia` / `pocket_depth` (9mm / 4.5mm): the case has a curved,
  raised area (~4mm wide, ~3mm tall) surrounding the screw hole. These
  are cut as an oversized flat-bottomed relief pocket so the clip
  plate sits flush without needing the exact profile — but "oversized"
  is still a guess. If the plate rocks on the case, enlarge these.

## How it fits together

- The screw head drops through a wide entry hole, then the bracket
  slides down so the shank seats in a narrower slot — a standard
  keyhole mount. The screw is never removed.
- A flat-bottomed pocket on the mating face clears the raised
  boss/curve around the screw hole.
- A wide foot (46 x 24mm) sits flat on the table for tip resistance
  while handling things one-handed.

## Printing notes

- No supports needed if the foot is printed flat on the bed (the
  design is built directly in its "in use" orientation, which happens
  to already sit flat-side-down).
- PLA or PETG both fine; this only carries the meter's weight, not
  ongoing dynamic load.
