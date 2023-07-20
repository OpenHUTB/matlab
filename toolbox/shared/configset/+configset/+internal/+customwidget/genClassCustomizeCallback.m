function updateDeps=genClassCustomizeCallback(cs,~)



    updateDeps=false;
    if~ecoderinstalled()
        DAStudio.error('RTW:makertw:licenseUnavailable',...
        get_param(cs,'SystemTargetFile'));
    end
    model=cs.getModel;
    coder.internal.launchCPPFunctionPrototypeControl(model);
