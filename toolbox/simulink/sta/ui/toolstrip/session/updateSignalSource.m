function updateSignalSource(sigIds,filesInScenario,filesInScenarioFullFile,appInstanceID,varargin)





    value=updateRepositoryDataSource(sigIds,filesInScenario,filesInScenarioFullFile);

    if isempty(varargin)
        fullChannel=sprintf('/sta%s/%s',appInstanceID,'sta/datasourceupdate');
    else
        fullChannel=sprintf('/%s%s/%s',varargin{1},appInstanceID,'sta/datasourceupdate');
    end
    message.publish(fullChannel,value);