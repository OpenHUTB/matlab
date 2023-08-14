function cb_InitFcn(blockPath)






    try
        Simulink.signaleditorblock.MaskSetting.enableMaskInitialization(blockPath);
    catch ME
        if~isempty(ME.cause)
            throwAsCaller(ME.cause{1});
        else
            throwAsCaller(ME);
        end
    end



    scenarioName=get_param(blockPath,'ActiveScenario');
    dataModel=get_param([blockPath,'/Model Info'],'UserData');
    signals=dataModel.getSignalsForScenario(scenarioName);
    Simulink.signaleditorblock.SimulationData.addSimulationDataToHashMap(blockPath);



    preserve_dirty_state=Simulink.PreserveDirtyFlag(bdroot(blockPath),'blockDiagram');




    outPortHandles=find_system(blockPath,...
    'findall','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'Parent',blockPath,...
    'BlockType','Outport');
    tempMap=containers.Map;
    for id=1:length(outPortHandles)
        outH=outPortHandles(id);
        tag=get_param(outH,'Tag');
        pc=get_param(outH,'PortConnectivity');
        wsH=pc.SrcBlock;
        tempMap(tag)=[wsH,outH];
    end

    for id=1:length(signals)
        portHandles=tempMap(['out_',signals{id}]);
        fromWsBlock=portHandles(1);
        outBlk=portHandles(2);
        SignalProperties=getSignalProperties(dataModel,signals{id});
        try
            IsBus=SignalProperties.IsBus;
            OutDataTypeStr='Inherit: auto';
            if strcmp(IsBus,'on')
                OutDataTypeStr=SignalProperties.BusObject;
                if strcmpi(OutDataTypeStr,'Bus: OutputBusObjectStr')
                    msg=MSLException(getSimulinkBlockHandle(blockPath),message('sl_sta_editor_block:message:ReservedBusObjectProperty',signals{id}));
                    throw(msg);
                end
            end
            encodedBlockPath=matlab.net.base64encode(unicode2native(blockPath));
            cmd=sprintf('Simulink.signaleditorblock.SimulationData.getData(''%s'',''%d'')',encodedBlockPath,id);
            set_param(fromWsBlock,'VariableName',cmd,...
            'SampleTime',SignalProperties.SampleTime,...
            'Interpolate',SignalProperties.Interpolate,...
            'ZeroCross',SignalProperties.ZeroCross,...
            'OutputAfterFinalValue',SignalProperties.OutputAfterFinalValue,...
            'OutDataTypeStr',OutDataTypeStr);
            set_param(outBlk,'Unit',SignalProperties.Unit);
        catch ME
            Simulink.signaleditorblock.SimulationData.removeSimulationDataFromHashMap(blockPath);
            if~isempty(ME.cause)
                throwAsCaller(ME.cause{1});
            else
                throwAsCaller(ME);
            end
        end
    end

    delete(preserve_dirty_state);
end
