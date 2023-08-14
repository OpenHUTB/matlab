function replaceExactClonesCallBack(cbinfo,~)





    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');
    if(~isempty(ui))
        ui.isReplaceExactCloneWithSubsysRef=~ui.isReplaceExactCloneWithSubsysRef;
        ui.toolstripCtx.enableParameterThreshold=~ui.isReplaceExactCloneWithSubsysRef;
        ui.toolstripCtx.isReplaceExactCloneWithSubsysRef=ui.isReplaceExactCloneWithSubsysRef;
        ui.toolstripCtx.enableMatchPatternsFromLib=~ui.isReplaceExactCloneWithSubsysRef;



        if ui.isReplaceExactCloneWithSubsysRef
            ui.parameterThreshold_old=ui.parameterThreshold;
            ui.parameterThreshold='0';
        else
            ui.parameterThreshold=ui.parameterThreshold_old;
        end
        ui.toolstripCtx.parameterThreshold=ui.parameterThreshold;
    end
end
