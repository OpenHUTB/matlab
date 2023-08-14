function replaceExactClonesFresher(cbinfo,action)



    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');
    if~isempty(ui)
        if ui.isReplaceExactCloneWithSubsysRef
            action.selected=1;
        else
            action.selected=0;
        end
    end
end