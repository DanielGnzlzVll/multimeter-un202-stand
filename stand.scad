// ============================================================
// Folding kickstand for Unity UN202 clamp multimeter
//
// One leg + a choice of two base attachments, plus one M3 screw
// and nut for the hinge:
//   1) base_tab()   - slides sideways under the loosened top case
//                     screw, sits flush against the case.
//   2) base_plug()  - alternative, no-hardware attachment: a peg
//                     that presses tightly into the screw's
//                     recess (no screw needed at all).
//   3) leg()        - attaches to whichever base through an M3
//                     bolt hinge (screw + nut = friction pivot).
//                     Folds flat against the case when stowed,
//                     swings out to prop the meter up when
//                     deployed. Tightening the nut sets how much
//                     friction holds whatever angle you leave it.
//
// MOST NUMBERS BELOW ARE ESTIMATES from product photos, not the
// real part. Print, test-fit, and correct the "ADJUST" sections.
// ============================================================

$fn = 48;

// ---------------- ADJUST: real screw/case measurements ----------
screw_head_d     = 5.1;   // measured
shank_d          = 2.6;   // ESTIMATE -- verify against the real screw shank
shank_clearance  = 0.5;
shank_hole_d     = shank_d + shank_clearance;
recess_d         = 5.6;   // measured diameter of the screw's recess/counterbore

// Distance from the meter's bottom edge, along the back, up to the
// TOP screw (below the jaw). Estimated from product photos --
// MEASURE THIS on the real meter, it directly sets the leg length.
screw_height_from_bottom = 115;

// ---------------- ADJUST: desired prop geometry ------------------
tilt_angle         = 60;  // meter's back angle from flat when propped up
deploy_hinge_angle = 15;  // how far the leg swings out (from lying flush
                           // against the case) to reach the table at
                           // tilt_angle. Must stay less than tilt_angle;
                           // smaller = longer leg but hugs the case
                           // closer while folding out.

// Required leg length so swinging the leg out by deploy_hinge_angle
// (from flush-against-the-case) lands the foot on the table with the
// meter resting on its bottom edge at tilt_angle. See README for the
// derivation.
leg_length = screw_height_from_bottom * sin(tilt_angle) / sin(tilt_angle - deploy_hinge_angle);

// ---------------- Base tab (captures under the case screw) -------
base_t = 1.6;  // thickness -- must be thinner than the gap you get by
               // loosening the screw a couple of turns. Only the zone
               // that actually slides under the screw head stays this
               // thin -- see base_thick_t below.
base_l = 11;   // length, insertion edge to hinge knuckles
base_w = 9;    // width of the thin insertion zone

// Past the screw hole, the tab doesn't need to stay thin -- nothing
// there has to slide under the screw head -- so it tapers up to a
// much thicker, wider anchor block for the hinge fingers to embed
// into, the same way base_plug()'s peg tapers into its flange.
base_thick_t = 5;   // thickness at the hinge end
base_thick_w = 14;  // width at the hinge end -- out-spans the fingers
                     // (hinge_span = 18mm) with real margin, instead of
                     // the original 9mm tab the fingers overhung badly

// ---------------- Press-fit base plug (no hardware) ---------------
peg_interference = 0.15;  // print the peg this much OVER recess_d for a
                           // tight press fit; sand down if too tight
peg_d    = recess_d + peg_interference;
peg_len  = 6;    // ADJUST -- how deep the recess actually is (bumped up
                  // from 5mm for a bit more friction-fit engagement;
                  // shorten this back down if the real recess is
                  // shallower)
flange_d = 22;    // rests on the flat case surface around the recess.
                  // Sized to comfortably out-span the hinge fingers
                  // (hinge_span = 2*finger_w + knuckle_gap = 18mm) with
                  // real margin, so the leg's leverage has a wide
                  // shoulder to load into instead of overhanging it.
flange_t = 3;     // shoulder thickness -- doubled from 1.5mm so the
                  // flange resists the leg's leverage without flexing
                  // or cracking under load
lead_in  = 1;     // small chamfer at the peg's tip so it starts straight

// Gusset width: each hinge finger meets the flange through a hull()'d
// fillet instead of a bare, sharply-cornered tangent (same hull-taper
// trick leg() uses to blend its knuckle into the strip). Deliberately
// bigger than knuckle_od (7mm) -- anything narrower ends up entirely
// swallowed by the finger's own cylinder (hull of a shape inside
// another is a no-op), so it has to actually stick out past the
// finger to add material. The gusset's height is computed inside
// base_plug() itself, capped to stay clear of the hinge hole.
gusset_w = 9;   // x-extent of the gusset's flange-side footprint

// ---------------- Hinge (M3 screw + nut = friction pivot) --------
m3_hole_d     = 3.6;  // bumped from 3.4 -- FDM horizontal holes commonly print
                       // a bit undersized, and 3.4 was too tight for a clean M3 fit
knuckle_od    = 7;
knuckle_r     = knuckle_od / 2;
finger_w      = 6;                 // width of each base knuckle finger --
                                    // widened from 4mm since the leg's
                                    // knuckle (finger_w - 0.4) is the
                                    // thin part actually cantilevering
                                    // the whole leg's load
knuckle_gap   = finger_w;          // gap between the two base fingers
leg_knuckle_w = finger_w - 0.4;    // leg's single knuckle, fits the gap
hinge_span    = 2 * finger_w + knuckle_gap;

// ---------------- Leg -----------------------------------------------
// Widened from the previous version, including the "waist" right
// after the hinge knuckle, both for strength and so it doesn't look
// pinched next to the knuckle and foot pad.
leg_w  = 12;  // strip width
leg_t  = 5;   // strip thickness
foot_w = 18;
foot_l = 14;
foot_t = 3;

// ====================================================================
// Teardrop hole -- printed horizontally (bore axis parallel to the
// bed), a plain round hole needs a bridged top; a teardrop profile
// (circle + a 45 degree point on top) prints with no bridging or
// support at all. Used for every M3 hinge bore in this file.
// ====================================================================
module teardrop2d(r) {
    union() {
        circle(r = r);
        polygon(points = [
            [-r * 0.7071, -r * 0.7071],
            [ r * 0.7071, -r * 0.7071],
            [0, -r * 1.4142]
        ]);
    }
}

module teardrop_hole(d, h) {
    // apex points toward local +Z pre-rotation; callers rotate([-90,0,0])
    // this so the bore axis lands on Y and the apex ends up on world +Z
    // (pointing up, away from the bed)
    linear_extrude(height = h, center = true)
        teardrop2d(d / 2);
}

// ====================================================================
// Base tab (screw version)
// ====================================================================
module base_tab() {
    // kept well clear of the knuckles (at x=base_l) so the hole-cutter
    // doesn't notch into them
    hole_x = base_l * 0.4;
    // stay thin a bit past the screw hole for clearance, then taper up
    // to the thick anchor block -- the taper itself starts well clear
    // of the slot/hole cutting below
    taper_x = hole_x + 2;
    difference() {
        union() {
            // thin insertion pad -- slides under the loosened screw head
            translate([0, -base_w/2, 0])
                cube([taper_x, base_w, base_t]);
            // taper from the thin pad up to a thick, wide anchor block
            hull() {
                translate([taper_x - 0.1, -base_w/2, 0])
                    cube([0.1, base_w, base_t]);
                translate([base_l - 0.1, -base_thick_w/2, 0])
                    cube([0.1, base_thick_w, base_thick_t]);
            }
            for (yc = [-(knuckle_gap/2 + finger_w/2), (knuckle_gap/2 + finger_w/2)])
                translate([base_l, yc, knuckle_r])
                    rotate([-90, 0, 0])
                        cylinder(d = knuckle_od, h = finger_w, center = true);
        }
        // open-sided slot + hole that captures the screw shank
        translate([-1, -shank_hole_d/2, -0.5])
            cube([hole_x + 1, shank_hole_d, base_t + 1]);
        translate([hole_x, 0, -0.5])
            cylinder(d = shank_hole_d, h = base_t + 1);
        // hinge bolt through both fingers -- cutter extends well past
        // the fingers' own Y edges (not just ~1mm) since a small margin
        // there left a hair-thin sliver of uncut material right at the
        // finger's end face, confirmed by intersecting a modeled screw
        // shaft with the part and finding real (if tiny) overlap
        translate([base_l, 0, knuckle_r])
            rotate([-90, 0, 0])
                teardrop_hole(m3_hole_d, hinge_span + 10);
    }
}

// ====================================================================
// Base plug (press-fit version, no hardware)
// ====================================================================
module base_plug() {
    // finger's bottom tangent starts at the flange's own base (not its
    // top) so it genuinely overlaps the flange's solid volume through
    // its full thickness, instead of just touching it along a
    // zero-area line
    finger_z = peg_len + knuckle_r;
    // Gusset stays clear of the hinge hole's own Z-footprint -- it
    // reinforces the finger-to-flange joint, not the finger itself, so
    // its top is capped below the hole's lower edge (with a small
    // margin) rather than a fixed height that could overlap the bore.
    gusset_top_z = finger_z - m3_hole_d/2 - 0.5;
    gusset_h = gusset_top_z - peg_len;
    difference() {
        union() {
            cylinder(d1 = peg_d * 0.8, d2 = peg_d, h = lead_in);
            translate([0, 0, lead_in])
                cylinder(d = peg_d, h = peg_len - lead_in);
            translate([0, 0, peg_len])
                cylinder(d = flange_d, h = flange_t);
            // each finger is hull()'d to a gusset pad seated in the
            // flange, so the finger-to-flange joint is a gradual taper
            // instead of a sharp, stress-concentrating inside corner
            for (yc = [-(knuckle_gap/2 + finger_w/2), (knuckle_gap/2 + finger_w/2)])
                hull() {
                    translate([-gusset_w/2, yc - finger_w/2, peg_len])
                        cube([gusset_w, finger_w, gusset_h]);
                    translate([0, yc, finger_z])
                        rotate([-90, 0, 0])
                            cylinder(d = knuckle_od, h = finger_w, center = true);
                }
        }
        // hinge bolt through both fingers -- cutter extends well past
        // the fingers' own Y edges (not just ~1mm) since a small margin
        // there left a hair-thin sliver of uncut material right at each
        // finger's end face, confirmed by intersecting a modeled screw
        // shaft with the part and finding real (if tiny) overlap there
        translate([0, 0, finger_z])
            rotate([-90, 0, 0])
                teardrop_hole(m3_hole_d, hinge_span + 10);
    }
}

// ====================================================================
// Leg
// ====================================================================
module leg() {
    // Two-stage taper: the first stage keeps the SAME width as the
    // knuckle (leg_knuckle_w) so the hull doesn't flare out over the
    // hinge hole's open ends and pinch them nearly shut; only the
    // second stage (safely past the knuckle) widens out to the full
    // strip cross-section.
    collar_x = knuckle_r + 1;
    root_x   = knuckle_r + 4;
    difference() {
        union() {
            hull() {
                translate([0, 0, knuckle_r])
                    rotate([-90, 0, 0])
                        cylinder(d = knuckle_od, h = leg_knuckle_w, center = true);
                translate([collar_x, -leg_knuckle_w/2, 0])
                    cube([0.1, leg_knuckle_w, knuckle_od]);
            }
            hull() {
                translate([collar_x, -leg_knuckle_w/2, 0])
                    cube([0.1, leg_knuckle_w, knuckle_od]);
                translate([root_x, -leg_w/2, 0])
                    cube([0.1, leg_w, leg_t]);
            }
            hull() {
                translate([root_x, -leg_w/2, 0])
                    cube([0.1, leg_w, leg_t]);
                translate([leg_length - foot_l, -leg_w/2, 0])
                    cube([0.1, leg_w, leg_t]);
            }
            translate([leg_length - foot_l, -foot_w/2, 0])
                cube([foot_l, foot_w, foot_t]);
        }
        // wide margin past the knuckle's own Y edges -- see base_plug()
        // for why a ~1mm margin isn't enough to reliably clear the bore
        translate([0, 0, knuckle_r])
            rotate([-90, 0, 0])
                teardrop_hole(m3_hole_d, leg_knuckle_w + 10);
    }
}

// ====================================================================
// Layout for printing -- all parts flat on the bed, side by side
// ====================================================================
base_tab();
translate([0, 35, 0]) base_plug();
translate([0, 65, 0]) leg();
