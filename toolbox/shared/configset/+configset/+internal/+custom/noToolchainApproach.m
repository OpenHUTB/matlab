function[out,dscr]=noToolchainApproach(cs,~)


    dscr='';

    toolchain=configset.internal.custom.getToolchainApproach(cs);
    if toolchain
        out=configset.internal.data.ParamStatus.InAccessible;
    else
        out=configset.internal.data.ParamStatus.Normal;
    end
