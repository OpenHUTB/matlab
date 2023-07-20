function registerCallback()



    persistent isRegistered
    if isempty(isRegistered)
        isRegistered=false;
    end

    if~isRegistered&&dig.isProductInstalled('Simulink')
        Simulink.dd.private.AddDDMgrMATLABCallBackEventHandler('rmi_dd_callback');
        isRegistered=true;

        if rmi.isInstalled


            ddFilePaths=Simulink.dd.getOpenDictionaryPaths();
            for i=1:length(ddFilePaths)
                slreq.internal.delayedLinksetLoader('delay',ddFilePaths{i});
            end
        end
    end
end
