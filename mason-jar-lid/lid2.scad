$fn= $preview ? 32 : 128;

// ===========================================================================
// EDITABLE VALUES
// ===========================================================================

lidDiam = 91;           // a bit bigger than 29.4 (measured circum) / pi
lidDepth = 17;          // height of lid receptacle
glassWidth = 7.5;       // width of glass in jar
thickness = 2;          // thickness of stand
standHeight = 5;        // height of receptacle off ground
standWidth = 15;        // width of each piece of tripod in stand
numFeet = 3;            // number of feet in stand

// ===========================================================================
// CALCULATED AND OTHER VALUES
// ===========================================================================

intersection(){
    difference(){

        union(){
            translate([0, 0, standHeight]) cylinder(d = lidDiam + 2*thickness, h = lidDepth, center=false);
            for(i = [0 : 360/numFeet : 359.9]){
                rotate([0, 0, i]){
                    translate([0, -standWidth/2, 0]){
                        cube([lidDiam + thickness, standWidth, standHeight], center=false);
                    }
                }
            }
        }

        translate([0, 0, standHeight + thickness]) cylinder(d = lidDiam, h = lidDepth + 2*standHeight + 1, center=false);
        translate([0, 0, -.5]) cylinder(d = lidDiam - 2*glassWidth, h = lidDepth + 2*standHeight + 1, center=false);
        translate([0, 0, -.5]) cylinder(d = lidDiam - 1.25*glassWidth, h = standHeight + .5, center=false);
    }

    cylinder(d = lidDiam + 2*thickness, h = lidDepth + standHeight, center=false);
}
