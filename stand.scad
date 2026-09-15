// ============================================================
// Kickstand for Unity UN202 clamp multimeter
// Clips onto the existing case screw on the back; the meter's
// bottom edge rests on the table, this leg holds the screw
// point at a fixed height so the whole thing tilts at a fixed,
// safe angle and cannot fall further backward.
//
// MOST NUMBERS BELOW ARE ESTIMATES. Print, test-fit against the
// real screw/case, and tweak the values in the "ADJUST" sections
// before your final print.
// ============================================================

$fn = 64;

// ---------------- ADJUST: overall angle ----------------------
// Angle of the meter's back relative to the table when resting
// on its bottom edge. 0 = lying flat, 90 = standing on end.
tilt_angle = 60;

// Distance from the meter's bottom edge, measured along the
// back surface, up to the center of the screw. This sets the
// leg length -- MEASURE THIS on your meter and correct it.
screw_height_from_bottom = 35;

// ---------------- ADJUST: screw / case geometry ---------------
screw_head_d    = 5.1;   // measured screw head diameter
head_clearance  = 0.6;   // extra dia. so the head slides into the entry hole easily
shank_d         = 3.0;   // estimated shank diameter under the head -- VERIFY
shank_clearance = 0.6;   // extra dia. for the narrow keyhole slot
hook_ceiling    = 0.8;   // plastic thickness trapping the head; must be <= real gap
                          // under the head. Increase for a snugger grip, decrease
                          // if the bracket won't slide flush.

// Relief pocket so the plate doesn't rock on the raised boss/curve
// that surrounds the screw hole (measured ~4mm wide, ~3mm deep).
// Cut as a flat-bottomed counterbore (not a dome) so it clears the
// whole boss regardless of its exact profile, oversized vs. the
// measurement since the exact shape is unknown. The screw head is
// assumed to sit near the bottom of this pocket, on top of the boss.
pocket_dia   = 9;
pocket_depth = 4.5;

// ---------------- Clip plate (touches the case) ---------------
// plate_t is derived below the pocket + hook ceiling + head clearance,
// so it always stays thick enough not to punch through into the pocket.
plate_w = 16;      // across (left-right)
plate_h = 14;      // up the back (bottom-to-top on the case)
head_clearance_h = 2; // extra depth above the ceiling for the screw head
plate_t = pocket_depth + hook_ceiling + head_clearance_h; // thickness

// ---------------- Leg + foot -----------------------------------
leg_t  = 4;    // leg wall thickness
foot_w = 46;   // foot width (left-right) -- tip resistance sideways
foot_d = 24;   // foot depth (front-back) -- tip resistance forward/back
foot_t = 3.5;  // foot thickness

// ================================================================
// Derived geometry
// ================================================================
a = tilt_angle;

// Point where the screw sits once the meter is tilted up on its
// bottom edge (pivoting at the origin).
screw_pt = [screw_height_from_bottom * cos(a), 0, screw_height_from_bottom * sin(a)];

// Outward normal of the meter's back plane (points away from the
// meter, into the space the stand occupies).
back_normal = [-sin(a), 0, cos(a)];

// Rotate a local part (built with its mating face in the XY plane
// at local Z=0, extending to +Z) so local +Z aligns with back_normal
// and local +X aligns with "up the meter's back" direction.
// This is a rotation about Y by (90 - a) degrees.
module in_case_frame() {
    translate(screw_pt)
        rotate([0, -a, 0])
            children();
}

// ---------------- Clip plate + keyhole mount --------------------
module clip_plate() {
    // z=0 is the mating face (touches the case). The pocket is cut
    // from there; the keyhole cavity that traps the screw head sits
    // on top of the pocket floor, separated by hook_ceiling.
    keyhole_z = pocket_depth + hook_ceiling;

    difference() {
        translate([-plate_h/2, -plate_w/2, 0])
            cube([plate_h, plate_w, plate_t]);

        // flat-bottomed relief pocket clearing the case's raised
        // boss/curve around the hole
        translate([0, 0, -0.01])
            cylinder(d = pocket_dia, h = pocket_depth + 0.01);

        // keyhole: large entry hole for the screw head, connected to
        // a narrower slot the shank drops into. Slides on from +X.
        entry_d = screw_head_d + head_clearance;
        slot_w  = shank_d + shank_clearance;
        translate([entry_d/2, 0, keyhole_z])
            cylinder(d = entry_d, h = plate_t - keyhole_z + 0.01);
        translate([-plate_h/2 - 1, -slot_w/2, keyhole_z])
            cube([plate_h/2 + 1 + entry_d/2, slot_w, plate_t - keyhole_z + 0.01]);
    }
}

// ================================================================
// Foot (built directly in world coordinates -- flat on the table)
// ================================================================
module foot() {
    translate([screw_pt[0] - foot_d/2, -foot_w/2, 0])
        cube([foot_d, foot_w, foot_t]);
}

// ================================================================
// Strut connecting the clip plate (in the tilted case frame) down
// to the foot (flat on the table). Built as a hull between the
// plate's footprint (projected to world coords) and the foot.
// ================================================================
module strut() {
    plate_bottom_world = screw_pt + back_normal * (plate_t/2)
                        - [cos(a), 0, sin(a)] * (plate_h/2);
    hull() {
        translate(plate_bottom_world)
            rotate([0, -a, 0])
                translate([-leg_t/2, -leg_t/2, -0.01])
                    cube([leg_t, leg_t, plate_t + 0.02]);
        translate([screw_pt[0] - leg_t/2, -leg_t/2, 0])
            cube([leg_t, leg_t, foot_t]);
    }
}

// ================================================================
// Assembly
// ================================================================
module stand() {
    union() {
        in_case_frame() clip_plate();
        strut();
        foot();
    }
}

stand();
