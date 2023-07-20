function saveCloneDetectionUIObj(clonesRawData)




    cloneDataObject=get_param(clonesRawData.model,'CloneDetectionUIObj');
    if~exist(cloneDataObject.backUpPath,'dir')
        mkdir(cloneDataObject.backUpPath);
        cloneDataObject.historyVersions=[];
    end
    updatedObj=cloneDataObject;
    save(cloneDataObject.objectFile,'updatedObj');
end
