$fn= $preview ? 32 : 96;

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

// ===========================================================================
// WHAT TO PRINT
// ===========================================================================

valvePipe = true;                  // if printing pipe inserted over valve
elbow = true;                      // if printing elbow piece (including valvePipe)
hosePipe = true;                   // if printing piece inserted into hose (hosePipe)

// ===========================================================================
// EDITABLE VALUES
// ===========================================================================

pipeThickness = 2.0;            // minimum thickness of pipe wall
valvePipeInsideDiam = 18.3;     // inside diameter (= 17?)
valvePipeLength = 14;           // length of d1 pipe
hosePipeOutsideDiam = 17.0;     // outside diameter (= 19?)
hosePipeLength = 25;            // length of d2 pipe inserted into hose
hosePipeRingDiam = 19.5;        // rings around 12 pipe (thread into hose?)
hosePipeRingWidth = 1;          // width of these rings

elbowRadius = 0;                // radius of inside of elbow
elbowSteps = $preview ? 10 : 45;  // steps in elbow reduction: MUST BE INTEGER MULTIPLE OF 90
elbowStopper = 2;               // extra diameter of ring used as stopper on hose pipe

screenThick = 2;                // thickness of screen
screenHoleSize = 2;             // size of holes in screen

screwLength = 0;                // length of screw section (0 omits)
screwPitch = 3.0;               // distance between threads of screw

// ===========================================================================
// OTHER
// ===========================================================================

elbowFudge = 3;                 // Fudge factor needed to get elbow to work. Don't change!

// ===========================================================================
// CALCULATED VALUES
// ===========================================================================

thickness = pipeThickness * 2;                 // double it since everything is center=true
d1 = valvePipe == false ? 0 : valvePipeInsideDiam; // make be 0 if not printing valvePipe
d2 = hosePipeOutsideDiam - thickness;
largerDiam = d1 >= d2 ? d1 : d2;               // larger of the two diameters
smallerDiam = d1 < d2 ? d1 : d2;               // smaller of the two diameters
elbowOffset = valvePipe == false ? 0 : largerDiam/2 + elbowFudge + elbowRadius;  // offset on y-axis to accommodate elbow joint
screwDiameter = hosePipeOutsideDiam + 3;       // need to make it thicker to attach to pipe better

// ===========================================================================
// MODULES
// ===========================================================================

module elbow(dia1, dia2){
    // create elbow of graduallvalvePipeLength changing diameters
    largerDiam = dia1 >= dia2 ? dia1 : dia2;
    smallerDiam = dia1 < dia2 ? dia1 : dia2;
    difference(){
        union(){
            // Create outer shell of constant size
            rotate_extrude(angle = 90) {
                translate([elbowOffset, 0, 0])
                    circle(d = largerDiam + thickness);
            }
            // Add stopper ring, onlvalvePipeLength if needed
            if(d2 > largerDiam - 4){
                translate([elbowOffset, elbowFudge/2, 0])
                    rotate([90, 0, 0])
                        ring(largerDiam + thickness + 4,
                             largerDiam + thickness,
                             elbowFudge);
            }
        }
        // Remove steps transitioning from one diameter to the other
        for(i = [0 : elbowSteps - 1]){
            rotate([0, 0, 90/elbowSteps*i])
                rotate_extrude(angle = i + 90/elbowSteps)
                    translate([elbowOffset, 0, 0])
                        circle(d = largerDiam - thickness - (d2 - d1)*i/elbowSteps);
        }
        rotate_extrude(angle = 90) {
            translate([elbowOffset, 0, 0]) circle(d = smallerDiam);
        }
    }
}

module ring(diaBig, diaSmall, width){
    difference(){
        cylinder(h=width, d=diaBig, center=true);
        cylinder(h=width + 1, d=diaSmall, center=true);
    }
}

module screen(diameter, width){
    difference(){
        cylinder(h=width, d=diameter, center=true);
        for(i = [0 : screenHoleSize + .75 : diameter]){
            for(j = [0 : screenHoleSize + .75 : diameter]){
                translate([diameter/2 - i, diameter/2 - j, 0])
                    cube([screenHoleSize, screenHoleSize, width+.1], center=true);
            }
        }
    }
}

module complete(){
    rotate([-90, 0, 0]) translate([0, -elbowOffset-d1/2-thickness/2, 0])
        union() {

            // valvePipe -- to go over drone valve
            if(valvePipe == true){

                // the pipe
                translate([-valvePipeLength/2, elbowOffset, 0]){
                    if(elbow == false){  // Not printing elbow, so place it next to hose pipe
                        translate([-valvePipeLength / 2,
                                   -elbowOffset - valvePipeLength / 2,
                                   0]){
                            rotate([0, 0, 90])
                                rotate([0, 90, 0]) ring(d1 + thickness, d1, valvePipeLength);
                        }
                    }
                    else{
                        rotate([0, 90, 0]) ring(d1 + thickness, d1, valvePipeLength);
                    }
                }

                // elbow joint
                if(elbow == true){
                    elbow(d1, d2);
                }

                translate([elbowOffset, 0, 0]){
                    rotate([90, 0, 0]){

                        // Add inside screw section
                        if(screwLength > 0){
                            translate([0, 0, screwLength/2])
                                difference(){
                                    threaded_rod(d=screwDiameter,
                                                 height=screwLength,
                                                 pitch=screwPitch);
                                    cylinder(h=screwLength + 1, d=d2, center=true);
                                }
                        }
                    }
                }

            }

            // hosePipe -- to be inserted into hose
            if(hosePipe == true){
                adjustx = screwLength == 0 ? 0 : hosePipeOutsideDiam + d1/2;
                adjusty = screwLength == 0 ? 0 : screenThick/2 + elbowOffset + d1/2 + thickness/2;
                translate([elbowOffset + adjustx, adjusty, 0]){
                    rotate([90, 0, 0]){
                        union(){
                            // outside screw FIXME: need to add connection to elbow!
                            if(screwLength > 0){
                                translate([0, 0, screenThick/2 + screwLength/2])
                                    threaded_nut(nutwidth=hosePipeOutsideDiam + 8,
                                                 id=screwDiameter+.5,
                                                 h=screwLength,
                                                 pitch=2.5,
                                                 bevel=false);
                            }
                            // Add screen
                            translate([0, 0, screwLength + screenThick/2]) screen(d2, screenThick);
                            // Add pipe to be inserted into hose
                            union(){
                                translate([0, 0, hosePipeLength/2 + screwLength])
                                    ring(d2+thickness, d2, hosePipeLength);
                                translate([0, 0, hosePipeLength/2 + screwLength])
                                    ring(hosePipeRingDiam, hosePipeOutsideDiam, hosePipeRingWidth);
                                translate([0, 0, hosePipeLength + screwLength - hosePipeRingWidth / 2])
                                    ring(hosePipeRingDiam, hosePipeOutsideDiam, hosePipeRingWidth);
                            }
                        }
                    }
                }
            }

        }
}

complete();

/* // the pipe */
/* rotate([0, 0, 90]) */
/* translate([-valvePipeLength/2 - screwLength, elbowOffset, 0]){ */
/*     rotate([0, 90, 0]) ring(d1 + thickness, d1, valvePipeLength); */
/* } */
