function runID=getRunIDfromLoggedData(var)





    runID=0;


    if iscell(var)&&length(var)==1
        var=var{1};
    end



    if isa(var,'Simulink.SimulationOutput')
        runID=locFindRunIDinSimOutput(var);
    elseif isa(var,'Simulink.SimulationData.Dataset')
        runID=locFindRunIDinDataset(var);
    elseif isa(var,'simscape.logging.Node')
        runID=locFindRunIDinSimscapeLog(var);
    end



    if~Simulink.sdi.isValidRunID(runID)
        eng=Simulink.sdi.Instance.engine();
        runID=eng.sigRepository.getRunIDfromWksVarChecksum(var);
    end
end


function runID=locFindRunIDinSimOutput(var)
    runID=0;
    if isscalar(var)
        varNames=who(var);
        for idx=1:length(varNames)
            curVar=var.get(varNames{idx});
            if isa(curVar,'Simulink.SimulationData.Dataset')
                runID=locFindRunIDinDataset(curVar);
            elseif isa(curVar,'simscape.logging.Node')
                runID=locFindRunIDinSimscapeLog(curVar);
            end
            if runID
                return
            end
        end
    end
end


function runID=locFindRunIDinDataset(var)
    runID=0;
    if isscalar(var)
        storage=var.getStorage(false);
        if isa(storage,'Simulink.sdi.internal.DatasetStorage')
            runID=storage.getRunID();
        end
    end
end


function runID=locFindRunIDinSimscapeLog(var)
    runID=0;
    if var(1).runId>0
        runID=var.runId;
    end
end
