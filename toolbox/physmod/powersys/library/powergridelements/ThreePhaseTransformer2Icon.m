function[w1x,w1y,g1x,g1y,w2x,w2y,g2x,g2y,satx,saty]=ThreePhaseTransformer2Icon(Winding1Connection,Winding2Connection,SetSaturation);







    if Winding1Connection<=3
        w1x=[0,0,-5,0,5]*2.5-85;
        w1y=[0,5,10,5,10]*3.2-175;
    end
    if Winding1Connection==3
        g1x=[0,1,1,0,0,1]*15-70;
        g1y=[0,0,2,2,1,1]*15-190;
    else
        g1x=[];
        g1y=[];
    end
    if Winding1Connection==4|Winding1Connection==5
        w1x=[0,10,5,0]*2.5-92;
        w1y=[0,0,10,0]*3-175;
    end
    if Winding2Connection<=3
        w2x=[0,0,-5,0,5]*2.5+80;
        w2y=[0,5,10,5,10]*3.2-175;
    end
    if Winding2Connection==3
        g2x=[0,1,1,0,0,1]*15+95;
        g2y=[0,0,2,2,1,1]*15-190;
    else
        g2x=[];
        g2y=[];
    end
    if Winding2Connection==4|Winding2Connection==5
        w2x=[0,10,5,0]*2.5+62;
        w2y=[0,0,10,0]*3-175;
    end
    if SetSaturation==1
        satx=[-30,-10,10,30];
        saty=[-150,-150,150,150];
    else
        satx=[];
        saty=[];
    end