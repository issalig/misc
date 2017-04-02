//circular z mount for 360 scanner
//include <MCAD/involute_gears.scad>;
include <publicDomainGearV1.1.scad>;
include <nutsnbolts/cyl_head_bolt.scad>;

z_angle=90;
guide_width=3;
axis_width=guide_width*3;
axis_height=guide_width*3;
scan_distance=60;

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
 polygon(points=[[0,0],[width/2,0],[width/2,guide_width],
	[width/2-guide_length,guide_width], [width/2-guide_length,guide_width+guide_width],
[width/2,guide_width+guide_width],
	[width/2,2*guide_width+guide_width],[0,2*guide_width+guide_width]
]);
}
}
module pinion(){
    //test_double_helix_gear (teeth=6,circles=3);
}

module joint(angle=15, radius=scan_distance, width=5, guide_width=2, guide_length=2, thickness=2,cl=0.4){
    gear_diam=5;
rotate_extrude(angle = angle, convexity = 10, $fn=200)

translate(v=[radius-(2*thickness+guide_width),0,0])
rotate(a=[0,180,0])
rotate(a=[0,0,90])

color("orange") 
    union(){
 polygon(points=[[0,0-cl],[width/2+cl,0-cl],[width/2+cl,guide_width+cl],
	[width/2-guide_length+cl,guide_width+cl], [width/2-guide_length+cl,guide_width+guide_width-cl],
[width/2+cl,guide_width+guide_width-cl],
	[width/2+cl,2*guide_width+guide_width],[width/2+cl,2*guide_width+guide_width+gear_diam],
    //outer    
    [width/2+thickness,2*guide_width+guide_width+gear_diam],
    [width/2+thickness,-thickness], [0,-thickness]              
]);
 mirror([1,0,0])
 polygon(points=[[0,0-cl],[width/2+cl,0-cl],[width/2+cl,guide_width+cl],
	[width/2-guide_length+cl,guide_width+cl], [width/2-guide_length+cl,guide_width+guide_width-cl],
[width/2+cl,guide_width+guide_width-cl],
	[width/2+cl,2*guide_width+guide_width],[width/2+cl,2*guide_width+guide_width+gear_diam],
    //outer    
    [width/2+thickness,2*guide_width+guide_width+gear_diam],
    [width/2+thickness,-thickness], [0,-thickness]              
]);
}

//hole for pinion axis
pinion_diam=2;
translate(v=[radius+pinion_diam,(radius+pinion_diam)*sin(angle/2),2*width])
#hole_through(name="M3", l=4*width, cl=0.2,$fn=20);

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
mm_per_tooth = 9; //all meshing gears need the same mm_per_tooth (and the same pressure_angle)
thickness    = 6;
hole         = 3;

    
teeth= get_teeth_from_radius(r1+width, mm_per_tooth);
echo ("Radius ", scan_distance, " mm/tooth ", mm_per_tooth, "-> teeth", teeth);

n1= teeth;
n2=5;

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
translate([ 0,  d12, 0]) rotate([0,0,-($t+n2/2-0*n1+1/2)*360/n2]) 
    color([0.75,1.00,0.75]) 
    gear(mm_per_tooth,n2,thickness,hole,0,108);

}

gears(r1=60,width=4);

circular_guide();
joint();
translate(v=[scan_distance+11.66,0,0])
pinion();


//test_double_helix_gear();