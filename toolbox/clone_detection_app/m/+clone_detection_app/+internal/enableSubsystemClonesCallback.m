function enableSubsystemClonesCallback(cbinfo,~)






    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');
    if~isempty(ui)
        ui.enableClonesAnywhere=~ui.enableClonesAnywhere;
        ui.setRegionSizeEnable(ui.enableClonesAnywhere);
        ui.setCloneGroupSizeEnable(ui.enableClonesAnywhere);
    end
end
