// A threaded lid for a standard narrow mouth home canning jar (Ball, Mason, etc.)
// Dependency:  round_threads.scad

//  David O'Connor https://www.thingiverse.com/lizard00
//  This work is under the Creative Commons 3.0 Attribution Unported (CC-BY-3.0) license.
//  (https://creativecommons.org/licenses/by/3.0/)
// 23 November 2018

// You'll need to change the path to work with your particular file system
use <./round_threads.scad>

// ===========================================================================
// WHAT TO PRINT
// ===========================================================================

lid = true;           // True to print lid
threads = true;       // True to print threads on lid (will give warning if false)
intake = true;        // True to print water intake
holes = true;         // True to print holes in lid
standoff = true;      // True to print standoffs on lid top

// ===========================================================================
// EDITABLE VALUES
// ===========================================================================

thickness = 1.5;      // Wall thickness
holesize = 1;         // Size of holes
intake_radius = 10;   // radius of water intake
intake_height = 15;   // height of water intake
offset = 3;           // Amount of offset for standoffs
lid_size = "wide";    // "wide" for widemouth; anything else for narrow (normal)

// ===========================================================================
// CALCULATED AND OTHER VALUES
// ===========================================================================

// According to Wikipedia, the outside diameter is 70 mm (86 mm for wide mouth)
// Below is some trial-and-error for getting the dimensions correct.  This was on a Creality CR-10S
//   with Tianse PLA filament; bed at 60 C and hot end at 225.  Your results may vary.
//d_nominal = 70.6;     // Nominal measured jar rim diameter (This value way too big; threads don't even engage.)
//d_nominal = 66.5;     // Snug; barely fits
//d_nominal = 67.2;     // *** USE THIS ONE FOR NARROW *** Good compromise for narrow mouth;
                        // spins onto jar nicely without being overly sloppy

//d_nominal = 83.2;     // Estimate for wide mouth, *slightly* snug but works fine.
//d_nominal = 83.3;     //  *** USE THIS ONE FOR WIDE ***

d_nominal = lid_size == "wide"? 83.3 : 67.2;  // set size of lid in mm
thread = threads == true? 3 : 0;  // Set thread diameter if threads is true
d_clearance = thread + 0.5;  // Add 0.5 mm for slop
d = d_nominal + d_clearance; // Diameter for the base cylinder
pitch = 0.25 * 25.4;  // Thread pitch
thread_length = 16;   // Length of threaded section
rounding = 3;         // Bevel radius


module lid() {
    // Print main lid, with all desired components
    union(){
        difference() {
            difference() {
                minkowski()
                {
                    sphere(r = rounding, $fa=5, $fs=0.2);
                    translate([0, 0, rounding])
                        // The default faceting works nicely for making the lid easy to grip
                        cylinder(r = d * 0.5 + thickness, h = thread_length + thickness - 2* rounding, $fa=20);
                }
                translate([0, 0, -.01])
                    round_threads(diam = d, thread_diam = thread, pitch = pitch, thread_length = thread_length, groove = true, num_starts = 1);
            }
            if(intake == true) cylinder(r = 10, h = 40, center=true);  // Cut out hole for intake
            if(holes == true) holes();
        }
        if(intake == true) intake();
        if(standoff == true) standoff();
    }
}

module standoff(){
    // standoff to lift lid above countertop when inverted
    translate([0, 0, thread_length/2 + offset])
    intersection(){
        difference(){
            cylinder(r=d/2+thickness*4, h=thread_length + thickness, center=true, $fa=20);
            cylinder(r=d/2+.2, h=thread_length + thickness+.01, center=true);
        }
        for(i = [0 : 120 : 359]){
            rotate([0, 0, i]) translate([-7.5, 0, 0]) cube([15, 50, thread_length/2 + offset], center=false);
        }
    }
}

module holes(width = holesize, height = 35){
    // drain holes in main part of lid
    intersection(){
        difference(){
            cylinder(r = d/2 - thickness*4, h = height + 1, center=true);
            cylinder(r = intake_radius + 2*thickness, h=height + 1, center=true);
        }
        for(i = [-d/2 : width * 2 : d/2]){
            for(j = [-d/2 : width * 2 : d/2]){
                translate([i, j, 0]){
                    /* cube([width, width, height], center=true); */
                    cylinder(d=width, h=height, center=true, $fs=0.6);
                }
            }
        }
    }
}

module intake(radius = intake_radius, height = intake_height, thickness = thickness){
    // recessed area for easy filling with water
    z = height/2 - (thread_length + thickness);
    rotate([0, 180, 0]) difference(){
        difference(){
            union(){
                translate([0, 0, z]) cylinder(r = radius, h = height, center=true);
                translate([0, 0, z + height/2]) sphere(radius);
            }
            union(){
                translate([0, 0, z]) cylinder(r = radius - thickness, h = height + .1, center=true);
                translate([0, 0, z + height/2]) sphere(radius - thickness);
            }
        }
        union(){
            translate([0, 0, z + thickness * 2]) for(i = [0 : 10 : 179]){
                rotate([0, 0, i]) cube([height*2, holesize*.85, height+thickness*2], center=true);
            }
            intersection(){
                for(i = [-radius + thickness : 2*holesize : radius - thickness]){
                    for(j = [-radius + thickness : 2*holesize : radius - thickness]){
                        translate([i, j, 0])
                            /* cube([holesize, holesize, height*2], center=true); */
                            cylinder(d=holesize, h=height*2, center=true, $fs=0.6);
                    }
                }
                cylinder(r=radius - thickness, h=height * 2);
            }
        }
    }
}

/* holes(); */
/* intake(); */
/* standoff(); */
lid();
