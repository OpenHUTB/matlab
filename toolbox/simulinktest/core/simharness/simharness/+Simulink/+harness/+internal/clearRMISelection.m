function clearRMISelection(systemModelH,harnessModelH,isSSHarness)
    try
        if rmi.isInstalled()
            rmisl.intraLinkMenus({});

            if isSSHarness&&~Simulink.harness.internal.isSavedIndependently(systemModelH)
                if strcmp(get_param(harnessModelH,'hasReqInfo'),'on')
                    set_param(systemModelH,'hasReqInfo','on');
                end
            end
        end
    catch ME

    end
end
