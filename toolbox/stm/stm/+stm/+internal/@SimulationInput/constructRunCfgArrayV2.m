
function[runCfgArray,simInputStructArray,simWatcherArray]=constructRunCfgArrayV2(simInputStructArray,simWatcherArray,useParallel)

    import stm.internal.RunTestConfiguration;
    import stm.internal.SimulationInput;

    for i=1:length(simInputStructArray)
        if(stm.internal.readStopTest()==1)
            return;
        end
        try

            runCfgArray(i)=stm.internal.RunTestConfiguration(simInputStructArray{i}.Mode);
            runCfgArray(i).runningOnPCT=useParallel;

            if(simWatcherArray{i}.revertingFailed)
                runCfgArray(i).out.IsIncomplete=true;
                tmpmsg=getString(message('stm:ScriptsView:TestIterationIncompleteDueToEarlierFailures'));
                runCfgArray(i).addMessages({tmpmsg},{false});
                continue;
            end

            if isempty(simInputStructArray{i}.Model)
                msg=getString(message('stm:general:NoModelSpecified'));
                runCfgArray(i).addMessages({msg},{true});
                continue;
            end

            if(~runCfgArray(i).processTestCaseSettings(simInputStructArray{i}))
                continue;
            end

            [mainModel,modelToRun,ownerName,harnessName]=getModelPropertyWithoutLoadingModel(simWatcherArray{i},simInputStructArray{i});


            if useParallel
                checkModelDirty(mainModel);
                checkModelDirty(modelToRun);
            end

            runCfgArray(i).modelToRun=modelToRun;



            runCfgArray(i).SimulationInput=SimulationInput.getSimIn('ModelName',modelToRun,...
            'HarnessOwner',ownerName,'HarnessName',harnessName,...
            'UseParallel',useParallel,'MainModel',mainModel);

            simInputStructArray{i}.CoverageSettings=stm.internal.Coverage.getCoverageSettings(...
            simInputStructArray{i}.CallingFunction,simInputStructArray{i}.TestCaseId);

            simWatcherArray{i}.testCaseId=simInputStructArray{i}.TestCaseId;
            simWatcherArray{i}.permutationId=simInputStructArray{i}.PermutationId;

            simInputStructArray{i}.testIteration.TestParameter.LoggedSignalSetId=runCfgArray(i).testIteration.TestParameter.LoggedSignalSetId;


            runCfgArray(i).SimulationInput=runCfgArray(i).SimulationInput.setModelParameter(...
            'RecordCoverage',getRecordCoverage(simInputStructArray{i}),...
            'CovHtmlReporting','off');

        catch me
            [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
            runCfgArray(i).addMessages(tempErrors,tempErrorOrLog);
        end
    end
end

function[mainModel,modelToRun,ownerName,harnessName]=getModelPropertyWithoutLoadingModel(simWatcher,simInputStruct)
    mainModel=simWatcher.mainModel;
    modelToRun=simInputStruct.modelToRun;
    harnessStr=simInputStruct.HarnessName;
    ownerName='';
    harnessName='';

    ind=strfind(harnessStr,'%%%');

    if~isempty(ind)&&~isequal(ind,1)
        harnessName=harnessStr(1:ind(1)-1);
        ownerName=harnessStr(ind(1)+3:end);
    end
end

function recordCoverage=getRecordCoverage(simIm)
    if simIm.CoverageSettings.RecordCoverage
        recordCoverage='on';
    else
        recordCoverage='off';
    end
end

function checkModelDirty(model)
    if bdIsLoaded(model)&&isequal(get_param(model,'Dirty'),'on')
        errID='Simulink:Commands:ParsimUnsavedChanges';
        unsavedError=getString(message(errID,model));
        throw(MException(errID,unsavedError));
    end
end