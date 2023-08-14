function WantBlockChoice=DCVoltageSourceInit(block)





    psbloadfunction(block,'goto','Initialize');

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    if PowerguiInfo.Phasor
        WantBlockChoice='DC complex';
    else
        WantBlockChoice='DC';
    end

    power_initmask();