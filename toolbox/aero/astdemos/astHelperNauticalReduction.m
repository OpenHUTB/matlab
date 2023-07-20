function[p,Z]=astHelperNauticalReduction(obs)











    if~builtin('license','test','Aerospace_Toolbox')
        error(message('aero:licensing:noLicenseTlbx'));
    end

    if~builtin('license','checkout','Aerospace_Toolbox')
        return;
    end





    Z=zeros(size(obs.Hs));







    D=0.0293*sqrt(obs.h);




    H=obs.Hs+obs.IC-D;



    R=zeros(size(obs.Hs));
    if any(H<15)


        R(H<15)=(obs.P/(obs.T+273))*((0.1594+H(H<15).*(0.0196+0.00002*H(H<15)))./...
        (1+H(H<15).*(0.0505+0.0845*H(H<15))));
    end
    if any(H>=15)


        R0=0.0167./tand(H(H>=15)+7.32./(H(H>=15)+4.32));


        f=0.28*obs.P/(obs.T+273);
        R(H>=15)=f*R0;
    end






    d=obs.altitude./149597871000;




    piParallax=8.794./d;



    PA=piParallax/3600.*cosd(H);



    S=zeros(size(obs.Hs));
    objMoon=strcmp(obs.object,'Moon');
    if any(objMoon)
        S(strcmp(obs.object,'Moon'))=56204.92/d;
    end
    S(strcmp(obs.object,'Sun'))=959.63;
    S(strcmp(obs.object,'Mercury'))=3.34;
    S(strcmp(obs.object,'Venus'))=8.41;
    S(strcmp(obs.object,'Mars'))=4.68;
    S(strcmp(obs.object,'Jupiter'))=98.47;
    S(strcmp(obs.object,'Saturn'))=83.33;
    S(strcmp(obs.object,'Uranus'))=34.28;
    S(strcmp(obs.object,'Neptune'))=36.56;
    SD=S./d;



    Ho=H-R+SD/3600+PA;







    LHA=mod(360+obs.GHA+obs.longitude,360);




    S=sind(obs.declination);
    C=cosd(obs.declination).*cosd(LHA);
    Hc=asind(S.*sind(obs.latitude)+C.*cosd(obs.latitude));




    x=(S.*cosd(obs.latitude)-C.*sind(obs.latitude))./cosd(Hc);
    if any(x>1)
        x(x>1)=1;
    end
    if any(x<-1)
        x(x<-1)=-1;
    end
    A=acosd(x);
    if any(LHA>180)
        Z(LHA>180)=A(LHA>180);
    end
    if any(LHA<=180)
        Z(LHA<=180)=360-A(LHA<=180);
    end


    p=Ho-Hc;


