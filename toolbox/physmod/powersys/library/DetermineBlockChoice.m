function[WantBlockChoice,Ts,SimStatus,CheckErrors]=DetermineBlockChoice(block,Ts,HavePhasorModel,CanInherit)




    CheckErrors=1;
    WantBlockChoice='Continuous';
    SimStatus=get_param(bdroot(block),'SimulationStatus');
    errMsg=message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Sample time','0');

    if CanInherit
        errMsg=message('physmod:powersys:library:InvalidTsCanInherit',block);
    end

    if~isscalar(Ts)
        error(message('physmod:powersys:common:NonScalarParameter','Sample time',block));
    end


    if isempty(Ts)
        error(errMsg);
    end

    if isinf(Ts)
        error(errMsg);
    end

    if Ts>0


        WantBlockChoice='Discrete';

    elseif Ts==0


        WantBlockChoice='Continuous';

    elseif Ts==-1



        WantBlockChoice='Discrete';



        if CanInherit==0
            error(errMsg);
        end

    elseif Ts==-2


        PowerguiInfo=getPowerguiInfo(bdroot(block),block);

        if PowerguiInfo.Phasor
            Ts=0;
            if HavePhasorModel
                WantBlockChoice='Phasor';
            else


                WantBlockChoice='Continuous';
            end
        end

        if PowerguiInfo.Discrete||PowerguiInfo.DiscretePhasor
            Ts=PowerguiInfo.Ts;
            WantBlockChoice='Discrete';
        end
        if PowerguiInfo.Continuous
            Ts=0;
            WantBlockChoice='Continuous';
        end

    else

        WantBlockChoice='Continuous';


        error(errMsg);
    end