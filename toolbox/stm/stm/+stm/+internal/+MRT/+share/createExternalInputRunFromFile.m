


function[externalInputRunData,dataSets]=createExternalInputRunFromFile(...
    simInStruct,isPCT,inputDataSetsRunFile)
    import stm.internal.util.SimulinkModel;
    dataSets=[];
    externalInputRunData=struct.empty;
    if~simInStruct.IncludeExternalInputs&&~simInStruct.StopSimAtLastTimePoint
        return;
    end

    [dataSets,validIdx]=SimulinkModel.getInputDataHelper(simInStruct.InputMappingString);
    if isempty(dataSets)
        return;
    end

    if isfield(simInStruct,'IsRunningOnCurrentRelease')
        isMRT=~simInStruct.IsRunningOnCurrentRelease;
    else
        isMRT=false;
    end
    dataSets=loc_processInputData(dataSets,validIdx,simInStruct);

    externalInputRunData=struct('type','externalInputDataSets','runID',[]);
    parsimFeature=slfeature('query','STMSimulationInputArray');

    if(~isempty(parsimFeature)&&(parsimFeature.State>1))&&~isMRT

        externalInputRunData.runID=loc_createRun(dataSets);
    else
        if isPCT||isMRT
            externalInputRunData.runID=1;
            if~isempty(inputDataSetsRunFile)
                save(inputDataSetsRunFile,'dataSets');
            end
        else

            externalInputRunData.runID=loc_createRun(dataSets);
        end
    end

    function runID=loc_createRun(ds)
        runID=stm.internal.createSet;

        Simulink.sdi.addToRun(runID,'vars',ds{:});

        Simulink.sdi.internal.moveRunToApp(runID,'stm');
    end

    function values=loc_processInputData(values,validIdx,simInStruct)
        if numel(values)==1&&...
            isa(values{1},'Simulink.SimulationData.Dataset')
            return;
        end
        if~isempty(simInStruct.InputMapping)
            inputMappings=simInStruct.InputMapping(validIdx);
        else
            inputMappings=[];
        end
        for idx=1:length(values)
            d=values{idx};
            if isempty(d)
                continue;
            end
            if isa(d,'Simulink.SimulationData.Signal')||...
                ~Simulink.SimulationData.utValidSignalOrCompositeData(d)
                sig=d;
            else
                sig=Simulink.SimulationData.Signal;
                sig.Values=d;
                if~isempty(inputMappings)
                    inputMap=inputMappings(idx);
                    sig.Name=inputMap.BlockName;
                    sig.BlockPath=inputMap.BlockPath;
                    sig.PortIndex=inputMap.PortNumber;
                end
            end
            values{idx}=sig;
        end
    end
end
