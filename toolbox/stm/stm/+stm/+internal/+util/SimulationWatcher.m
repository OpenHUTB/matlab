classdef SimulationWatcher<handle





    properties



        closeModel=true;
        fastRestart=false;

        isIteration=false;



        isFirstIteration=true;


        simModel=[];
        mainModel='';
        modelToRun='';
        simMode='';

        harnessString='';
        harnessName='';
        ownerName='';
        currHarness=[];
        oldHarness=[];
        wasHarnessOpen=false;
        deactivateHarness=false;
        componentUnderTest='';
        modelsAlreadyLoaded={};







        modelSharingStatus=-1;









        refreshErrorMSG='';
        refreshParameterOverrides=[];
        refreshErrorMSGList={};
        refreshErrorMSGMap=[];
        coverage;

        testCaseId=[];
        permutationId=[];
        modelLoggingInfo=[];
        modelLoggingInfoDone=false;


        originalTopModelDirty='off';

        configName='';
        configRefPath='';
        configVarName='';


        cleanupTestCase=[];


        cleanupIteration=[];


        initFailed=false;
        initErrors=[];

        revertingFailed=false;
        revertingErrors=[];

        modelResolved=false;
        testCaseSimSettingApplied=false;
        coverageSettingApplied=false;

        signalBuilderBlock=[];

        NeedSubsystemManager=false;
        SubsystemManager=[];

        slicerDebugPreventHarnessClose=false;
    end

    methods
        function obj=SimulationWatcher(modelName,harnessString)
            if nargin==0,modelName='';harnessString='';end
            obj.revertingErrors.messages={};
            obj.revertingErrors.errorOrLog={};

            obj.initErrors.messages={};
            obj.initErrors.errorOrLog={};


            obj.mainModel=modelName;
            if isempty(modelName)
                msg=stm.internal.MRT.share.getString(('stm:general:NoModelSpecified'));
                obj.initErrors.messages{end+1}=msg;
                obj.initErrors.errorOrLog{end+1}=true;
                obj.initFailed=true;
            end
            obj.harnessString=harnessString;

            obj.refreshParameterOverrides=struct(...
            'PermutationId',-1,'RefreshResult',[]);


            obj.refreshErrorMSGMap=containers.Map(0,?handle);
            obj.refreshErrorMSGMap.remove(0);
        end

        function setProperty(obj,propertyName,value)
            obj.(propertyName)=value;
        end

        function value=getProperty(obj,propertyName)
            value=obj.(propertyName);
        end

        function resolveModelToRun(obj)

            [obj.modelToRun,obj.deactivateHarness,obj.currHarness,...
            obj.oldHarness,obj.wasHarnessOpen,obj.harnessName,obj.ownerName,obj.componentUnderTest]=...
            stm.internal.util.resolveModelToRun(obj.mainModel,obj.harnessString);

            if(~strcmp(obj.modelToRun,obj.mainModel))
                obj.simModel.HarnessName=obj.modelToRun;
            end
            obj.modelResolved=true;
        end



        function restoreHarness(obj)
            if~isempty(obj.currHarness)
                if~obj.slicerDebugPreventHarnessClose
                    close_system(obj.currHarness.name,0);
                end

                if obj.closeModel&&bdIsLoaded(obj.mainModel)
                    if(~strcmp(get_param(obj.mainModel,'Lock'),'on'))
                        set_param(obj.mainModel,'Dirty',obj.originalTopModelDirty);
                    end
                end


                if(obj.deactivateHarness)
                    stm.internal.util.loadHarness(obj.oldHarness.ownerFullPath,obj.oldHarness.name,obj.wasHarnessOpen);
                end
            end



            if isempty(obj.currHarness)&&~isempty(obj.simModel)&&...
                strcmp(obj.modelToRun,obj.simModel.Model)&&~isempty(obj.oldHarness)



                stm.internal.util.loadHarness(obj.oldHarness.ownerFullPath,obj.oldHarness.name,obj.wasHarnessOpen);
            end
            obj.modelResolved=false;
        end

        function restoreReferencedModels(obj)



            modelsCurrentlyLoaded=find_system('type','block_diagram');
            modelsToIgnore={obj.modelToRun;obj.mainModel};
            refModelsToClose=setdiff(modelsCurrentlyLoaded,[obj.modelsAlreadyLoaded;modelsToIgnore]);
            bdclose(refModelsToClose);
        end

        function delete(obj)
            if(isa(obj.simModel,'stm.internal.util.SimulinkModel'))
                obj.simModel.delete();
            end
            obj.simModel=[];
        end


        function revertIterationSettings(obj)
            poWrapper=stm.internal.Parameters.ParameterOverrideWrapper;
            if(isempty(obj.cleanupIteration)||~isstruct(obj.cleanupIteration))
                return;
            end
            mdl=obj.modelToRun;
            cleanupStruct=obj.cleanupIteration;


            if(isfield(cleanupStruct,'LoadExternalInput')&&~isempty(cleanupStruct.LoadExternalInput))
                set_param(mdl,'LoadExternalInput',cleanupStruct.LoadExternalInput);
            end

            if(isfield(cleanupStruct,'ExternalInput'))
                set_param(mdl,'ExternalInput',cleanupStruct.ExternalInput);
            end

            if isfield(cleanupStruct,'StopTime')&&~isempty(cleanupStruct.StopTime)
                set_param(mdl,'StopTime',cleanupStruct.StopTime);
            end

            if(isfield(cleanupStruct,'SignalBuilder')&&isfield(cleanupStruct,'SigBuilderIndex')...
                &&~isempty(cleanupStruct.SignalBuilder)&&~isempty(cleanupStruct.SigBuilderIndex))



                block=stm.internal.blocks.SignalSourceBlock.getBlock(cleanupStruct.SignalBuilder);


                block.delete(cleanupStruct.SigBuilderIndex);
            end

            if(isfield(cleanupStruct,'prevScenarioParamInitVal')&&isfield(cleanupStruct,'testSeqPath')...
                &&~isempty(cleanupStruct.testSeqPath))
                tsBlockPath=cleanupStruct.testSeqPath;
                rt=sfroot();
                chart=rt.find('-isa','Stateflow.ReactiveTestingTableChart','Path',tsBlockPath);
                sttman=Stateflow.STT.StateEventTableMan(chart.Id);
                viewManager=sttman.viewManager;
                viewManager.scenarioParamVal(cleanupStruct.prevScenarioParamInitVal);
            end

            if isfield(cleanupStruct,'VarsLoaded')&&~isempty(cleanupStruct.VarsLoaded)
                evalin('base',['clear ',char(strjoin(cleanupStruct.VarsLoaded))]);
            end

            if(isfield(cleanupStruct,'ParamOverrides'))
                paramOverrides=cleanupStruct.ParamOverrides;
                poWrapper.resetOverridenParameters(paramOverrides.hModelWorkspace,...
                paramOverrides.overridesStruct,...
                paramOverrides.originalValues,...
                paramOverrides.dataDictionaryStates,...
                paramOverrides.modelWorkspaceDirtyState,...
                paramOverrides.modelToRun,obj.cleanupTestCase.Dirty);
            end

            if isfield(cleanupStruct,'InstrumentedSignals')
                obj.revertInstrumentedSignals(cleanupStruct.InstrumentedSignals);
                cleanupStruct.InstrumentedSignals=[];
            end

            if isfield(cleanupStruct,'DSMLoggingOverrides')&&~isempty(cleanupStruct.DSMLoggingOverrides)
                obj.revertDSMLoggingOverrides(cleanupStruct.DSMLoggingOverrides);
                cleanupStruct.DSMLoggingOverrides=[];
            end

            if(isfield(cleanupStruct,'ModelParameters'))
                iterationWrapper=stm.internal.util.TestIterationWrapper;
                iterationWrapper.resetIterationModelParameters(cleanupStruct.ModelParameters.originalValues);
            end

            if(isfield(cleanupStruct,'VariableParameters'))
                variableOverrides=cleanupStruct.VariableParameters;
                poWrapper.resetOverridenParameters(...
                variableOverrides.hModelWorkspace,...
                variableOverrides.overridesStruct,...
                variableOverrides.originalValues,...
                variableOverrides.dataDictionaryStates,...
                variableOverrides.modelWorkspaceDirtyState,...
                variableOverrides.modelToRun,obj.cleanupTestCase.Dirty);
            end

            if(isfield(cleanupStruct,'SignalBuilderGroups'))
                iterationWrapper=stm.internal.util.TestIterationWrapper;
                iterationWrapper.resetIterationSigBuilderGroups(cleanupStruct.SignalBuilderGroups.orignalValues);
            end
            obj.cleanupIteration=[];
        end



        function revertTestCaseSettings(obj,revertFastRestart)
            if(isempty(obj.cleanupTestCase)||~isstruct(obj.cleanupTestCase))
                return;
            end

            mdl=obj.modelToRun;
            cleanupStruct=obj.cleanupTestCase;

            if isfield(cleanupStruct,'SimulationMode')
                mdlToModify=mdl;
                if isfield(cleanupStruct,'SimulationModeAppliedOn')
                    mdlToModify=cleanupStruct.SimulationModeAppliedOn;
                end

                set_param(mdlToModify,'SimulationMode',cleanupStruct.SimulationMode);
                cleanupStruct.SimulationMode=[];
            end


            if(isfield(cleanupStruct,'InitializeInteractiveRuns')&&revertFastRestart)
                set_param(mdl,'InitializeInteractiveRuns',cleanupStruct.InitializeInteractiveRuns);
                cleanupStruct.InitializeInteractiveRuns=[];
            end

            if isfield(cleanupStruct,'FastRestartLoggedSignals')
                unmarkSignalsToLog(cleanupStruct.FastRestartLoggedSignals);
                cleanupStruct.FastRestartLoggedSignals=[];
            end


            if isfield(cleanupStruct,'removeConfigSet')||isfield(cleanupStruct,'removeConfigSet1')
                if isfield(cleanupStruct,'currConfigSet')
                    setActiveConfigSet(mdl,cleanupStruct.currConfigSet.Name);
                    cleanupStruct.currConfigSet=[];
                end



                if isfield(cleanupStruct,'removeConfigSet')
                    detachConfigSet(mdl,cleanupStruct.removeConfigSet);
                    cleanupStruct.removeConfigSet=[];
                end
                if isfield(cleanupStruct,'removeConfigSet1')
                    detachConfigSet(mdl,cleanupStruct.removeConfigSet1);
                    cleanupStruct.removeConfigSet1=[];
                end
                if isfield(cleanupStruct,'Dirty')
                    set_param(mdl,'Dirty',cleanupStruct.Dirty);
                    cleanupStruct.Dirty=[];
                end
            else

                if isfield(cleanupStruct,'SaveFormat')
                    set_param(mdl,'SaveFormat',cleanupStruct.SaveFormat);
                    cleanupStruct.SaveFormat=[];
                end
                if isfield(cleanupStruct,'ReturnWorkspaceOutputs')
                    set_param(mdl,'ReturnWorkspaceOutputs',cleanupStruct.ReturnWorkspaceOutputs);
                    cleanupStruct.ReturnWorkspaceOutputs=[];
                end
                if isfield(cleanupStruct,'SDIOptimizeVisual')
                    set_param(mdl,'SDIOptimizeVisual',cleanupStruct.SDIOptimizeVisual);
                    cleanupStruct.SDIOptimizeVisual=[];
                end
                if isfield(cleanupStruct,'StartTime')
                    set_param(mdl,'StartTime',cleanupStruct.StartTime);
                    cleanupStruct.StartTime=[];
                end
                if isfield(cleanupStruct,'StopTime')&&~isempty(cleanupStruct.StopTime)
                    set_param(mdl,'StopTime',cleanupStruct.StopTime);
                    cleanupStruct.StopTime=[];
                end
                if isfield(cleanupStruct,'LoadInitialState')
                    set_param(mdl,'LoadInitialState',cleanupStruct.LoadInitialState);
                    cleanupStruct.LoadInitialState=[];
                end
                if isfield(cleanupStruct,'InitialState')
                    set_param(mdl,'InitialState',cleanupStruct.InitialState);
                    cleanupStruct.InitialState=[];
                end
                if isfield(cleanupStruct,'GenerateReport')
                    set_param(mdl,'GenerateReport',cleanupStruct.GenerateReport);
                    cleanupStruct.GenerateReport=[];
                end

                if isfield(cleanupStruct,'SaveOutput')
                    set_param(mdl,'SaveOutput',cleanupStruct.SaveOutput);
                    cleanupStruct.SaveOutput=[];
                end
                if isfield(cleanupStruct,'SaveState')
                    set_param(mdl,'SaveState',cleanupStruct.SaveState);
                    cleanupStruct.SaveState=[];
                end
                if isfield(cleanupStruct,'SaveTime')
                    set_param(mdl,'SaveTime',cleanupStruct.SaveState);
                    cleanupStruct.SaveTime=[];
                end
                if isfield(cleanupStruct,'SaveFinalState')
                    set_param(mdl,'SaveFinalState',cleanupStruct.SaveFinalState);
                    cleanupStruct.SaveFinalState=[];
                end
                if isfield(cleanupStruct,'SignalLogging')
                    set_param(mdl,'SignalLogging',cleanupStruct.SignalLogging);
                    cleanupStruct.SignalLogging=[];
                end
                if isfield(cleanupStruct,'DSMLogging')
                    set_param(mdl,'DSMLogging',cleanupStruct.DSMLogging);
                    cleanupStruct.DSMLogging=[];
                end

                if isfield(cleanupStruct,'LoggingToFile')
                    set_param(mdl,'LoggingToFile',cleanupStruct.LoggingToFile);
                    cleanupStruct.LoggingToFile=[];
                end

                if isfield(cleanupStruct,'SignalLoggingName')
                    set_param(mdl,'SignalLoggingName',cleanupStruct.SignalLoggingName);
                    cleanupStruct.SignalLoggingName=[];
                end

                if isfield(cleanupStruct,'DatasetSignalFormat')
                    set_param(mdl,'DatasetSignalFormat',cleanupStruct.DatasetSignalFormat);
                    cleanupStruct.DatasetSignalFormat=[];
                end


                for i=1:length(stm.internal.Coverage.CoverageParams)
                    param=stm.internal.Coverage.CoverageParams{i};
                    if isfield(cleanupStruct,param)
                        set_param(mdl,param,cleanupStruct.(param));
                        cleanupStruct.(param)=[];
                    end
                end

                if isfield(cleanupStruct,'StreamToWorkspace')
                    set_param(mdl,'StreamToWorkspace',cleanupStruct.StreamToWorkspace);
                    cleanupStruct.StreamToWorkspace=[];
                end

                if isfield(cleanupStruct,'InspectSignalLogs')
                    set_param(mdl,'InspectSignalLogs',cleanupStruct.InspectSignalLogs);
                    cleanupStruct.InspectSignalLogs=[];
                end

                if isfield(cleanupStruct,'InstrumentedSignals')
                    obj.revertInstrumentedSignals(cleanupStruct.InstrumentedSignals);
                    cleanupStruct.InstrumentedSignals=[];
                end

                if isfield(cleanupStruct,'DSMLoggingOverrides')
                    obj.revertDSMLoggingOverrides(cleanupStruct.DSMLoggingOverrides);
                    cleanupStruct.DSMLoggingOverrides=[];
                end


                if isfield(cleanupStruct,'currConfigSet')
                    setActiveConfigSet(mdl,cleanupStruct.currConfigSet.Name);
                    cleanupStruct.currConfigSet=[];
                end

                if isfield(cleanupStruct,'Dirty')
                    set_param(mdl,'Dirty',cleanupStruct.Dirty);
                    cleanupStruct.Dirty=[];
                end

                allParameterReverted=true;
                fieldNames=fieldnames(cleanupStruct);
                for k=1:length(fieldNames)
                    value=cleanupStruct.(fieldNames{k});
                    if(~isempty(value))
                        allParameterReverted=false;
                        break;
                    end
                end
                if(allParameterReverted==false)
                    msg=stm.internal.MRT.share.getString('stm:ScriptsView:ModelNotFullyRestored',obj.modelToRun);
                    obj.revertingErrors.messages=[obj.revertingErrors.messages,msg];
                    obj.revertingErrors.errorOrLog=[obj.revertingErrors.errorOrLog,true];
                end
            end

            obj.cleanupTestCase=[];
            obj.testCaseSimSettingApplied=false;
            obj.coverageSettingApplied=false;
        end

        function revertSettings(obj,revertAll)
            try
                if~isempty(obj.SubsystemManager)
                    obj.SubsystemManager.workflowTeardown();
                    obj.SubsystemManager=[];
                end

                reuseTeseCaseSetting=true;

                if(obj.closeModel)


                    if(obj.fastRestart)
                        set_param(obj.modelToRun,'InitializeInteractiveRuns',...
                        obj.cleanupTestCase.InitializeInteractiveRuns);
                    end
                    reuseTeseCaseSetting=false;
                end



                obj.revertIterationSettings();


                if(obj.modelSharingStatus==1||obj.modelSharingStatus==4)
                    reuseTeseCaseSetting=false;
                end

                if(revertAll)
                    reuseTeseCaseSetting=false;
                end

                if(~reuseTeseCaseSetting)
                    obj.revertTestCaseSettings(false);
                end
            catch me

                msg=stm.internal.MRT.share.getString('stm:ScriptsView:ErrorOccurWhenRevertingModelChanges',obj.modelToRun);
                obj.revertingErrors.messages=[obj.revertingErrors.messages,msg];
                obj.revertingErrors.errorOrLog=[obj.revertingErrors.errorOrLog,true];

                [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
                obj.revertingErrors.messages=[obj.revertingErrors.messages,tempErrors];
                obj.revertingErrors.errorOrLog=[obj.revertingErrors.errorOrLog,tempErrorOrLog];
                obj.revertingFailed=true;



                if(obj.fastRestart&&isfield(obj.cleanupTestCase,'InitializeInteractiveRuns')&&...
                    strcmp(obj.cleanupTestCase.InitializeInteractiveRuns,'off'))

                    try
                        set_param(obj.modelToRun,'InitializeInteractiveRuns',...
                        obj.cleanupTestCase.InitializeInteractiveRuns);

                        obj.revertIterationSettings();
                        obj.revertTestCaseSettings(true);
                    catch
                    end
                end
            end

        end






        function refreshParameters(obj,permId)
            if(obj.refreshParameterOverrides.PermutationId>0)
                if(obj.refreshParameterOverrides.PermutationId~=permId)
                    stm.internal.MRT.share.error(('stm:ScriptsView:SimulationNotFoundInSimulationWatcher'));
                end
                return;
            end
            obj.refreshParameterOverrides.PermutationId=permId;

            refreshResult=stm.internal.refreshParameterOverrides(permId,obj.isIteration);
            obj.refreshParameterOverrides.RefreshResult=refreshResult.ParameterSets;



            if(~isempty(refreshResult.Errors))
                obj.refreshErrorMSG=refreshResult.Errors;
            end


            refreshResult=refreshResult.ParameterSets;
            for k=1:length(refreshResult)
                if(~isempty(refreshResult(k).ErrorMSGList))
                    total=length(obj.refreshErrorMSGList)+1;
                    obj.refreshErrorMSGList{total}=...
                    reshape(refreshResult(k).ErrorMSGList,1,length(refreshResult(k).ErrorMSGList));

                    theKey=refreshResult(k).ParameterSetID;
                    obj.refreshErrorMSGMap(theKey)=total;
                end
            end
        end






        function[errorMessages,newPOList]=updateParameterOverrides(obj,poList,runningOnMRT)
            newPOList=poList;

            nPOs=length(poList);
            if runningOnMRT
                params=struct('name',{poList.Name});
                fcn=@stm.internal.MRT.share.findVars;
            else
                params=[poList.NamedParamId];
                fcn=@stm.internal.Parameters.findVars;
            end
            [vars,errorMessages]=fcn(obj.modelToRun,obj.harnessName,params);
            if(~isempty(errorMessages))
                return;
            end


            varIndex=cell(nPOs,1);
            varMap=Simulink.sdi.Map(char('?'),int32(0));
            total=0;
            for k=1:length(vars)
                varName=vars{k}.Name;
                if(varMap.isKey(varName))
                    idx=varMap.getDataByKey(varName);
                    varIndex{idx}=[varIndex{idx},k];
                else
                    total=total+1;
                    varIndex{total}=k;
                    varMap.insert(varName,total);
                end
            end


            for varK=1:nPOs
                if(~isempty(newPOList(varK).Source)||~isempty(newPOList(varK).SourceType))
                    continue;
                end
                varName=newPOList(varK).Name;
                if(~varMap.isKey(varName))
                    continue;
                end

                idx=varMap.getDataByKey(varName);
                idxList=varIndex{idx};

                if(length(idxList)==1)

                    x=idxList(1);
                    if(isfield(vars{x},'SourceType')&&isfield(vars{x},'Source'))
                        newPOList(varK).SourceType=vars{x}.SourceType;
                        newPOList(varK).Source=vars{x}.Source;
                    else
                        msg=stm.internal.MRT.share.getString('stm:Parameters:CannotResolveOverrideParameter',...
                        varName,newPOList(varK).ParameterSetName);
                        errorMessages{end+1}=msg;
                    end
                    continue;
                end


                for k=1:length(idxList)
                    x=idxList(k);
                    if(strcmp(vars(x).SourceType,'model workspace')||...
                        strcmp(vars(x).SourceType,'base workspace')||...
                        strcmp(vars(x).SourceType,'data dictionary'))
                        newPOList(varK).SourceType=vars{x}.SourceType;
                        newPOList(varK).Source=vars{x}.Source;
                        break;
                    end
                end
            end
        end

        function msgList=prepareForIteratingSignalSetInFS(obj)
            msgList={};


            itrIdList=[];
            if(obj.fastRestart)
                itrIdList=stm.internal.getTestIterationsFromTestCase(obj.testCaseId,'',-1,true);
            end
            nIterations=length(itrIdList);

            if(obj.fastRestart&&nIterations>1)
                signalSetMap=Simulink.sdi.Map(char('?'),int32(0));
                loggedSignalSets=stm.internal.getLoggedSignalSets(obj.permutationId,true);
                for k=1:length(loggedSignalSets)
                    signalSetMap.insert(loggedSignalSets(k).Name,k);
                end


                itrLoggedSignalSetIdx=zeros(1,nIterations);
                if(~isempty(loggedSignalSets))
                    tmpTotal=0;
                    for itrK=1:nIterations
                        itr=sltest.testmanager.TestIteration();
                        itr.getIterationSettings(itrIdList(itrK));


                        mask=strcmp(cellfun(@(elem)elem{1},itr.TestParams,...
                        'Uniform',false),'LoggedSignalSet');
                        loggedSignalSet=itr.TestParams(mask);
                        if~isempty(loggedSignalSet)
                            tmpSetName=loggedSignalSet{1}{2};
                            if(~isempty(tmpSetName))
                                if(~signalSetMap.isKey(tmpSetName))
                                    msg=stm.internal.MRT.share.getString('stm:OutputView:LoggedSignalSetNotFound',tmpSetName,itr.Name);
                                    msgList{end+1}=msg;
                                    return;
                                end
                                idx=signalSetMap.getDataByKey(tmpSetName);
                                tmpTotal=tmpTotal+1;
                                itrLoggedSignalSetIdx(tmpTotal)=idx;
                            end
                        end
                    end
                end

                itrLoggedSignalSetIdx=unique(itrLoggedSignalSetIdx(itrLoggedSignalSetIdx>0));



                if(length(itrLoggedSignalSetIdx)>1)
                    allSignals=[];

                    signalIdMap=Simulink.sdi.Map(int32(0),int32(0));
                    for k=1:length(itrLoggedSignalSetIdx)
                        setK=itrLoggedSignalSetIdx(k);
                        setId=loggedSignalSets(setK).id;
                        tmpSignals=stm.internal.getLoggedSignals(setId,true,true);
                        for sigK=1:length(tmpSignals)
                            if(~signalIdMap.isKey(tmpSignals(sigK).id))
                                allSignals=[allSignals,tmpSignals(sigK)];
                                signalIdMap.insert(tmpSignals(sigK).id,length(allSignals));
                            end
                        end
                    end



                    [msgList,currInstrumentedSignals,dsmOverrides]=stm.internal.util.markOutputSignalsForStreaming(obj.modelToRun,allSignals);
                    if(~isfield(obj.cleanupTestCase,'InstrumentedSignals')||isempty(obj.cleanupTestCase.InstrumentedSignals))
                        obj.cleanupTestCase.InstrumentedSignals=containers.Map;
                    end
                    if(~isfield(obj.cleanupTestCase,'DSMLoggingOverrides')||isempty(obj.cleanupTestCase.DSMLoggingOverrides))
                        obj.cleanupTestCase.DSMLoggingOverrides=containers.Map;
                    end
                    obj.modelLoggingInfo=containers.Map;
                    models=currInstrumentedSignals.keys;
                    for i=1:length(models)
                        model=models{i};
                        if(~obj.cleanupTestCase.InstrumentedSignals.isKey(model))
                            obj.cleanupTestCase.InstrumentedSignals(model)=currInstrumentedSignals(model);
                        end
                        obj.modelLoggingInfo(model)=Simulink.SimulationData.ModelLoggingInfo(model);
                    end

                    models=dsmOverrides.keys;
                    for i=1:length(models)
                        if(~obj.cleanupTestCase.DSMLoggingOverrides.isKey(model))
                            obj.cleanupTestCase.DSMLoggingOverrides(model)=dsmOverrides(model);
                        end
                        obj.modelLoggingInfo(model)=Simulink.SimulationData.ModelLoggingInfo(model);
                    end
                end
                obj.modelLoggingInfoDone=true;
            end
        end

        function revertInstrumentedSignals(~,instrumentedSignals)
            models=instrumentedSignals.keys;
            for i=1:length(models)
                mdl=models{i};


                preserve_dirty=Simulink.PreserveDirtyFlag(get_param(mdl,'Handle'),'blockDiagram');

                instrumentedSignalsForMdl=instrumentedSignals(mdl);
                currLoggedSignals=stm.internal.MRT.share.getInstrumentedSignals(mdl);
                bHasHMIInstrumentedSignals=isa(currLoggedSignals,'Simulink.HMI.InstrumentedSignals')||...
                isa(instrumentedSignalsForMdl,'Simulink.HMI.InstrumentedSignals');

                if(bHasHMIInstrumentedSignals)
                    set_param(mdl,'InstrumentedSignals',instrumentedSignalsForMdl);
                else

                    for k=1:length(currLoggedSignals)
                        phs=get_param(currLoggedSignals(k).BlockPath,'PortHandles');
                        set_param(phs.Outport,'DataLogging','off');
                    end

                    for k=1:length(instrumentedSignalsForMdl)
                        phs=get_param(instrumentedSignalsForMdl(k).BlockPath,'PortHandles');
                        set_param(phs.Outport,'DataLogging','on');
                    end
                end

                clear preserve_dirty;
            end
        end

        function revertDSMLoggingOverrides(~,dsmLoggingOverrides)
            models=dsmLoggingOverrides.keys;
            for m_idx=1:length(models)

                preserve_dirty=Simulink.PreserveDirtyFlag(get_param(models{m_idx},'Handle'),'blockDiagram');


                dsmInfo=dsmLoggingOverrides(models{m_idx});
                dsmBlocks=dsmInfo.dsmBlocks;
                for dsmBlock=dsmBlocks
                    set_param(dsmBlocks{1},'DataLogging','off');
                end

                dsmVars=dsmInfo.dsmVars;
                for dsmVar=dsmVars
                    stm.internal.SignalLogging.setGlobalDataStoreLogging(dsmVar.Name,dsmVar.SourceType,false,models{m_idx});
                end

                clear preserve_dirty;
            end
        end
    end
end

function unmarkSignalsToLog(sigs)
    for idx=1:numel(sigs)
        bPath=sigs(idx).BlockPath.convertToCell;
        ph=get_param(bPath{end},'PortHandles');
        ph=ph.Outport(sigs(idx).OutputPortIndex);
        set_param(ph,'DataLogging','off');
    end
end
