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
leg_length_raw = screw_height_from_bottom * sin(tilt_angle) / sin(tilt_angle - deploy_hinge_angle);
// The geometric derivation above came out longer than the meter itself
// in practice. Trimmed directly rather than distorting the measured/
// chosen inputs above (which are either a real measurement or a
// deliberate angle choice, not free knobs to fudge for length alone).
leg_shorten = 25;
leg_length = leg_length_raw - leg_shorten;

// ---------------- Base tab (through-hole for a replacement screw) ---
// The original case screw is being swapped for a different one (head
// ~5mm, shank ~3mm) that's removed entirely, passed through a plain
// hole in the tab, and driven back into the case -- so the head
// clamps the tab flush against the case. This replaced an earlier
// loosen-and-slide keyhole design sized for the original screw; a
// plain hole is simpler now that the screw comes all the way out, and
// -- as a bonus -- means the tab can't come loose on its own at all,
// since it can only be removed by fully unscrewing it again.
new_screw_head_d       = 5;    // ADJUST -- replacement screw's head
new_screw_shank_d      = 3;    // ADJUST -- replacement screw's shank
new_screw_shank_clear  = 0.5;
new_screw_hole_d       = new_screw_shank_d + new_screw_shank_clear;

base_t = 1.6;  // thickness at the screw hole -- doesn't need to be
               // this thin anymore now that the screw is fully
               // removed for installation, but no reason to change it
base_l = 13;   // length, insertion edge to hinge knuckles
base_w = 14;   // width of the zone the screw head clamps down on --
               // widened from 9mm so it presses on a much bigger flat
               // area, instead of a narrow strip barely wider than
               // the head

// Past the screw hole, the tab doesn't need to stay thin -- nothing
// there has to slide under the screw head -- so it tapers up to a
// much thicker, wider anchor block for the hinge fingers to embed
// into, the same way base_plug()'s peg tapers into its flange.
base_thick_t = 5;   // thickness at the hinge end
base_thick_w = 14;  // width at the hinge end -- out-spans the fingers
                     // (hinge_span = 18mm) with real margin, instead of
                     // the original 9mm tab the fingers overhung badly

// ---------------- Press-fit base plug (no hardware) ---------------
// The peg alone (a rigid cylinder) was too loose -- printed hole sizes
// vary enough in practice that a single fixed diameter can't reliably
// grip. peg_interference is bumped up, and the peg itself is split
// into flexible fingers (see peg_slot_count etc. below) that compress
// or spring out to self-adjust across a range of real hole sizes,
// instead of relying on hitting one exact diameter.
peg_interference = 0.4;   // print the peg this much OVER recess_d;
                           // the split fingers below let it compress
                           // if that's too tight for your actual hole
peg_d    = recess_d + peg_interference;
peg_slot_count = 3;    // number of flexible fingers the peg is split
                        // into -- each can flex independently, so the
                        // peg self-adjusts to a slightly bigger or
                        // smaller real hole instead of being a single
                        // rigid diameter that's either loose or won't
                        // go in at all
peg_slot_w     = 0.6;  // slot width -- thin but printable at $fn=48
peg_solid_top  = 1;    // solid, unsplit hub left at the peg's own top
                        // (flange end) so the fingers have something
                        // rigid to cantilever from
peg_len  = 5.5;  // ADJUST -- how deep the recess actually is. Kept
                  // 0.5mm short of the full estimated recess depth so
                  // the peg doesn't bottom out/crash into whatever is
                  // at the base of that hole (e.g. the screw boss it
                  // used to thread into) before the flange seats flush.
                  // Shorten further if the real recess is shallower.
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

// The leg is already printed -- these two only touch base_tab()/
// base_plug(), never leg(), so the real printed part is unaffected.
// After printing, the leg's actual knuckle didn't leave a clear path
// for the M3 screw through both bases' finger holes: printed parts
// commonly come out slightly oversized on solid features and
// undersized on holes, so a tight nominal fit and a tight nominal
// bore can stack up into no usable clearance at all. Both give the
// real, physical leg more room to seat centered and the screw more
// room to find a straight path through all three holes.
base_gap_pad  = 1.5;   // extra width added to the fingers' own gap
base_m3_hole_d = 4.2;  // base-side hinge bore diameter (leg's own
                        // bore stays at m3_hole_d, unchanged)
base_hinge_span = 2 * finger_w + knuckle_gap + base_gap_pad;

// ---------------- Leg -----------------------------------------------
// Widened from the previous version, including the "waist" right
// after the hinge knuckle, both for strength and so it doesn't look
// pinched next to the knuckle and foot pad.
leg_w  = 12;  // strip width
leg_t  = 5;   // strip thickness
// Foot pad's footprint matches the strip exactly (was 18x3, wider and
// thinner than the strip's 12x5) so the whole leg is one constant
// rectangular cross-section end to end. That lets it print standing
// on edge (rotated 90 degrees from lying flat) for better layer
// orientation along its length -- a flared/thinner foot would stick
// out past the rotated profile and defeat the point.
foot_w = leg_w;
foot_l = 14;
foot_t = leg_t;

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
    // Plain hole for the replacement screw's shank -- fully enclosed
    // by material (not a slot to any edge), positioned with margin on
    // both sides before the taper starts.
    screw_x = new_screw_head_d/2 + 1.5;
    taper_x = screw_x + new_screw_head_d/2 + 1.5;
    difference() {
        union() {
            translate([0, -base_w/2, 0])
                cube([taper_x, base_w, base_t]);
            // taper from the thin pad up to a thick, wide anchor block
            hull() {
                translate([taper_x - 0.1, -base_w/2, 0])
                    cube([0.1, base_w, base_t]);
                translate([base_l - 0.1, -base_thick_w/2, 0])
                    cube([0.1, base_thick_w, base_thick_t]);
            }
            for (yc = [-(base_gap_pad/2 + knuckle_gap/2 + finger_w/2), (base_gap_pad/2 + knuckle_gap/2 + finger_w/2)])
                translate([base_l, yc, knuckle_r])
                    rotate([-90, 0, 0])
                        cylinder(d = knuckle_od, h = finger_w, center = true);
            // The taper above only builds up material on the near (-X,
            // toward the tab) side of each finger -- it stops exactly at
            // the finger's own center, leaving the far (+X) half of each
            // cylinder completely unsupported. This adds a matching cap
            // on that far side, flat in the XY plane at the same low Z
            // as the rest of the anchor block (not stacked upward -- it
            // stays well clear of the fingers' own top, so it can't be
            // in the leg's swept rotation path). Only spans each
            // finger's own Y width, not the gap between them, so it
            // can't interfere with the leg's knuckle sliding in there.
            for (yc = [-(base_gap_pad/2 + knuckle_gap/2 + finger_w/2), (base_gap_pad/2 + knuckle_gap/2 + finger_w/2)])
                translate([base_l, yc - finger_w/2, 0])
                    cube([knuckle_r + 1, finger_w, base_thick_t]);
        }
        // plain through-hole -- the replacement screw is fully removed,
        // passed through here, and driven back into the case, so the
        // head clamps the tab flush. Fully enclosed, not a slot, so the
        // tab can't come loose on its own at all.
        translate([screw_x, 0, -0.5])
            cylinder(d = new_screw_hole_d, h = base_t + 1);
        // hinge bolt through both fingers -- wider bore and gap (see
        // base_gap_pad/base_m3_hole_d) than the leg's own knuckle/bore,
        // since the printed leg didn't leave a clear screw path
        // otherwise: solid features print slightly big, holes print
        // slightly small, and those stack up fast on a tight nominal fit
        translate([base_l, 0, knuckle_r])
            rotate([-90, 0, 0])
                teardrop_hole(base_m3_hole_d, base_hinge_span + 10);
    }
}

// ====================================================================
// Peg slots -- cuts the peg into peg_slot_count flexible fingers (a
// simple split/collet pin) so it self-adjusts across a range of real
// hole sizes instead of relying on one exact nominal diameter: each
// finger can flex inward if the actual hole is a bit tight, or spring
// outward if it's a bit loose. Slots start right past the lead-in
// chamfer and stop peg_solid_top short of the peg's own top, leaving a
// solid, unsplit hub for the fingers to cantilever from.
// ====================================================================
module peg_slots() {
    slot_len = peg_d;
    slot_h   = peg_len - lead_in - peg_solid_top;
    for (i = [0 : peg_slot_count - 1])
        rotate([0, 0, i * 360 / peg_slot_count])
            translate([0, -peg_slot_w/2, lead_in])
                cube([slot_len, peg_slot_w, slot_h]);
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
    gusset_top_z = finger_z - base_m3_hole_d/2 - 0.5;
    gusset_h = gusset_top_z - peg_len;
    difference() {
        union() {
            difference() {
                union() {
                    cylinder(d1 = peg_d * 0.8, d2 = peg_d, h = lead_in);
                    translate([0, 0, lead_in])
                        cylinder(d = peg_d, h = peg_len - lead_in);
                }
                peg_slots();
            }
            translate([0, 0, peg_len])
                cylinder(d = flange_d, h = flange_t);
            // each finger is hull()'d to a gusset pad seated in the
            // flange, so the finger-to-flange joint is a gradual taper
            // instead of a sharp, stress-concentrating inside corner
            for (yc = [-(base_gap_pad/2 + knuckle_gap/2 + finger_w/2), (base_gap_pad/2 + knuckle_gap/2 + finger_w/2)])
                hull() {
                    translate([-gusset_w/2, yc - finger_w/2, peg_len])
                        cube([gusset_w, finger_w, gusset_h]);
                    translate([0, yc, finger_z])
                        rotate([-90, 0, 0])
                            cylinder(d = knuckle_od, h = finger_w, center = true);
                }
        }
        // hinge bolt through both fingers -- wider bore and gap (see
        // base_gap_pad/base_m3_hole_d) than the leg's own knuckle/bore,
        // since the printed leg didn't leave a clear screw path
        // otherwise: solid features print slightly big, holes print
        // slightly small, and those stack up fast on a tight nominal fit
        translate([0, 0, finger_z])
            rotate([-90, 0, 0])
                teardrop_hole(base_m3_hole_d, base_hinge_span + 10);
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
