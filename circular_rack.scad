//circular z mount for 360 scanner
//include <MCAD/involute_gears.scad>;
//https://www.youtube.com/watch?v=8bml2pK6Ra0
include <publicDomainGearV1.1.scad>;
include <nutsnbolts/cyl_head_bolt.scad>;

z_angle=90;
guide_width=3;
axis_width=guide_width*3;
axis_height=guide_width*3;
scan_distance=50;

module circular_guide(angle=z_angle, radius=scan_distance, width=5, guide_width=2, guide_length=2){
rotate_extrude(angle = angle, convexity = 10, $fn=200)

translate(v=[radius,radius*0,0])
rotate(a=[0,0,90])
union(){
 polygon(points=[[0,0],[width/2,0],[width/2,guide_width],
	[width/2-guide_length,guide_width], [width/2-guide_length,guide_width+guide_width],
[width/2,guide_width+guide_width],
	[width/2,2*guide_width+guide_width],[0,2*guide_width+guide_width]
]);
 mirror([1,0,0])
 polygon(points=[[0,0],[width/2,0],//[width/2,guide_width],
	//[width/2-guide_length,guide_width], //[width/2-guide_length,guide_width+guide_width],
//[width/2,guide_width+guide_width],
	[width/2,2*guide_width+guide_width],[0,2*guide_width+guide_width]
]);
}
}
module pinion(){
    //test_double_helix_gear (teeth=6,circles=3);
}

module joint(angle=15, radius=scan_distance, width=5, guide_width=2, guide_length=2, thickness=2,cl=0.4, gear_dist=5){

difference(){
    
            holder_width=2;
            rotate(a=[0,0,angle/2])            
            translate(v=[radius-(width+thickness+(1-cos(angle/2))*radius),0,0])
//TODO, compute height (14) and interesect big cube to have parallel cut -> easier printing    
    #cube([holder_width,14,30],true);
            
     
translate(v=[radius-(width+thickness+(1-cos(angle/2))*radius)/2,15/2,30*0.35])
            rotate(a=[0,90,angle/2])                    
            #hole_through(name="M3", l=4*width, cl=0.2,$fn=20);

translate(v=[radius-(width+thickness+(1-cos(angle/2))*radius)/2,15/2,-30*0.35])
            rotate(a=[0,90,angle/2])                    
            #hole_through(name="M3", l=4*width, cl=0.2,$fn=20);           
            
}


    difference(){
        union(){
            
rotate_extrude(angle = angle, convexity = 10, $fn=200)

translate(v=[radius-(2*thickness+guide_width),0,0])
rotate(a=[0,180,0])
rotate(a=[0,0,90])

color("orange") 
    union(){
 polygon(points=[[0,0-cl],[width/2+cl,0-cl],[width/2+cl,guide_width+cl],
	[width/2-guide_length+cl,guide_width+cl], [width/2-guide_length+cl,guide_width+guide_width-cl],
[width/2+cl,guide_width+guide_width-cl],
	[width/2+cl,2*guide_width+guide_width],[width/2+cl,2*guide_width+guide_width+gear_dist*2],
    //outer    
    [width/2+thickness,2*guide_width+guide_width+gear_dist*2],
    [width/2+thickness,-thickness], [0,-thickness]              
]);
 mirror([1,0,0])
 polygon(points=[[0,0-cl],
        [width/2+cl,0-cl],/*[width/2+cl,guide_width+cl],
	[width/2-guide_length+cl,guide_width+cl], [width/2-guide_length+cl,guide_width+guide_width-cl],
[width/2+cl,guide_width+guide_width-cl],*/
	[width/2+cl,2*guide_width+guide_width],[width/2+cl,2*guide_width+guide_width+gear_dist*2],
    //outer    
    [width/2+thickness,2*guide_width+guide_width+gear_dist*2],
    [width/2+thickness,-thickness], [0,-thickness]              
]);
}
}
//hole for pinion axis
pinion_diam=gear_dist;
translate(v=[radius+pinion_diam,(radius+pinion_diam)*sin(angle/2),2*width])
#hole_through(name="M3", l=4*width, cl=0.2,$fn=20);
}
}
module my_double_helix_gear (
	teeth=20,
	circles=0)
{
	//double helical gear
	{
		twist=200;
		height=20;
		pressure_angle=30;

		gear (number_of_teeth=teeth,
			circular_pitch=700,
			pressure_angle=pressure_angle,
			clearance = 0.2,
			gear_thickness = 0,//height/2*0.5,
			rim_thickness = height/+2,
			rim_width = 5,
			hub_thickness = height/2*1.2,
			hub_diameter=0,//15,
			bore_diameter=0,//5,
			circles=circles,
			twist=twist/teeth,
			involute_facets=1,
			flat=false);
		mirror([0,0,1])
		gear (number_of_teeth=teeth,
			circular_pitch=700,
			pressure_angle=pressure_angle,
			clearance = 0.2,
			gear_thickness = 0,//height/2,
			rim_thickness = height/2,
			rim_width = 5,
			hub_thickness = height/2,
			hub_diameter=0,//15,
			bore_diameter=5,
			circles=circles,
			twist=twist/teeth);
	}
}

function get_teeth_from_radius(radius, mm_per_tooth)=
     (2*3.1415926*radius)/mm_per_tooth;

module gears(r1=scan_distance, mm_per_tooth = 9, height= 12,
width=15, angle=90){
mm_per_tooth = 7; //all meshing gears need the same mm_per_tooth (and the same pressure_angle)
thickness    = 6;
hole         = 3;

    
teeth= get_teeth_from_radius(r1+width, mm_per_tooth);
echo ("Radius ", scan_distance, " mm/tooth ", mm_per_tooth, "-> teeth", teeth);

n1= teeth;
n2=6;

d1=pitch_radius(mm_per_tooth,n1);
d2=pitch_radius(mm_per_tooth,n2);
d12=d1+d2;
echo("Arch pitch radius",d1);
echo("Pinion pitch radius ",d2);
translate([ 0,    0, 0]) rotate([0,0, $t*360/n1])                 
    color([1.00,0.75,0.75]) 
    gear(mm_per_tooth,n1,thickness,hole_diameter=2*(d1-width),
    teeth_to_hide=n1*(1-angle/360),
    clearance=0.2, backslash=0.1);

translate([ 0,  d12+4, 0]) rotate([0,0,-($t+n2/2-0*n1+1/2)*360/n2]) 
    color([0.75,1.00,0.75]) 
    gear(mm_per_tooth,n2,thickness,hole,0,108);
/*
rotate([0,0, 15/2]) 
translate([ d12,  0, 0]) 
    color([0.75,1.00,0.75]) 
    gear(mm_per_tooth,n2,thickness,hole,0,108);
*/
}

gwidth=4;
/*
rotate([0,0, -90+5]) 
gears(r1=scan_distance,width=gwidth);

circular_guide(width=6);
//rotate([0,0, 90-15/2]) 
*/
/////

rotate([90,0,0]) 
rotate([0,0, 180-20]) 
translate([-50,-8.9,-10])
joint(angle=20,gear_dist=pitch_radius(7,6)+gwidth, width=6.3-0.4, cl=0.4);



