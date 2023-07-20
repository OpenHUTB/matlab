function blockPropertyCallback(cbinfo,~)



    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');
    if~isempty(ui)
        ui.ignoreBlockProperty=~ui.ignoreBlockProperty;
    end
end