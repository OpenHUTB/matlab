


function simInEvaluateAndSimulate(simInStructCellArray,simWatchersCellArray,useParallel,resultSetId)


    [simInStructCellArray,simWatchersCellArray,paramsToRevertInSIL]=updateSimInputArrayForPerformance(simInStructCellArray,simWatchersCellArray);


    warnState=warning('off','backtrace');
    oc=onCleanup(@()warning(warnState));

    multiHarnessOpen=slfeature('MultipleHarnessOpen',1);
    cleanupFeatureSetting3=onCleanup(@()slfeature('MultipleHarnessOpen',multiHarnessOpen));

    currentFeat2=slfeature('SimulationMetadata',2);
    featureReset2=onCleanup(@()slfeature('SimulationMetadata',currentFeat2));



    modelsAlreadyLoaded=find_system('type','block_diagram','IsHarness','off','Open','off');
    modelsLockStatusMap=containers.Map;
    for i=1:length(modelsAlreadyLoaded)
        modelsLockStatusMap(modelsAlreadyLoaded{i})=get_param(modelsAlreadyLoaded{i},'Lock');
    end

    modelsAlreadyOpen=find_system('type','block_diagram','IsHarness','off','Open','on');
    modelsAlreadyDirty=find_system('type','block_diagram','Dirty','on');
    harnessesLoaded=find_system('type','block_diagram','IsHarness','on');
    harnessesAlreadyLoaded=find_system('type','block_diagram','IsHarness','on','Open','off');
    harnessesAlreadyOpen=find_system('type','block_diagram','IsHarness','on','Open','on');
    harnessOwnerMap=containers.Map;
    for i=1:length(harnessesLoaded)
        harnessOwnerMap(harnessesLoaded{i})=get_param(harnessesLoaded{i},'OwnerBDName');
    end



    [runCfgArray,simInStructCellArray,simWatchersCellArray]=stm.internal.SimulationInput.constructRunCfgArray(simInStructCellArray,simWatchersCellArray,useParallel);
    sltest.internal.Events.getInstance.notifySimInArrayCreated;

    noRet=onCleanup(@()cleanupModels(modelsAlreadyLoaded,modelsAlreadyOpen,modelsAlreadyDirty,harnessesAlreadyLoaded,harnessOwnerMap,runCfgArray,modelsLockStatusMap,harnessesAlreadyOpen));
    noRet1=onCleanup(@()deleteSubsystemManagers(simWatchersCellArray));
    noRet_SIL=onCleanup(@()deleteHarnessCreatedForPerformance(paramsToRevertInSIL));

    if(stm.internal.readStopTest()==1)
        return;
    end


    stm.internal.SimulationInput.simulateAndEvaluate(runCfgArray,simInStructCellArray,simWatchersCellArray,useParallel,resultSetId);

    noRet_SIL.delete;
    noRet1.delete;
    noRet.delete;
end

function cleanupModels(modelsAlreadyLoaded,modelsAlreadyOpen,modelsAlreadyDirty,harnessesAlreadyLoaded,harnessOwnerMap,runCfgArray,modelsLockStatusMap,harnessesAlreadyOpen)
    harnessesCurrentlyLoaded=find_system('type','block_diagram','IsHarness','on','Open','off');
    harnessesToClose=setdiff(harnessesCurrentlyLoaded,harnessesAlreadyLoaded);

    close_system(harnessesToClose,0);

    if(stm.internal.util.getFeatureFlag('MultipleHarnessOpen')>0)





        for i=1:length(harnessesAlreadyLoaded)
            ownerBDName=harnessOwnerMap(harnessesAlreadyLoaded{i});
            hInfo=sltest.harness.find(ownerBDName,'Name',harnessesAlreadyLoaded{i});
            sltest.harness.load(hInfo.ownerFullPath,hInfo.name);
        end
        for i=1:length(harnessesAlreadyOpen)
            ownerBDName=harnessOwnerMap(harnessesAlreadyOpen{i});
            hInfo=sltest.harness.find(ownerBDName,'Name',harnessesAlreadyOpen{i});
            sltest.harness.open(hInfo.ownerFullPath,hInfo.name);
        end
    else
        harnessesToLoad=setdiff(harnessesAlreadyLoaded,harnessesCurrentlyLoaded);
        for i=1:length(harnessesToLoad)
            ownerBDName=harnessOwnerMap(harnessesToLoad{i});
            hInfo=sltest.harness.find(ownerBDName,'Name',harnessesToLoad{i});
            sltest.harness.load(hInfo.ownerFullPath,hInfo.name);
        end
        harnessesCurrentlyOpen=find_system('type','block_diagram','IsHarness','on','Open','on');
        harnessesToOpen=setdiff(harnessesAlreadyOpen,harnessesCurrentlyOpen);
        for i=1:length(harnessesToOpen)
            ownerBDName=harnessOwnerMap(harnessesToOpen{i});
            hInfo=sltest.harness.find(ownerBDName,'Name',harnessesToOpen{i});
            sltest.harness.open(hInfo.ownerFullPath,hInfo.name);
        end
    end

    modelsCurrentlyLoaded=find_system('type','block_diagram','IsHarness','off','Open','off');
    modelsCurrentlyOpen=find_system('type','block_diagram','IsHarness','off','Open','on');
    modelsToClose=setdiff(modelsCurrentlyLoaded,modelsAlreadyLoaded);



    modelsClosedByCleanup=cell(1,length(runCfgArray));
    [modelsClosedByCleanup{:}]=deal(runCfgArray.modelsClosedByCleanup);
    modelsClosedByCleanup=modelsClosedByCleanup(~cellfun(@isempty,modelsClosedByCleanup));

    modelsToLoad=setdiff(modelsAlreadyLoaded,modelsCurrentlyLoaded);
    modelsToOpen=setdiff(modelsAlreadyOpen,modelsCurrentlyOpen);
    close_system(modelsToClose,0);
    cellfun(@(x)close_system(x,0),modelsClosedByCleanup);
    load_system(modelsToLoad);

    for i=1:length(modelsAlreadyLoaded)
        lockStatus=modelsLockStatusMap(modelsAlreadyLoaded{i});
        if bdIsLibrary(modelsAlreadyLoaded{i})&&...
            ~isequal(lockStatus,get_param(modelsAlreadyLoaded{i},'Lock'))
            set_param(modelsAlreadyLoaded{i},'Lock',lockStatus);
        end
    end


    open_system(modelsToOpen);

    modelsCurrentlyDirty=find_system('type','block_diagram','Dirty','on');
    modelsToDirtyOn=setdiff(modelsAlreadyDirty,modelsCurrentlyDirty);



    modelsToDirtyOff=setdiff(modelsCurrentlyDirty,modelsAlreadyDirty);

    cellfun(@(x)dirtyModel(x,'on'),modelsToDirtyOn);
    cellfun(@(x)dirtyModel(x,'off'),modelsToDirtyOff);
end

function dirtyModel(model,value)
    if strcmp(get_param(model,'Lock'),'off')
        set_param(model,'Dirty',value);
    end
end

function deleteSubsystemManagers(simWatchersCellArray)
    for i=1:length(simWatchersCellArray)
        simWatcher=simWatchersCellArray{i};
        if~isempty(simWatcher.SubsystemManager)
            try
                simWatcher.SubsystemManager.workflowTeardown();
                simWatcher.SubsystemManager=[];
            catch
                simWatcher.SubsystemManager=[];
            end
        end
    end
end

function[simInputStructArray,simWatcherArray,paramsToRevertInSIL]=updateSimInputArrayForPerformance(simInputStructArray,simWatcherArray)
    paramsToRevertInSIL=[];
    modelToChange={};
    origDirtyValues={};
    for i=1:length(simInputStructArray)
        if(stm.internal.readStopTest()==1)
            return;
        end
        try
            loggedSignalSetId=simInputStructArray{i}.LoggedSignalSetId;
            if(slfeature('STMPerformanceImproveForSIL')==1)&&strcmpi(simInputStructArray{i}.Mode,'Software-in-the-Loop (sil)')&&...
                (~simInputStructArray{i}.SignalLogging&&~simInputStructArray{i}.SaveOutput)&&...
                (isempty(loggedSignalSetId)||loggedSignalSetId==0)



                if isempty(simInputStructArray{i}.HarnessName)
                    if~bdIsLoaded(simInputStructArray{i}.Model)
                        load_system(simInputStructArray{i}.Model);
                    end
                    harnessModelName=[simInputStructArray{i}.Model,'_harnessSIL_ForPERFORMANCE'];




                    harnesslist=sltest.harness.find(simInputStructArray{i}.Model,'Name',harnessModelName);
                    if isempty(harnesslist)



                        modelToChange{end+1}=simInputStructArray{i}.Model;%#ok<AGROW> 
                        origDirtyValues{end+1}=get_param(simInputStructArray{i}.Model,'Dirty');%#ok<AGROW> 
                        sltest.harness.create(simInputStructArray{i}.Model,'Name',...
                        harnessModelName,'VerificationMode','SIL',...
                        'LogOutputs',true);
                        set_param(modelToChange{end},'Dirty',origDirtyValues{end});
                    end


                    simInputStructArray{i}.HarnessName=[harnessModelName,'%%%',simInputStructArray{i}.Model];
                    simWatcherArray{i}.harnessString=simInputStructArray{i}.HarnessName;
                end
            end
        catch Me
            rethrow(Me);
        end
    end
    if(~isempty(modelToChange))
        paramsToRevertInSIL=containers.Map(modelToChange,origDirtyValues);
    end
end

function deleteHarnessCreatedForPerformance(paramsToRevertInSIL)
    if(isempty(paramsToRevertInSIL))
        return;
    end



    modelToChange=paramsToRevertInSIL.keys;
    values=paramsToRevertInSIL.values;

    for i=1:length(modelToChange)
        harnessModelName=[modelToChange{i},'_harnessSIL_ForPERFORMANCE'];
        harnesslist=sltest.harness.find(modelToChange{i},'Name',harnessModelName);
        modelH=get_param(modelToChange{i},'Handle');
        if~isempty(harnesslist)
            if harnesslist.isOpen
                sltest.harness.close(modelH,harnessModelName);
            end
            sltest.harness.delete(modelH,harnessModelName);
            set_param(modelToChange{i},'Dirty',values{i});
        end
    end
end
