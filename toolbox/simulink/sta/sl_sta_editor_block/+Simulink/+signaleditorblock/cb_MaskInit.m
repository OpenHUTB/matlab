function cb_MaskInit(blockPath)






    SignalEditorBlockUniqueFeature=false;


    aMaskObj=Simulink.Mask.get(blockPath);

    isFastRestartOn=Simulink.signaleditorblock.isFastRestartOn(blockPath);
    map=Simulink.signaleditorblock.ListenerMap.getInstance;
    UIDataModel=map.getListenerMap(num2str(getSimulinkBlockHandle(blockPath),32));
    BlockDataModel=get_param([blockPath,'/Model Info'],'UserData');
    scenarioListBeforeUpdate=BlockDataModel.getScenarioList;
    scenarioBeforeUpdate=BlockDataModel.getScenario;
    signalListBeforeUpdate=BlockDataModel.getSignalsForScenario(scenarioBeforeUpdate);
    preserveSignalNameBeforeUpdate=BlockDataModel.getPreserveSignalName;

    if isempty(UIDataModel)




        dataModel=copy(BlockDataModel);
        dataModel.isUpdated=false;
    else
        dataModel=UIDataModel;
    end

    if SignalEditorBlockUniqueFeature&&strcmp(class(dataModel),'Simulink.signaleditorblock.model.SignalEditorBlock')






        newDataModel=Simulink.signaleditorblock.model.SignalEditorBlockUnique();
        newDataModel.importFromSignalEditorBlock(dataModel);
        dataModel=newDataModel;
    end


    blockProperties=Simulink.signaleditorblock.model.SignalEditorBlock.createBlockProperties(blockPath);
    if strcmp(blockProperties.Signal.SampleTime,'')
        return;
    end
    try
        dataModel.updateDataModel(blockProperties);
    catch ME
        set_param([blockPath,'/Model Info'],'UserDataPersistent','on');
        set_param([blockPath,'/Model Info'],'UserData',copy(dataModel));
        if strcmp(ME.identifier,'sl_sta_editor_block:message:LaunchSignalEditorCreateNewFile')
            suggestion=message('sl_sta_editor_block:message:LaunchSignalEditorAction',...
            num2str(getSimulinkBlockHandle(blockPath),32));
            ex=message('sl_sta_editor_block:message:NonExistentFile','untitled.mat');
            msg=MSLException(getSimulinkBlockHandle(blockPath),ex,'ACTION',MSLDiagnostic(suggestion));
        else
            msg=MSLException(getSimulinkBlockHandle(blockPath),ME);
        end
        throwAsCaller(msg);
    end




    scenarioNames=dataModel.getScenarioList;
    if isempty(scenarioNames)
        fileName=Simulink.signaleditorblock.FileUtil.getFullFileNameForBlock(blockPath);
        msg=MSLException(getSimulinkBlockHandle(blockPath),message('sl_sta_editor_block:message:NoScenarios',fileName));
        throwAsCaller(msg);
    end


    dataScenarioName=dataModel.getScenario;
    activeScenarioName=get_param(blockPath,'ActiveScenario');
    aMaskObj.Parameters(2).TypeOptions=scenarioNames;
    if~strcmp(dataScenarioName,activeScenarioName)



        set_param(blockPath,'ActiveScenario',dataScenarioName);
        activeScenarioName=dataScenarioName;
    end


    if~any(strcmp(activeScenarioName,scenarioNames))
        throw(MException(message('sl_sta_editor_block:message:NonExistentScenario',activeScenarioName)));
    end


    if length(scenarioListBeforeUpdate)~=length(scenarioNames)




        if~isFastRestartOn
            numberOfScenariosParam=aMaskObj.getParameter('NumberOfScenarios');
            numberOfScenariosParam.Value=num2str(length(scenarioNames));
        else
            set_param(blockPath,'NumberOfScenarios',num2str(length(scenarioNames)));
        end
    end


    SignalsForActiveScenario=getSignalsForScenario(dataModel,activeScenarioName);
    if isempty(SignalsForActiveScenario)
        msg=MSLException(getSimulinkBlockHandle(blockPath),...
        message('sl_sta_editor_block:message:EmptyScenario',activeScenarioName));
        throwAsCaller(msg);
    end
    if any(strcmp(SignalsForActiveScenario,''))
        suggestion=message('sl_sta_editor_block:message:LaunchSignalEditorAction',...
        num2str(getSimulinkBlockHandle(blockPath),32));
        ex=message('sl_sta_editor_block:message:EmptySignalNames');
        msg=MSLException(getSimulinkBlockHandle(blockPath),ex,'ACTION',MSLDiagnostic(suggestion));
        throwAsCaller(msg);
    end
    if length(unique(SignalsForActiveScenario))~=length(SignalsForActiveScenario)
        suggestion=message('sl_sta_editor_block:message:LaunchSignalEditorAction',...
        num2str(getSimulinkBlockHandle(blockPath),32));
        ex=message('sl_sta_editor_block:message:DuplicateSignalsNotSupported');
        msg=MSLException(getSimulinkBlockHandle(blockPath),ex,'ACTION',MSLDiagnostic(suggestion));
        throwAsCaller(msg);
    end


    if length(signalListBeforeUpdate)~=length(SignalsForActiveScenario)
        if~isFastRestartOn
            numberOfSignalsParam=aMaskObj.getParameter('NumberOfSignals');
            numberOfSignalsParam.Value=num2str(length(SignalsForActiveScenario));
        else
            set_param(blockPath,'NumberOfSignals',num2str(length(SignalsForActiveScenario)));
        end
    end

    if isFastRestartOn


        portHandles=get_param(blockPath,'PortHandles');
        currentOutputPorts=portHandles.Outport;
        if length(currentOutputPorts)~=length(SignalsForActiveScenario)


            msg=MSLException(getSimulinkBlockHandle(blockPath),...
            message('sl_sta_editor_block:message:FastRestart_Error'));
            msg=msg.addCause(MException(...
            message('sl_sta_editor_block:message:FastRestart_NumberOfPortsMismatch')));


            Simulink.signaleditorblock.SimulationData.removeSimulationDataFromHashMap(blockPath);
            throwAsCaller(msg);
        end
    end


    ports=get_param(blockPath,'Ports');
    numOfOutputPorts=ports(2);
    if length(signalListBeforeUpdate)~=length(SignalsForActiveScenario)||...
        numOfOutputPorts~=length(SignalsForActiveScenario)||...
        any(~strcmp(signalListBeforeUpdate,SignalsForActiveScenario))||...
        ~strcmp(preserveSignalNameBeforeUpdate,get_param(blockPath,'PreserveSignalName'))
        Simulink.signaleditorblock.updateSubSystemForGivenScenario(blockPath,dataModel);
    end


    currActiveSignal=get_param(blockPath,'ActiveSignal');
    aMaskObj.Parameters(3).TypeOptions=SignalsForActiveScenario;
    if~strcmp(scenarioBeforeUpdate,activeScenarioName)||...
        ~isequal(signalListBeforeUpdate,SignalsForActiveScenario)||...
        dataModel.isUpdated






        if~isempty(SignalsForActiveScenario)
            if~any(strcmp(currActiveSignal,SignalsForActiveScenario))
                set_param(blockPath,'ActiveSignal',SignalsForActiveScenario{1});
                currActiveSignal=SignalsForActiveScenario{1};


                blockProperties=Simulink.signaleditorblock.model.SignalEditorBlock.createBlockProperties(blockPath);
                dataModel.updateDataModel(blockProperties);
            end
        end
    end


    if~any(strcmp(currActiveSignal,SignalsForActiveScenario))
        throwAsCaller(MException(message('sl_sta_editor_block:message:NonExistentSignal',currActiveSignal,activeScenarioName)));
    end



    Simulink.signaleditorblock.activateSignal(blockPath,dataModel);

    if isFastRestartOn

        Exceptions={};



        outPortHandles=find_system(blockPath,'findall','on',...
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
        for id=1:length(SignalsForActiveScenario)
            newSignalProperties=getSignalProperties(dataModel,SignalsForActiveScenario{id});
            portHandles=tempMap(['out_',SignalsForActiveScenario{id}]);
            fromWsBlock=portHandles(1);
            outBlk=portHandles(2);
            workSpaceBlockProperties={
            'SampleTime','Interpolate','ZeroCross','OutputAfterFinalValue'
            };

            for fwsid=1:length(workSpaceBlockProperties)
                if~strcmp(get_param(fromWsBlock,workSpaceBlockProperties{fwsid}),...
                    newSignalProperties.(workSpaceBlockProperties{fwsid}))
                    Exceptions{end+1}=MException(message('sl_sta_editor_block:message:FastRestart_BlockPropertyMismatch',...
                    workSpaceBlockProperties{fwsid},...
                    get_param(outBlk,'Port'),...
                    get_param(fromWsBlock,workSpaceBlockProperties{fwsid}),...
                    newSignalProperties.(workSpaceBlockProperties{fwsid})));%#ok<*AGROW>
                end
            end

            if strcmp(newSignalProperties.IsBus,'on')

                if~strcmp(get_param(fromWsBlock,'OutDataTypeStr'),...
                    newSignalProperties.BusObject)
                    if strcmp(get_param(fromWsBlock,'OutDataTypeStr'),'Inherit: auto')
                        Exceptions{end+1}=MException(message('sl_sta_editor_block:message:FastRestart_NonBusToBus',...
                        get_param(outBlk,'Port')));
                    else
                        Exceptions{end+1}=MException(message('sl_sta_editor_block:message:FastRestart_BusObjectMismatch',...
                        get_param(outBlk,'Port'),...
                        get_param(fromWsBlock,'OutDataTypeStr'),...
                        newSignalProperties.BusObject));
                    end
                end
            else
                if~strcmp(newSignalProperties.BusObject,'Bus: BusObject')
                    Exceptions{end+1}=MException(message('sl_sta_editor_block:message:BusObjectSpecifiedForNonBusSignal',get_param(outBlk,'Port')));
                end


                if contains(get_param(fromWsBlock,'OutDataTypeStr'),'Bus')
                    Exceptions{end+1}=MException(message('sl_sta_editor_block:message:FastRestart_BusToNonBus',get_param(outBlk,'Port')));
                end
            end

            outPortProperties={
'Unit'
            };
            for outid=1:length(outPortProperties)
                if~strcmp(get_param(outBlk,outPortProperties{outid}),...
                    newSignalProperties.(outPortProperties{outid}))
                    Exceptions{end+1}=MException(message('sl_sta_editor_block:message:FastRestart_BlockPropertyMismatch',...
                    outPortProperties{outid},...
                    get_param(outBlk,'Port'),...
                    get_param(outBlk,outPortProperties{outid}),...
                    newSignalProperties.(outPortProperties{outid})));
                end
            end
        end
        if~isempty(Exceptions)
            msg=MSLException(getSimulinkBlockHandle(blockPath),...
            message('sl_sta_editor_block:message:FastRestart_Error'));
            for exID=1:length(Exceptions)
                msg=msg.addCause(Exceptions{exID});
            end

            Simulink.signaleditorblock.SimulationData.removeSimulationDataFromHashMap(blockPath);
            throwAsCaller(msg);
        end
    end


    dataModel.isUpdated=false;
    set_param([blockPath,'/Model Info'],'UserDataPersistent','on');
    if~isempty(UIDataModel)
        set_param([blockPath,'/Model Info'],'UserData',copy(dataModel));
    else
        set_param([blockPath,'/Model Info'],'UserData',dataModel);
    end


    dlgs=Simulink.signaleditorblock.getDialogFromBlockHandle(get_param(blockPath,'handle'));
    for dlgid=1:length(dlgs)
        dlg=dlgs(dlgid);
        dlg.refresh();
    end
    if isempty(dlgs)


        map=Simulink.signaleditorblock.ListenerMap.getInstance;
        map.removeListener(num2str(getSimulinkBlockHandle(blockPath),32));
    end





    simStatus=get_param(bdroot(blockPath),'SimulationStatus');
    if isFastRestartOn||strcmp(simStatus,'updating')
        Simulink.signaleditorblock.SimulationData.removeSimulationDataFromHashMap(blockPath);
    end

end
