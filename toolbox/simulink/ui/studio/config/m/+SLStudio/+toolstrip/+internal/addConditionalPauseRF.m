function addConditionalPauseRF(cbinfo,action)




    action.enabled=false;

    model=cbinfo.editorModel;
    if isempty(model),return;end

    featOn=slfeature('slDebuggerSimStepperIntegration')>1;
    if featOn>0
        block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    else
        block=[];
    end

    signalLine=SLStudio.Utils.getSingleSelectedLine(cbinfo);
    if isempty(signalLine)&&isempty(block)
        return;
    end

    if~isempty(signalLine)
        srcPort=SLStudio.Utils.getLineSourcePort(signalLine);
        if(isempty(srcPort)||~SLStudio.Utils.objectIsValidPort(srcPort)),return;end
    end

    simulationStatus=model.SimulationStatus;

    if~SLStudio.toolstrip.internal.isSimulationSteppingEnabled(cbinfo)||...
        ~cbinfo.domain.areSimulinkControlItemsVisible(model.handle)||...
        (strcmpi(simulationStatus,'running')&&...
        ~SLStudio.toolstrip.internal.isPausedInDebugLoop(cbinfo))||...
        (~isempty(signalLine)&&strcmpi(signalLine.type,'Connection'))


        action.enabled=false;
    else
        action.enabled=true;
    end
end
