function[Pnom,Vnom,Fnom,Rs,Lls,Rr,Llr,H,p,F,Wind_On,FACTSroot]=WindTurbineIndGenInit(nom,sta,rot,mec,ExternalTm,wind_base,block)









    powerlibroot=which('powersysdomain');
    PSBroot=powerlibroot(1:end-25);
    FACTSroot=fullfile(PSBroot,'DR','DR');
    if strcmp('off',ExternalTm)
        Wind_On=1;
    else
        Wind_On=0;
    end
    block=getfullname(block);


    if any(size(nom)~=[1,3])
        error(message('physmod:powersys:common:InvalidVectorParameter','Nominal power, line-to-line voltage, frequency',block,1,3));
    end

    Pnom=nom(1);
    Vnom=nom(2);
    Fnom=nom(3);


    if Pnom<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Nominal power','0'));
    end
    if Vnom<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Nominal line-to-line voltage','0'));
    end
    if Fnom<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Nominal frequency','0'));
    end


    if any(size(sta)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','Stator',block,1,2));
    end

    Rs=sta(1);
    Lls=sta(2);


    if Rs<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Rs','0'));
    end
    if Lls<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Lls','0'));
    end


    if any(size(rot)~=[1,2])
        error(message('physmod:powersys:common:InvalidVectorParameter','Rotor',block,1,2));
    end

    Rr=rot(1);
    Llr=rot(2);


    if Rr<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Rr','0'));
    end
    if Llr<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Llr','0'));
    end


    if any(size(mec)~=[1,3])
        error(message('physmod:powersys:common:InvalidVectorParameter','Inertia constant, friction factor, and pairs of poles',block,1,3));
    end

    H=mec(1);
    F=mec(2);
    p=mec(3);


    if H<=0
        error(message('physmod:powersys:common:GreaterThan',block,'Inertia constant','0'));
    end
    if F<0
        error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'friction factor','0'));
    end
    if p<=0
        error(message('physmod:powersys:common:GreaterThan',block,'pairs of poles','0'));
    end


    if~(wind_base>0)
        error(message('physmod:powersys:common:GreaterThan',getfullname(block),'Base wind speed (m/s)',0));
    end



    WindTurbineIndGenCback(block);
    power_initmask();