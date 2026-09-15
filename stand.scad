// ============================================================
// Folding kickstand for Unity UN202 clamp multimeter
//
// Two printed parts + one M3 screw and nut:
//   1) base_tab()  - slides sideways under the loosened top case
//                    screw, sits flush against the case.
//   2) leg()       - attaches to the base through an M3 bolt
//                    hinge (screw + nut = friction pivot). Folds
//                    flat against the case when stowed, swings
//                    out to prop the meter up when deployed.
//                    Tightening the nut sets how much friction
//                    holds whatever angle you leave it at.
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

// ---------------- Hinge (M3 screw + nut = friction pivot) --------
m3_hole_d     = 3.4;
knuckle_od    = 7;
knuckle_r     = knuckle_od / 2;
finger_w      = 4;                 // width of each base knuckle finger
knuckle_gap   = finger_w;          // gap between the two base fingers
leg_knuckle_w = finger_w - 0.4;    // leg's single knuckle, fits the gap
hinge_span    = 2 * finger_w + knuckle_gap;

// ---------------- Leg ---------------------------------------------
leg_w  = 8;   // strip width
leg_t  = 3;   // strip thickness
foot_w = 18;
foot_l = 14;
foot_t = 3;

// ====================================================================
// Base tab
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
                cylinder(d = m3_hole_d, h = hinge_span + 2, center = true);
    }
}

// ====================================================================
// Leg
// ====================================================================
module leg() {
    difference() {
        union() {
            translate([0, 0, knuckle_r])
                rotate([-90, 0, 0])
                    cylinder(d = knuckle_od, h = leg_knuckle_w, center = true);
            hull() {
                translate([0, -leg_w/2, knuckle_r - leg_t/2])
                    cube([0.1, leg_w, leg_t]);
                translate([leg_length - foot_l, -leg_w/2, knuckle_r - leg_t/2])
                    cube([0.1, leg_w, leg_t]);
            }
            translate([leg_length - foot_l, -foot_w/2, knuckle_r - foot_t/2])
                cube([foot_l, foot_w, foot_t]);
        }
        translate([0, 0, knuckle_r])
            rotate([-90, 0, 0])
                cylinder(d = m3_hole_d, h = leg_knuckle_w + 2, center = true);
    }
}

// ====================================================================
// Layout for printing -- both parts flat on the bed, side by side
// ====================================================================
base_tab();
translate([0, base_w/2 + 10, 0]) leg();
