function enabled=modelBreakpointRF(cbinfo,breakpointType)




    model=cbinfo.editorModel;
    if isempty(model)||...
        ~isa(breakpointType,'slbreakpoints.datamodel.ModelBreakpointType')
        return;
    end

    simulationStatus=model.SimulationStatus;

    if strcmpi(simulationStatus,'stopped')&&...
        ~SLStudio.toolstrip.internal.isModelBreakpointEnabled(breakpointType)
        enabled=true;
    else
        enabled=false;
    end
end

