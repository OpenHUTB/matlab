function[status,dscr]=extModeOptionsVisible(cs,paramName)






    dscr='';

    if isa(cs,'Simulink.ConfigSet')
        rtw=cs.getComponent('Code Generation');
        tgt=rtw.getComponent('Target');
    elseif isa(cs,'Simulink.RTWCC')
        tgt=cs.getComponent('Target');
    elseif isa(cs,'Simulink.TargetCC')
        tgt=cs;
    end

    if strcmp(paramName,'ExtMode')

        extModeOptionsVisible=true;
    else


        extmode=strcmp(tgt.getProp('ExtMode'),'on');
        extModeOptionsVisible=extmode;
    end

    if cs.isValidParam('OnTargetOneClick')
        oneclick=coder.oneclick.Utils.isOneClickWorkflowEnabled(cs);
    else
        oneclick=false;
    end

    if oneclick





        try
            targetHookObj=coder.oneclick.TargetHook.createOneClickTargetHookObject(cs);
            extModeOptionsVisible=targetHookObj.areExtModeOptionsVisible;
        catch ME
            if strcmp(ME.identifier,'Simulink:Extmode:OneClickUnsupportedModelConfiguration')

                if coder.oneclick.Utils.isCustomHWFeaturedOn
                    targetHookObj=coder.oneclick.TargetHook.createOneClickTargetHookObject(cs.getConfigSetSource);
                    extModeOptionsVisible=targetHookObj.areExtModeOptionsVisible;
                end
            else


                disp(ME.getReport);
            end
        end
    end

    if extModeOptionsVisible
        status=configset.internal.data.ParamStatus.Normal;
    else
        status=configset.internal.data.ParamStatus.InAccessible;
    end

end
