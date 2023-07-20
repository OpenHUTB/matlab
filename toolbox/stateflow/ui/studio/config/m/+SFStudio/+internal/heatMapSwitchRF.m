function heatMapSwitchRF(cbInfo,action)





    action.enabled=false;
    action.selected=false;
    if~Stateflow.HeatMap.HeatMapToolStripManager.isHeatMapFeatureSwitchOn()
        return;
    end
    [machineName,status]=SFStudio.internal.extractMachineInfo(cbInfo);

    if isempty(machineName)
        return;
    end

    if bdIsSubsystem(machineName)

        return;
    end

    isMachineOpenAsRefModel=SFStudio.internal.isModelRef(cbInfo,machineName);

    if isMachineOpenAsRefModel
        return;
    end


    bd=cbInfo.studio.App.blockDiagramHandle;
    name=get_param(bd,'Name');
    if~strcmp(name,machineName)
        return;
    end

    action.enabled=status.enabled;
    if action.enabled
        action.selected=Stateflow.HeatMap.HeatMapToolStripManager.isHeatMapOnByUserFor(machineName);
    end
end
