function[icon]=maskInit()




    a=.6;
    s=10*pi/180;
    t=-s:pi/180:s;
    x=[NaN,a*cos(t)-.1];
    y=[NaN,a*sin(t)+.5];

    a=.7;
    s=15*pi/180;
    t=-s:pi/180:s;
    x=[x,NaN,a*cos(t)-.1];
    y=[y,NaN,a*sin(t)+.5];

    a=.8;
    s=25*pi/180;
    t=-s:pi/180:s;
    x=[x,NaN,a*cos(t)-.1];
    y=[y,NaN,a*sin(t)+.5];




    icon.x=[x,NaN,0.05,NaN,.75];
    icon.y=[y,NaN,.08,NaN,.92];

    icon.x1=[.1,.1,.22,.42,.42,.22,.1];
    icon.y1=[.38,.62,.62,.9,.1,.38,.38];

    icon.x2=[.18,.22,.22,.18];
    icon.y2=[.38,.38,.62,.62];

    icon.x3=1.5;
    icon.y3=(max(y)-min(y))/2;

end