function blockPropertyFresher(cbinfo,action)



    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');
    if~isempty(ui)
        if ui.ignoreBlockProperty
            action.selected=1;
        else
            action.selected=0;
        end
    end
end