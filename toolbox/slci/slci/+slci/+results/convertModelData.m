
function[blockTable,codeTable,functionInterfaceTable]=...
    convertModelData(Config,datamgr,verification_data,blockTable,...
    codeTable,functionInterfaceTable)



    inputModelStatus=[];
    inputModelAggStatus=[];
    inputModelSliceStatus=[];
    inputModelTrace=[];
    inputOptimizedBlocks=[];

    for k=1:numel(verification_data)
        cell_data=verification_data{k};
        switch(cell_data.name)
        case 'MODEL_VERIFICATION_STATUS'
            inputModelStatus=cell_data.data;
        case 'MODEL_TAGS_VERIFICATION_STATUS'
            inputModelAggStatus=cell_data.data;
        case 'MODEL_SLICE'
            inputModelSliceStatus=cell_data.data;
        case 'MODEL_TRACEABILITY'
            inputModelTrace=cell_data.data;
        case 'BLOCKS_OPTIMIZED'
            inputOptimizedBlocks=cell_data.data;
        end
    end

    blockSliceTable=containers.Map;

    if~isempty(inputModelSliceStatus)
        [blockTable,blockSliceTable]=...
        constructBlockSliceObject(inputModelSliceStatus,...
        blockTable,...
        blockSliceTable,...
        datamgr);
    end

    if~isempty(inputModelStatus)

        [blockTable,blockSliceTable]=...
        updateBlockAndSliceObject(inputModelStatus,...
        blockTable,blockSliceTable,datamgr);
    end

    if~isempty(inputModelAggStatus)
        [blockTable,functionInterfaceTable]=slci.results.updateModelAggStatus(...
        inputModelAggStatus,...
        blockTable,...
        functionInterfaceTable,...
        datamgr);
    end


    if~isempty(inputModelTrace)
        [blockTable,functionInterfaceTable]=...
        slci.results.updateModelTrace(inputModelTrace,blockTable,...
        functionInterfaceTable,datamgr);
    end

    if~isempty(inputOptimizedBlocks)
        blockTable=slci.results.updateOptimizedBlocks(inputOptimizedBlocks,...
        blockTable,datamgr);
    end


    blockTable=slci.results.setUnsupportedBlocks(Config,blockTable,datamgr);




    blockTable=slci.results.setTrivialTransitions(Config,blockTable,datamgr);

    blockTable=slci.results.setTransitionCallee(Config,blockTable,datamgr);


    slci.results.cacheData('save',blockSliceTable,datamgr,...
    datamgr.getBlockSliceReader(),'replaceObject');

end


function[blockTable,blockSliceTable]=...
    constructBlockSliceObject(inputModelSliceStatus,blockTable,...
    blockSliceTable,datamgr)

    blockReader=datamgr.getBlockReader();
    blockSliceReader=datamgr.getBlockSliceReader();


    sliceArray=slci.internal.ReportUtil.categorize('SLICE_OP',inputModelSliceStatus);
    sliceKeys=keys(sliceArray);
    numSlices=numel(sliceKeys);

    datamgr.beginTransaction();
    try
        for k=1:numSlices


            sliceKey=sliceKeys{k};


            sliceInfo=sliceArray(sliceKey);
            sliceName=sliceInfo.SLICE_NAME;


            sliceFunc=sliceInfo.FUNC;




            numSliceInfo=numel(sliceInfo);
            sourceBlocks=cell(0);
            for p=1:numSliceInfo
                srcBlock=sliceInfo(p).ID;
                if blockReader.hasObject(srcBlock)
                    [sourceBlocks{end+1},blockTable]=...
                    slci.results.cacheData('get',blockTable,blockReader,...
                    'getObject',srcBlock);
                else
                    DAStudio.error('Slci:results:UnknownKey',srcBlock);
                end
            end

            if blockSliceReader.hasObject(sliceKey)
                [sObject,blockSliceTable]=...
                slci.results.cacheData('get',blockSliceTable,blockSliceReader,...
                'getObject',sliceKey);
                sObject.addSourceObject(sourceBlocks);
            else
                sObject=...
                slci.results.BlockSliceObject(sliceKey,sliceName,...
                sliceFunc,sourceBlocks);
                blockSliceReader.insertObject(sliceKey,sObject);
            end
            blockSliceTable=...
            slci.results.cacheData('update',blockSliceTable,sliceKey,sObject);
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();

end


function[blockTable,blockSliceTable]=...
    updateBlockAndSliceObject(inputModelStatus,blockTable,blockSliceTable,datamgr)

    blockReader=datamgr.getBlockReader();
    blockSliceReader=datamgr.getBlockSliceReader();

    blockMap=slci.internal.ReportUtil.categorize('ID',inputModelStatus);
    blockKeys=keys(blockMap);

    datamgr.beginTransaction();
    try
        for k=1:numel(blockKeys)
            keyVal=blockKeys{k};

            hasObj=slci.results.cacheData('check',blockTable,blockReader,...
            'hasObject',keyVal);
            if hasObj
                [bObject,blockTable]=...
                slci.results.cacheData('get',blockTable,blockReader,...
                'getObject',keyVal);
                blockInfos=blockMap(keyVal);
                for m=1:numel(blockInfos)
                    thisBlockInfo=blockInfos(m);
                    sliceKey=thisBlockInfo.SLICE_OP;
                    status=thisBlockInfo.STATUS;
                    substatus=thisBlockInfo.SUBSTATUS;


                    [sObject,blockSliceTable]=...
                    slci.results.cacheData('get',blockSliceTable,blockSliceReader,...
                    'getObject',sliceKey);
                    sObject.appendContributingSourceKey(keyVal);

                    blockSliceTable=slci.results.cacheData('update',...
                    blockSliceTable,sliceKey,sObject);


                    bObject.addSubstatusForSlice(sObject,substatus);
                    bObject.addStatusForSlice(sObject,status);
                end

                blockTable=slci.results.cacheData('update',blockTable,...
                keyVal,bObject);
            else
                DAStudio.error('Slci:results:UnknownKey',keyVal);
            end
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();

end
