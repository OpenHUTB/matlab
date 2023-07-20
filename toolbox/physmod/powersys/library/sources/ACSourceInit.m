function WantBlockChoice=ACSourceInit(block,PowerguiBlockName)






    psbloadfunction(block,'goto','Initialize');

    if~exist('PowerguiBlockName','var')
        PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    else
        PowerguiInfo=getPowerguiInfo(bdroot(block),PowerguiBlockName);
    end

    if PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
        WantBlockChoice='AC complex';
    else
        WantBlockChoice='AC';
    end

    power_initmask();