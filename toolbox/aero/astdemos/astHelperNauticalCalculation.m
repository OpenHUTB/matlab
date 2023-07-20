function Hs=astHelperNauticalCalculation(obs,latitude,longitude)













    if~builtin('license','test','Aerospace_Toolbox')
        error(message('aero:licensing:noLicenseTlbx'));
    end

    if~builtin('license','checkout','Aerospace_Toolbox')
        return;
    end





    Hs=zeros(size(obs.object));
    LHA=zeros(size(obs.object));





    obs.longitude=longitude;
    obs.latitude=latitude;
    UTCActual=astHelperLongitudeHour(obs);





    for k=1:length(obs.object)







        jd=juliandate(UTCActual);
        posECI=planetEphemeris(jd,'Earth',obs.object{k},'405','km');





        posECEF=dcmeci2ecef('IAU-76/FK5',UTCActual)*posECI';





        posLLA=ecef2lla(1000*posECEF');

        GHA=-atan2d(posECEF(2),posECEF(1));
        declination=atan2d(posECEF(3),sqrt(posECEF(1)^2+...
        posECEF(2)^2));



        altitude=posLLA(3);




        LHA(k)=mod(360+GHA+longitude,360);









        S=sind(declination);
        C=cosd(declination)*cosd(LHA(k));
        Hc=asind(S*sind(latitude)+C*cosd(latitude));




        D=0.0293*sqrt(obs.h);




        H=Hc+obs.IC+D;



        if H<15


            R=(obs.P/(obs.T+273))*((0.1594+H*(0.0196+0.00002*H))/...
            (1+H*(0.0505+0.0845*H)));
        else


            R0=0.0167/tand(H+7.32/(H+4.32));


            f=0.28*obs.P/(obs.T+273);
            R=f*R0;
        end





        d=altitude/149597871000;


        piParallax=8.794/d;


        PA=piParallax/3600*cosd(H);



        if strcmp(obs.object{k},'Moon')
            SD=56204.92/d;
        else
            switch obs.object{k}
            case 'Sun'
                S=959.63;
            case 'Mercury'
                S=3.34;
            case 'Venus'
                S=8.41;
            case 'Mars'
                S=4.68;
            case 'Jupiter'
                S=98.47;
            case 'Saturn'
                S=83.33;
            case 'Uranus'
                S=34.28;
            case 'Neptune'
                S=36.56;
            end
            SD=S/d;
        end


        Hs(k)=round((R-SD/3600-PA+D+Hc)*100)/100;
    end

