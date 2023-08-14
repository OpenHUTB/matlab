function updateFromEventData(eventData,varargin)






    modelName=eventData.modelName;
    sdiTsRunID=eventData.runID;

    if isempty(modelName)||isempty(sdiTsRunID)

        return;
    end

    if isempty(varargin)
        runName=get_param(modelName,'FPTRunName');
    else
        runName=varargin{1};
    end

    DataTypeWorkflow.SigLogServices.updateRunIDInfoInRun(modelName,sdiTsRunID,runName);

    sdiEngine=Simulink.sdi.Instance.engine();
    sdiEngine.setRunName(sdiTsRunID,runName);

end


