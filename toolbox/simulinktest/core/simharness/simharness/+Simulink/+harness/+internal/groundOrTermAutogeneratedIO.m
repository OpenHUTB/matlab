function groundOrTermAutogeneratedIO(harnessInfo)







    SSPorts=get_param(harnessInfo.Owner,'PortHandles');
    numSSInputs=numel(SSPorts.Inport);
    numSSOutputs=numel(SSPorts.Outport);
    for portCtr=1:numSSInputs
        signalHierarchy=get_param(SSPorts.Inport(portCtr),'SignalHierarchy');
        if signalHierarchy.BusObject==""&&...
            numel(signalHierarchy.Children)>1
            MSLDiagnostic('Simulink:Harness:UnableToGroundTermVirtualBus').reportAsWarning
            return
        end
    end

    for portCtr=1:numSSOutputs
        signalHierarchy=get_param(SSPorts.Outport(portCtr),'SignalHierarchy');
        if signalHierarchy.BusObject==""&&...
            numel(signalHierarchy.Children)>1
            MSLDiagnostic('Simulink:Harness:UnableToGroundTermVirtualBus').reportAsWarning
            return
        end
    end



    numExtractInputs=numel(harnessInfo.Sources);
    numExtractOutputs=numel(harnessInfo.Sinks);


    numSSInports=numSSInputs+numel(SSPorts.Enable)+...
    numel(SSPorts.Reset)+numel(SSPorts.Trigger);
    if(numExtractInputs>numSSInports)
        for portCtr=numSSInports+1:numExtractInputs
            inputHandle=get_param(harnessInfo.Sources(portCtr),'Handle');
            replace_block(harnessInfo.HarnessModel,...
            'Handle',inputHandle,...
            'built-in/Ground','noprompt')
        end
    end


    if(numExtractOutputs>numSSOutputs)
        for portCtr=numSSOutputs+1:numExtractOutputs
            outputHandle=get_param(harnessInfo.Sinks(portCtr),'Handle');
            replace_block(harnessInfo.HarnessModel,...
            'Handle',outputHandle,...
            'built-in/Terminator','noprompt')
        end
    end
end
