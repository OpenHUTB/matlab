function SurgeArresterCback(block)






    aMaskObj=Simulink.Mask.get(block);
    AdvancedTab=aMaskObj.getDialogControl('Advanced');

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    if PowerguiInfo.Continuous||PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
        AdvancedTab.Visible='off';
    else
        if PowerguiInfo.AutomaticDiscreteSolvers
            AdvancedTab.Visible='off';
        else
            AdvancedTab.Visible='on';
        end
    end

    MV=get_param(block,'MaskVisibilities');
    if strcmp(get_param(block,'BreakLoop'),'on')
        MV{9}='off';
    else
        MV{9}='on';
    end
    set_param(block,'MaskVisibilities',MV);