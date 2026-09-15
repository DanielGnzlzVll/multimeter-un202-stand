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
               // loosening the screw a couple of turns
base_l = 11;   // length, insertion edge to hinge knuckles
base_w = 9;    // width

// ---------------- Press-fit base plug (no hardware) ---------------
peg_interference = 0.15;  // print the peg this much OVER recess_d for a
                           // tight press fit; sand down if too tight
peg_d    = recess_d + peg_interference;
peg_len  = 5;   // ADJUST -- how deep the recess actually is
flange_d = 9;   // rests on the flat case surface around the recess
flange_t = 1.5;
lead_in  = 1;   // small chamfer at the peg's tip so it starts straight

// ---------------- Hinge (M3 screw + nut = friction pivot) --------
m3_hole_d     = 3.6;  // bumped from 3.4 -- FDM horizontal holes commonly print
                       // a bit undersized, and 3.4 was too tight for a clean M3 fit
knuckle_od    = 7;
knuckle_r     = knuckle_od / 2;
finger_w      = 4;                 // width of each base knuckle finger
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
    difference() {
        union() {
            translate([0, -base_w/2, 0])
                cube([base_l, base_w, base_t]);
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
        // hinge bolt through both fingers
        translate([base_l, 0, knuckle_r])
            rotate([-90, 0, 0])
                teardrop_hole(m3_hole_d, hinge_span + 2);
    }
}

// ====================================================================
// Base plug (press-fit version, no hardware)
// ====================================================================
module base_plug() {
    difference() {
        union() {
            cylinder(d1 = peg_d * 0.8, d2 = peg_d, h = lead_in);
            translate([0, 0, lead_in])
                cylinder(d = peg_d, h = peg_len - lead_in);
            translate([0, 0, peg_len])
                cylinder(d = flange_d, h = flange_t);
            // fingers' bottom tangent starts at the flange's own base
            // (not its top) so they genuinely overlap its solid volume
            // instead of just touching it along a zero-area line
            for (yc = [-(knuckle_gap/2 + finger_w/2), (knuckle_gap/2 + finger_w/2)])
                translate([0, yc, peg_len + knuckle_r])
                    rotate([-90, 0, 0])
                        cylinder(d = knuckle_od, h = finger_w, center = true);
        }
        translate([0, 0, peg_len + knuckle_r])
            rotate([-90, 0, 0])
                teardrop_hole(m3_hole_d, hinge_span + 2);
    }
}

// ====================================================================
// Leg
// ====================================================================
module leg() {
    // short tapered root blends the round knuckle into the flat strip
    // (also removes the abrupt step that made the knuckle end harder
    // to print cleanly)
    root_x = knuckle_r + 2;
    difference() {
        union() {
            hull() {
                translate([0, 0, knuckle_r])
                    rotate([-90, 0, 0])
                        cylinder(d = knuckle_od, h = leg_knuckle_w, center = true);
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
        translate([0, 0, knuckle_r])
            rotate([-90, 0, 0])
                teardrop_hole(m3_hole_d, leg_knuckle_w + 2);
    }
}

// ====================================================================
// Layout for printing -- all parts flat on the bed, side by side
// ====================================================================
base_tab();
translate([0, base_w/2 + 8, 0]) base_plug();
translate([0, base_w/2 + 24, 0]) leg();
