function[Ts,WantBlockChoice,p]=SurgeArresterInit(block,BreakLoop)





    p=-100;

    powericon('psbloadfunction',block,'gotofrom','Initialize');

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;

    if PowerguiInfo.Phasor
        WantBlockChoice='Continuous';
    end

    if PowerguiInfo.Discrete
        if BreakLoop
            WantBlockChoice='Discrete';
        else
            WantBlockChoice='DirectFT';
        end
    end

    if PowerguiInfo.Continuous
        WantBlockChoice='Continuous';
    end

    IM=get_param(block,'UseDiscreteRobustSolver');
    if PowerguiInfo.Discrete&&strcmp(get_param(block,'BreakLoop'),'off')&&strcmp('on',IM)
        LocallyWantDSS=1;
    else
        LocallyWantDSS=0;
    end

    if PowerguiInfo.WantDSS||LocallyWantDSS
        WantBlockChoice='Discrete_DSS';
    end

    SurgeArresterCback(block);