function conditionalPauseListRF(cbinfo,action)




    model=cbinfo.editorModel;
    if isempty(model),return;end

    simulationStatus=model.SimulationStatus;

    if~SLStudio.toolstrip.internal.isSimulationSteppingEnabled(cbinfo)||...
        ~cbinfo.domain.areSimulinkControlItemsVisible(model.handle)||...
        (strcmpi(simulationStatus,'running')&&...
        ~SLStudio.toolstrip.internal.isPausedInDebugLoop(cbinfo))

        action.enabled=false;
    else
        action.enabled=true;
    end
end
