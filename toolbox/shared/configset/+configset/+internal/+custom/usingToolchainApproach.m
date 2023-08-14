function[out,dscr]=usingToolchainApproach(cs,~)


    dscr='';

    toolchain=configset.internal.custom.getToolchainApproach(cs);
    if toolchain
        out=configset.internal.data.ParamStatus.Normal;
    else
        out=configset.internal.data.ParamStatus.InAccessible;
    end

