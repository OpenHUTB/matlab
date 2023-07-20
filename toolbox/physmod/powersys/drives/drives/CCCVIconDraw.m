
CH.X=[-70,30];
CH.bas=-50;
CH.haut=40;
CH.dim_Xsin=CH.X(1):1:CH.X(2);
CH.dim_sin=0:pi/2/((-CH.X(1)+CH.X(2))/2):2*pi/2;
CH.TopX=[-30,-10];
CH.dim_Xtop=CH.TopX(1):1:CH.TopX(2);
CH.dim_top=0:pi/2/((-CH.TopX(1)+CH.TopX(2))/2):2*pi/2;

[X1,X1m,X2,X2m,X3,X4,Y1,Y1m,Y2,Y2m,Y3,Y4,CH.color1,CH.color2]=spsdrivelogo;

scale=160;
CH.dx=0.6;
CH.dy=0.7;
CH.X1=(X1-CH.dx)*scale;
CH.X1m=(X1m-CH.dx)*scale;
CH.X2=(X2-CH.dx)*scale;
CH.X2m=(X2m-CH.dx)*scale;
CH.X3=(X3-CH.dx)*scale;
CH.X4=(X4-CH.dx)*scale;
CH.Y1=(Y1-CH.dy)*scale;
CH.Y1m=(Y1m-CH.dy)*scale;
CH.Y2=(Y2-CH.dy)*scale;
CH.Y2m=(Y2m-CH.dy)*scale;
CH.Y3=(Y3-CH.dy)*scale;
CH.Y4=(Y4-CH.dy)*scale;
CH.X5=(([-20,-5,-5,10,10,25,25,40,40,25,25,15,10,10,-5,-5,-10,-20,-20,-35,-35,-20,-20]-2.5).*1.25)-20;
CH.Y5=[35,35,10,10,35,35,10,10,0,0,-20,-25,-25,-50,-50,-25,-25,-20,0,0,10,10,35]-1;
CH.color3=(CH.color1+CH.color2)/2;

plot(-100,-60,60,50,[CH.X(1),CH.X(1)],[CH.bas,CH.haut],[CH.X(2),CH.X(2)],[CH.haut,CH.bas],CH.dim_Xsin,4*sin(CH.dim_sin)+CH.haut,CH.dim_Xsin,-4*sin(CH.dim_sin)+CH.haut,CH.dim_Xsin,-4*sin(CH.dim_sin)+CH.bas,CH.dim_Xtop,sin(CH.dim_top)+CH.haut+4,CH.dim_Xtop,-sin(CH.dim_top)+CH.haut+4,CH.dim_Xtop,-sin(CH.dim_top)+CH.haut,[CH.TopX(2),CH.TopX(2)],[CH.haut,CH.haut+4],[CH.TopX(1),CH.TopX(1)],[CH.haut+4,CH.haut]);plot(CH.dim_Xsin,-5*sin(CH.dim_sin)+20);

patch(CH.X5,CH.Y5,CH.color3);
plot(CH.X5,CH.Y5);

s=0.65;
oX=-10;
oY=2;
patch([CH.X1,CH.X1m].*s+oX,[CH.Y1,CH.Y1m].*s+oY,CH.color1);
patch(CH.X3.*s+oX,CH.Y3.*s+oY,CH.color2);
plot([CH.X1,CH.X1m,CH.X2,CH.X2m,CH.X3,CH.X4].*s+oX,[CH.Y1,CH.Y1m,CH.Y2,CH.Y2m,CH.Y3,CH.Y4].*s+oY);


port_label('rconn',1,'V+');
port_label('rconn',2,'V-');

switch get_param(gcb,'s_type')
case '3-phases AC (wye)'
    switch get_param(gcb,'n_connect')
    case 'on'
        port_label('lconn',1,'A');
        port_label('lconn',2,'B');
        port_label('lconn',3,'C');
        port_label('lconn',4,'N');
    case 'off'
        port_label('lconn',1,'A');
        port_label('lconn',2,'B');
        port_label('lconn',3,'C');
    end
case '3-phases AC (delta)'
    port_label('lconn',1,'A');
    port_label('lconn',2,'B');
    port_label('lconn',3,'C');
case '3-phases AC'
    port_label('lconn',1,'A');
    port_label('lconn',2,'B');
    port_label('lconn',3,'C');
case '1-phase AC'
    port_label('lconn',1,'A');
    port_label('lconn',2,'B');
case 'DC'
    port_label('lconn',1,'+');
    port_label('lconn',2,'-');
end

color('blue');
port_label('output',1,'m');

switch get_param(gcb,'VoltComp')
case 'on'
    port_label('input',1,'Ta');
    switch get_param(gcb,'DynInT')
    case 'on'
        switch get_param(gcb,'Out_mode')
        case 'Constant Current - Constant Voltage (CCCV)'
            port_label('input',2,'CC');
            port_label('input',3,'CV');
        case 'Constant Current only (CC)'
            port_label('input',2,'CC');
        case 'Constant Voltage only (CV)'
            port_label('input',2,'CV');
        end
    end
otherwise
    switch get_param(gcb,'DynInT')
    case 'on'
        switch get_param(gcb,'Out_mode')
        case 'Constant Current - Constant Voltage (CCCV)'
            port_label('input',1,'CC');
            port_label('input',2,'CV');
        case 'Constant Current only (CC)'
            port_label('input',1,'CC');
        case 'Constant Voltage only (CV)'
            port_label('input',1,'CV');
        end
    end
end