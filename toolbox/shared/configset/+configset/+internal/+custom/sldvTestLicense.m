function[st,dscr]=sldvTestLicense(~,~)




    dscr='not available when Simulink Test is not installed';

    if Simulink.harness.internal.isInstalled()...
        &&Simulink.harness.internal.licenseTest()
        st=configset.internal.data.ParamStatus.Normal;
    else
        st=configset.internal.data.ParamStatus.UnAvailable;
    end

