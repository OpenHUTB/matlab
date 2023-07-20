function enableSubsystemClonesFresher(cbinfo,action)






    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');
    if~isempty(ui)
        action.selected=ui.enableClonesAnywhere;
    end
end
