function tr=get









    if exist('isSimulinkStarted','builtin')&&isSimulinkStarted&&~coder.targetreg.internal.TargetRegistry.slCustomizerRegistrationsLoaded()
        sl_refresh_customizations;
    end

    tr=coder.targetreg.internal.TargetRegistry.getWithoutDataLoad();

