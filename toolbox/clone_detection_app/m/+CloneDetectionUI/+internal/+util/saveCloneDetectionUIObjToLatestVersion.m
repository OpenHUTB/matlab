function saveCloneDetectionUIObjToLatestVersion(model)



    cloneUIObj=get_param(model,'CloneDetectionUIObj');

    if~isempty(cloneUIObj.objectFile)
        if~exist(cloneUIObj.backUpPath,'dir')
            mkdir(cloneUIObj.backUpPath);
            cloneUIObj.historyVersions=[];
        end
        updatedObj=cloneUIObj;
        save(cloneUIObj.objectFile,'updatedObj');
    end
end