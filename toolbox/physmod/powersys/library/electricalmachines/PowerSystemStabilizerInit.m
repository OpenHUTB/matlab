function[Ts,WantBlockChoice]=PowerSystemStabilizerInit(block)







    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;


    WantDiscreteModel=PowerguiInfo.Discrete||PowerguiInfo.DiscretePhasor;
    if WantDiscreteModel
        WantBlockChoice='Discrete';
    else
        WantBlockChoice='Continuous';
    end

    power_initmask();