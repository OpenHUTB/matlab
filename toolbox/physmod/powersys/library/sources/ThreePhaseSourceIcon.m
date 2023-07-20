function[p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,s5]=ThreePhaseSourceIcon(SpecifyImpedance,ShortCircuitLevel,BaseVoltage,R,L,XRratio,InternalConnection,NonIdealSource)





    s5=350;

    if strcmp(SpecifyImpedance,'on')
        R=1;
        L=1;
        if isinf(ShortCircuitLevel)
            R=0;
            L=0;
        else
            if isinf(XRratio)
                R=0;
            end
            if XRratio==0

                R=0;
                L=0;
            end
            if BaseVoltage==0
                R=0;
                L=0;
            end
        end
    else
        if isempty(R)
            R=0;
        end
        if isempty(L)
            L=0;
        end
    end

    switch NonIdealSource
    case 0
        R=0;
        L=0;
    end

    if R==0&&L==0
        s5=70;
    end

    short_x=[0,150];
    short_y=[0,0];
    resistor_x=[0,30,30,38,53,68,83,98,113,120,120,150];
    resistor_y=[0,0,0,25,-25,25,-25,25,-25,0,0,0]*0.5;
    inductor_x=[150,173,173,174,178,184,190,197,202,205,206,204,201,201,197,196,198,201,207,214,220,225,229,229,227,224,224,220,219,221,225,230,237,243,249,252,253,251,247,247,244,243,244,248,254,260,267,272,275,276,276,300];
    inductor_y=[0,0,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,0,0,0]*0.5;
    if R~=0
        p1=resistor_x;
        p2=resistor_y;
    else
        p1=short_x;
        p2=short_y;
    end
    if L~=0
        p3=inductor_x;
        p4=inductor_y;
    else
        p3=short_x+150;
        p4=short_y;
    end

    if InternalConnection==3
        p5=[-150,-150];
        p6=[-15,15];
        p7=[-165,-165];
        p8=[-10,10];
        p9=[-180,-180];
        p10=[-5,5];
    else
        p5=0;p6=0;p7=0;p8=0;p9=0;p10=0;
    end