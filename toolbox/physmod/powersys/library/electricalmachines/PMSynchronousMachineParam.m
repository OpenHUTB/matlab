function PM=PMSynchronousMachineParam(block,FluxCst,~,PolePairs,InitialConditions,InitialConditions5ph)









    PM.Flux=FluxCst;
    dpt=2*pi/3;

    if strcmp(get_param(block,'NbPhases'),'5')

        PM.wmo=InitialConditions5ph(1);


        thetam=InitialConditions5ph(2)*pi/180;
        PM.tho=thetam*PolePairs;


        isao_mag=InitialConditions5ph(3);
        isbo_mag=InitialConditions5ph(4);
        isco_mag=InitialConditions5ph(5);
        isdo_mag=InitialConditions5ph(6);
        iseo_mag=-(isao_mag+isbo_mag+isco_mag+isdo_mag);

        PM.ia=InitialConditions5ph(3);
        PM.ib=InitialConditions5ph(4);
        PM.ic=InitialConditions5ph(5);
        PM.id=InitialConditions5ph(6);


        isabcde=[isao_mag,isbo_mag,isco_mag,isdo_mag,iseo_mag]';

        if strcmp(get_param(block,'RefAngle'),'Aligned with phase A axis (original Park)')
            PM.isqo1=2/5*[cos(PM.tho+pi/2),cos(PM.tho+pi/2-2*pi/5),cos(PM.tho+pi/2-4*pi/5),cos(PM.tho+pi/2+4*pi/5),cos(PM.tho+pi/2+2*pi/5)]*isabcde;
            PM.isdo1=2/5*[sin(PM.tho+pi/2),sin(PM.tho+pi/2-2*pi/5),sin(PM.tho+pi/2-4*pi/5),sin(PM.tho+pi/2+4*pi/5),sin(PM.tho+pi/2+2*pi/5)]*isabcde;
            PM.isqo2=2/5*[cos(PM.tho+pi/2),cos(PM.tho+pi/2+4*pi/5),cos(PM.tho+pi/2-2*pi/5),cos(PM.tho+pi/2+2*pi/5),cos(PM.tho+pi/2-4*pi/5)]*isabcde;
            PM.isdo2=2/5*[sin(PM.tho+pi/2),sin(PM.tho+pi/2+4*pi/5),sin(PM.tho+pi/2-2*pi/5),sin(PM.tho+pi/2+2*pi/5),sin(PM.tho+pi/2-4*pi/5)]*isabcde;
        else
            PM.isqo1=2/5*[cos(PM.tho),cos(PM.tho-2*pi/5),cos(PM.tho-4*pi/5),cos(PM.tho+4*pi/5),cos(PM.tho+2*pi/5)]*isabcde;
            PM.isdo1=2/5*[sin(PM.tho),sin(PM.tho-2*pi/5),sin(PM.tho-4*pi/5),sin(PM.tho+4*pi/5),sin(PM.tho+2*pi/5)]*isabcde;
            PM.isqo2=2/5*[cos(PM.tho),cos(PM.tho+4*pi/5),cos(PM.tho-2*pi/5),cos(PM.tho+2*pi/5),cos(PM.tho-4*pi/5)]*isabcde;
            PM.isdo2=2/5*[sin(PM.tho),sin(PM.tho+4*pi/5),sin(PM.tho-2*pi/5),sin(PM.tho+2*pi/5),sin(PM.tho-4*pi/5)]*isabcde;
        end

    else

        PM.wmo=InitialConditions(1);


        thetam=InitialConditions(2)*pi/180;
        PM.tho=thetam*PolePairs;


        isao_mag=InitialConditions(3);
        isbo_mag=InitialConditions(4);
        isco_mag=-(isao_mag+isbo_mag);

        PM.ia=InitialConditions(3);
        PM.ib=InitialConditions(4);


        isabc=[isao_mag,isbo_mag,isco_mag]';
        if strcmp(get_param(block,'RefAngle'),'Aligned with phase A axis (original Park)')
            PM.isqo=2/3*[cos(PM.tho+pi/2),cos(PM.tho+pi/2-dpt),cos(PM.tho+pi/2+dpt)]*isabc;
            PM.isdo=2/3*[sin(PM.tho+pi/2),sin(PM.tho+pi/2-dpt),sin(PM.tho+pi/2+dpt)]*isabc;
        else
            PM.isqo=2/3*[cos(PM.tho),cos(PM.tho-dpt),cos(PM.tho+dpt)]*isabc;
            PM.isdo=2/3*[sin(PM.tho),sin(PM.tho-dpt),sin(PM.tho+dpt)]*isabc;
        end
    end

    if strcmp(get_param(block,'RefAngle'),'Aligned with phase A axis (original Park)')
        PM.thOffest=pi/2;
    else
        PM.thOffest=0;
    end