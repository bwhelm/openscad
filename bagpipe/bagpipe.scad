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
elbowOffset = valvePipe == false ? 0 : largerDiam/2 + elbowFudge + elbowRadius;  // offset on y-axis to accommodate elbow joint

// ===========================================================================
// MODULES
// ===========================================================================

module elbow(dia1 = d1, dia2 = d2){
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
            if(dia2 > largerDiam - 4){
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
        // make sure inside is cleaned out to minimum diameter
        rotate([0, 0, -.5]) rotate_extrude(angle = 91) {
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

module hosePipe(elbow = elbow){
    adjustx = hosePipeOutsideDiam + d1/2;
    adjusty = screenThick/2 + elbowOffset + d1/2 + thickness/2;
    translate([elbowOffset + adjustx, adjusty, 0]){
        rotate([90, 0, 0]){
            union(){
                // Add screen
                fudge = elbow==false ? elbowFudge/2 : 0;
                translate([0, 0, screenThick/2 - fudge]) screen(d2, screenThick);
                // Add pipe to be inserted into hose
                union(){
                    translate([0, 0, hosePipeLength/2])
                        ring(d2+thickness, d2, hosePipeLength);
                    translate([0, 0, hosePipeLength/2])
                        ring(hosePipeRingDiam, hosePipeOutsideDiam, hosePipeRingWidth);
                    translate([0, 0, hosePipeLength - hosePipeRingWidth / 2])
                        ring(hosePipeRingDiam, hosePipeOutsideDiam, hosePipeRingWidth);
                }
                // Add stopper ring, onlvalvePipeLength if needed
                if(elbow == false){
                    difference(){
                        cylinder(h=elbowFudge, d=largerDiam + thickness, $fn=6, center=true);
                        cylinder(h=elbowFudge + 1, d=d2, center=true);
                    }
                }
            }
        }
    }
}

module buildComplete(valvePipe = valvePipe, elbow = elbow, hosePipe = hosePipe){
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
                if(elbow == true) elbow(d1, d2);

            }

            // hosePipe -- to be inserted into hose
            if(hosePipe == true)
                translate([-2*d2, -hosePipeLength+.75, 0]){
                    hosePipe();
                }
        }

}

module buildArray(num = 4, xspace = 38.5, yspace = 24){
    for(i = [0 : 1 : sqrt(num) - 1]){
        for(j = [0 : 1 : sqrt(num) - 1]){
            translate([i*xspace, j*yspace, 0]){
                buildComplete(valvePipe = true, elbow = true, hosePipe = true);
            }
        }
    }
    translate([-20, 50, 0])
    for(i = [0 : 1 : sqrt(num) - 1]){
        for(j = [0 : 1 : sqrt(num) - 1]){
            translate([i*yspace, j*yspace, hosePipeLength+.75]){
                rotate([-90, 0, 0]) hosePipe(elbow = false);
            }
        }
    }
}

/* buildArray(); */

buildComplete();
