function Excluderefresher(cbinfo,action)



    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');

    if~isempty(ui)
        exclusion=ui.getExclusions(sysHandle);

        if ui.excludeLibraries||ui.excludeModelReferences||...
            ui.excludeInactiveRegions||~isempty(exclusion)
            action.selected=1;
        else
            action.selected=0;
        end
    end
end