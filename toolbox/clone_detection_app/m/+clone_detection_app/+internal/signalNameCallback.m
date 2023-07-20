function signalNameCallback(cbinfo,~)



    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');
    if~isempty(ui)
        ui.ignoreSignalName=~ui.ignoreSignalName;
    end
end
