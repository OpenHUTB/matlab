classdef SigLogServices<handle




    methods(Static)
        updateFromEventData(eventData,varargin);
        updateRunIDInfoInRun(modelName,sdiTsRunID,runName);
        updatePlottableFlagInRun(modelName,sdiTsRunID);
        runID=getSDIRunID(model,runName,simOut)
    end
end

