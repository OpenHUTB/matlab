function addConditionalPauseCB(cbinfo)




    model=cbinfo.editorModel;
    if isempty(model),return;end

    featOn=slfeature('slDebuggerSimStepperIntegration')>0;
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

        portHandle=srcPort.handle;
        SLStudio.ShowAddConditionalPauseDialog(model.handle,portHandle);


    elseif~isempty(block)&&slfeature('slDebuggerSimStepperIntegration')>1
        blockPath=[get_param(block.handle,'Parent'),'/'...
        ,get_param(block.handle,'Name')];
        isEnabled=true;
        bpListInstance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
        BPID=bpListInstance.createBlockBPID(model.name,blockPath);
        bpListInstance.addBlockBreakpoint(model.Name,blockPath,BPID,isEnabled);
    end
end
