function[w1x,w1y,g1x,g1y,w2x,w2y,g2x,g2y,w3x,w3y,g3x,g3y,satx,saty,p]=ThreePhaseTransformer3Icon(Winding1Connection,Winding2Connection,Winding3Connection,SetSaturation);







    ydw1=Winding1Connection;
    ydw2=Winding2Connection;
    ydw3=Winding3Connection;

    p=1;ofst=0;
    if ydw1==1|ydw1==2|ydw1==3
        w1x=[0,0,-5,0,5]*2.5-110;
        w1y=[0,5,10,5,10]*3.2+40;
    end
    if ydw1==3
        g1x=[0,1,1,0,0,1]*15-p*90+ofst;
        g1y=[0,0,2,2,1,1]*15+30;
    else
        g1x=[];
        g1y=[];
    end
    if ydw1==4|ydw1==5
        w1x=[0,10,5,0]*2.5-92;
        w1y=[0,0,10,0]*3+40;
    end


    if ydw2==1|ydw2==2|ydw2==3
        w2x=[0,0,-5,0,5]*2.5+65;
        w2y=[0,5,10,5,10]*3.2+140;
    end
    if ydw2==3
        g2x=[0,1,1,0,0,1]*15+p*80+ofst;
        g2y=[0,0,2,2,1,1]*15+120;
    else
        g2x=[];
        g2y=[];
    end
    if ydw2==4|ydw2==5
        w2x=[0,10,5,0]*2.5+62;
        w2y=[0,0,10,0]*3+90;
    end

    if ydw3==1|ydw3==2|ydw3==3
        w3x=[0,0,-5,0,5]*2.5+65;
        w3y=[0,5,10,5,10]*3.2-170;
    end
    if ydw3==3
        g3x=[0,1,1,0,0,1]*15+p*80+ofst;
        g3y=[0,0,2,2,1,1]*15-190;
    else
        g3x=[];
        g3y=[];
    end
    if ydw3==4|ydw3==5
        w3x=[0,10,5,0]*2.5+68;
        w3y=[0,0,10,0]*3-40;
    end

    if SetSaturation==1
        satx=[-50,-10,10,50];
        saty=[-160,-160,160,160];
    else
        satx=[];
        saty=[];
    end