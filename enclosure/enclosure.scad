$fn = 50;

thick = 1.5;
lid_thick_up = 0.5;
lid_thick_bottom = 1;
lid_thick_w = 0.5;
w = 50;
h = 80;
r = 5;

rim_h = 33;
pcb_elevation = 10;
pcb_thick = 1.8;

head_d = 8;
body_d = 4;

tolerance = 0.1;

// y coordinate of upper screwholes
yy_up = h / 2 - 5 - 3 - 8 - 5;
yy_down = -h / 2 + 3;
xx_left = -w / 2 + 3;
xx_right = w / 2 - 3;

module base_shape(w, h, r)
{
    minkowski()
    {
        square([w,h], center = true);
        circle(r);
    }
}

module base_2d()
{
    difference()
    {
        base_shape(w, h, r);
        translate([0, h/2 - 5, 0]) union()
        {
            hull()
            {
                circle(d = body_d);
                translate([0, -body_d*1.5, 0]) circle(d = body_d);
            }
            translate([0, -body_d*1.5, 0]) circle(d = head_d);
        }
    }
}

module battery_placeholder_2d()
{
    bw = 50;
    bh = 35;
    bthick = 1.5;
    bclen = 5;

    translate([0, -10, 0]) difference()
    {
        square([bw + bthick, bh + bthick], true);
        square([bw, bh], true);
        square([bw + bthick, bh - bclen*2], true);
        square([bw - bclen*2, bh + bthick], true);
    }
}

module rim_2d()
{
    difference()
    {
        base_shape(w, h, r);
        base_shape(w, h, r - thick);
    }
}

module arch(size)
{
    rotate([90, 0, 90]) linear_extrude(thick + 1, center = true) difference()
    {
        square(size);
        intersection()
        {
            circle(r = size);
            square(size + 1);
        }
    }
}

module rimhole(size, r)
{
    zthick = rim_h - thick - pcb_elevation - pcb_thick;
    translate([0, 0, zthick/2 + thick + pcb_elevation + pcb_thick]) cube([thick + 1, size, zthick], center = true);
    translate([0, -r - size/2, rim_h - r]) arch(r);
    translate([0, r + size/2, rim_h - r]) rotate([0, 0, 180]) arch(r);
}

module arkhole(r)
{
    translate([-thick/2, -10/2 + r, r]) minkowski()
    {
        cube([thick, 10 - 2*r, 10 - 2*r]);
        sphere(r = r);
    }
}

module usbhole(r)
{
    //translate([0, 0, 3.5]) cube([12, thick + 1, 7], true);
    translate([-12/2 + r, -thick/2, r]) minkowski()
    {
        cube([12 - 2*r, thick, 7 - 2*r]);
        sphere(r = r);
    }
}

module rim()
{
    difference()
    {
        linear_extrude(rim_h) rim_2d();
        translate([-w/2 - r + thick/2, yy_up - 10, thick + pcb_elevation + pcb_thick])
            arkhole(2);
         translate([w/2 + r - thick/2, yy_up - 10, thick + pcb_elevation + pcb_thick])
            arkhole(2);
         translate([0, -h/2 - r + thick/2, thick + pcb_elevation + pcb_thick - 3.5 + 0.9])
            usbhole(2);
        // make room for a lid
        translate([0, r, rim_h - (lid_thick_up + lid_thick_bottom)])
        linear_extrude(lid_thick_bottom)
            base_shape(w, h + 2*r, r - thick + lid_thick_w);
        translate([0, h + r, rim_h - (lid_thick_up + lid_thick_bottom)])
        linear_extrude(lid_thick_up + lid_thick_bottom + 0.5)
            square([w + 2*(r - thick), h + 2*r], true);
    }
}

module screwstand()
{
    cylinder(pcb_elevation, d1 = 9, d2 = 7);
}

module screwhole()
{
    //cylinder(2, d = 5);
    translate([0, 0, thick]) cylinder(pcb_elevation + 1, d = 2.2);
}

module base()
{
    difference()
    {
        union()
        {
            linear_extrude(thick) base_2d();
            translate([xx_left, yy_down, thick]) screwstand();
            translate([xx_right, yy_down, thick]) screwstand();
            translate([xx_left, yy_up, thick]) screwstand();
            translate([xx_right, yy_up, thick]) screwstand();
        }
        translate([xx_left, yy_down, 0]) screwhole();
        translate([xx_right, yy_down, 0]) screwhole();
        translate([xx_left, yy_up, 0]) screwhole();
        translate([xx_right, yy_up, 0]) screwhole();
    }

    // battery placeholder
    linear_extrude(thick + 1) battery_placeholder_2d();
}

module lid()
{
    rr = r - thick - tolerance;
    translate([0, thick/2, 0]) difference()
    {
        union()
        {
            linear_extrude(lid_thick_bottom - 2*tolerance)
                base_shape(w, h + thick + 2*tolerance, rr + lid_thick_w);
             linear_extrude(lid_thick_bottom + lid_thick_up)
                base_shape(w, h + thick + 2*tolerance, rr);
        }
        translate([0, 0, lid_thick_bottom - 2*tolerance])
        linear_extrude(lid_thick_up+3*tolerance+0.01)
            import (file = "logo.dxf");
    }
}

//lid();
base();
rim();
translate([0, 0, rim_h - (lid_thick_bottom + lid_thick_up)]) lid();


echo("Horizontal screw distance: ", xx_right - xx_left);
echo("Vertical screw distance: ", yy_up - yy_down);