

function[blockTable]=setUnsupportedBlocks(Config,blockTable,datamgr)

    blockReader=datamgr.getBlockReader();



    modelObj=Config.getModelObject();
    unsupportedBlkObjs=modelObj.getUnsupportedBlocks();
    numUnsupported=numel(unsupportedBlkObjs);
    for k=1:numUnsupported
        keyVal=slci.results.getKeyFromBlockHandle(...
        unsupportedBlkObjs{k}.getHandle());


        [bObject,blockTable]=...
        slci.results.cacheData('get',blockTable,blockReader,...
        'getObject',keyVal);

        bObject.setIsUnsupported();
        blockTable=slci.results.cacheData('update',blockTable,...
        keyVal,bObject);

    end

end
