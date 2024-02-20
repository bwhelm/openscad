$fn= $preview ? 32 : 96;        // render more accurately than preview

// =============================
// ===== ADJUSTABLE VALUES =====
// =============================
height = 125;                   // total height of model
width = 70;                     // z-dimension of initial block
baseThickness = 7.5;            // thickness of main
backAngle = 22.5;               // angle of back off vertical
frontAngle = 40;                // angle at front off vertical
rackHeight = 45;                // height of bottom of rack
rackWidth = 14;                 // width of rack
rackThickness = 4.5;            // thickness of rack
braceHeight = 12;               // height of supporting brace at apex
washerRadius = 20;              // radius of washer used for weight
washerDepth = 6.5;              // total thickness of washers
washerFromFront = 5;            // distance of washer from front of stand

// =============================
// ===== CALCULATED VALUES =====
// =============================
z = width - baseThickness;   // z-dimension of block
y = height - baseThickness;  // y-dimension of initial block, compensating for hull
x = y * tan(backAngle) + (y - rackHeight) * tan(frontAngle) + rackWidth;  // base length
braceHeightBase = braceHeight/cos(backAngle);  // length along back brace of apex triangle
braceHeightRack = braceHeight/cos(frontAngle);  // length along front (rack) brace of apex triangle


rotate([90, 0, 0]) translate([baseThickness/2, baseThickness/2, baseThickness/2])  // Adjust to put model at origin
difference(){

    union(){

        // Back
        rotate([0, 0, -backAngle]){
            hull(){
                translate([0, 0, 0]) sphere(baseThickness/2);
                translate([0, 0, z]) sphere(baseThickness/2);
                translate([0, y/cos(backAngle), 0]) sphere(baseThickness/2);
                translate([0, y/cos(backAngle), z]) sphere(baseThickness/2);
            }
        }

        // Front
        // Calculate length of front from apex to bottom of rack
        frontLength = (y-rackHeight-baseThickness/2+rackThickness/2)/cos(frontAngle) + (baseThickness+rackThickness)*tan(frontAngle)/2;
        translate([y * tan(backAngle), y, 0]){
            rotate([0, 0, 180+frontAngle]){
                hull(){
                    translate([0, 0, 0]) sphere(baseThickness/2);
                    translate([0, 0, z]) sphere(baseThickness/2);
                    // Next 4 lines gradually narrow diameter of rack support to diameter of rack
                    translate([0, (y-rackHeight)/cos(frontAngle)/2+braceHeightBase*cos(frontAngle), 0])
                        sphere(baseThickness/2);
                    translate([0, (y-rackHeight)/cos(frontAngle)/2+braceHeightBase*cos(frontAngle), z])
                        sphere(baseThickness/2);
                    translate([-(baseThickness-rackThickness)/2, frontLength, -(baseThickness-rackThickness)/2])
                        sphere(rackThickness/2);
                    translate([-(baseThickness-rackThickness)/2, frontLength, z + (baseThickness-rackThickness)/2])
                        sphere(rackThickness/2);
                    // Substitute these for previous 4 lines to have consistent diameter
                    // translate([0, frontLength-(baseThickness-rackThickness)/2, 0]) sphere(baseThickness/2);
                    // translate([0, frontLength-(baseThickness-rackThickness)/2, z]) sphere(baseThickness/2);
                }
            }
        }

        // Interior triangle brace at apex
        translate([y * tan(backAngle), y, 0]) {
            hull(){
                translate([0, 0, 0]) sphere(baseThickness/2);
                translate([-braceHeightBase*sin(backAngle), -braceHeightBase*cos(backAngle), 0])
                    sphere(baseThickness/2);
                translate([braceHeightRack*sin(frontAngle), -braceHeightRack*cos(frontAngle), 0])
                    sphere(baseThickness/2);
                translate([0, 0, z])
                    sphere(baseThickness/2);
                translate([-braceHeightBase*sin(backAngle), -braceHeightBase*cos(backAngle), z])
                    sphere(baseThickness/2);
                translate([braceHeightRack*sin(frontAngle), -braceHeightRack*cos(frontAngle), z])
                    sphere(baseThickness/2);
            }
        }

        // Bottom
        hull(){
            translate([0, 0, 0]) sphere(baseThickness/2);
            translate([x, 0, 0]) sphere(baseThickness/2);
            translate([x, 0, z]) sphere(baseThickness/2);
            translate([0, 0, z]) sphere(baseThickness/2);
        }

        // Bottom triangle brace
        hull(){
            translate([0, 0, 0])               sphere(baseThickness/2);
            translate([0, 0, z])               sphere(baseThickness/2);
            translate([braceHeightBase, 0, 0]) sphere(baseThickness/2);
            translate([braceHeightBase, 0, z]) sphere(baseThickness/2);
            translate([braceHeightBase*sin(backAngle), braceHeightBase*cos(backAngle), 0])
                sphere(baseThickness/2);
            translate([braceHeightBase*sin(backAngle), braceHeightBase*cos(backAngle), z])
                sphere(baseThickness/2);
        }

        // Rack
        /* translate([0, 0, 0]) color("red", .5) cube([x, rackHeight, z]); */
        translate([y * tan(backAngle), y, 0]){
            rotate([0, 0, frontAngle - 90]){
                translate([frontLength, (baseThickness-rackThickness)/2, (baseThickness-rackThickness)/2]){
                    rotate([0, 0, 90]){
                        // Rack bottom
                        hull(){
                            translate([0, 0, rackThickness-baseThickness])
                                sphere(rackThickness/2);
                            translate([rackWidth + rackThickness, 0, rackThickness-baseThickness])
                                sphere(rackThickness/2);
                            translate([rackWidth + rackThickness, 0, z])
                                sphere(rackThickness/2);
                            translate([0, 0, z])
                                sphere(rackThickness/2);
                        }
                        // Rack front lip
                        translate([rackWidth + rackThickness, 0, 0]){
                            hull(){
                                translate([0, 0, rackThickness-baseThickness])
                                    sphere(rackThickness/2);
                                translate([0, rackWidth/2, rackThickness-baseThickness])
                                    sphere(rackThickness/2);
                                translate([0, rackWidth/2, z])
                                    sphere(rackThickness/2);
                                translate([0, 0, z])
                                    sphere(rackThickness/2);
                            }
                        }
                    }
                }
            }
        }

    }  // END UNION()

    // NOW IN DIFFERENCE()

    // Carve out back hole for cord
    radiushole = 6;
    translate([0, (rackHeight - radiushole + baseThickness)/2, z / 4 + radiushole]) {
        hull(){
            rotate([0, 90, 0]){
                translate([0, 0, 0]) cylinder(h=baseThickness*3, r=radiushole);
                translate([-z/4 - radiushole/2, 0, 0]) cylinder(h=baseThickness*3, r=radiushole);
            }
        }
    }

    // Carve out hole in rack for cord
    translate([y * tan(backAngle) - baseThickness/2, y - baseThickness/2, z / 3])
        rotate([0, 0, frontAngle])
        translate([0, -(y-rackHeight)/cos(frontAngle)-rackThickness, 0]){
            hull(){
                translate([0, 0, 0])
                    sphere(rackThickness/2);
                translate([rackWidth + baseThickness * 2, 0, 0])
                    sphere(rackThickness/2);
                translate([rackWidth + baseThickness * 2, z/3, 0])
                    sphere(rackThickness/2);
                translate([0, z/3, 0])
                    sphere(rackThickness/2);
                translate([0, 0, z/3])
                    sphere(rackThickness/2);
                translate([rackWidth + baseThickness * 2, 0, z/3])
                    sphere(rackThickness/2);
                translate([rackWidth + baseThickness * 2, z/3, z/3])
                    sphere(rackThickness/2);
                translate([0, z/3, z/3])
                    sphere(rackThickness/2);
            }
        }

    // Carve out hole in bottom plate for washers
    translate([x - washerRadius - washerFromFront, 0, z/2])
        rotate([90, 0, 0])
        cylinder(h=washerDepth, r=washerRadius);

}

