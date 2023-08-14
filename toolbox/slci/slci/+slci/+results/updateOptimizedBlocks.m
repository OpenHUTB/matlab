

function blockTable=updateOptimizedBlocks(inputOptimizedBlocks,...
    blockTable,datamgr)

    blockReader=datamgr.getReader('BLOCK');
    numOptimizedBlocks=numel(inputOptimizedBlocks);
    for k=1:numOptimizedBlocks
        blockKey=inputOptimizedBlocks(k).ID;


        hasObj=slci.results.cacheData('check',blockTable,blockReader,...
        'hasObject',blockKey);
        if hasObj
            [mObject,blockTable]=...
            slci.results.cacheData('get',blockTable,blockReader,...
            'getObject',blockKey);

            mObject.addPrimVerSubstatus('OPTIMIZED');
            mObject.addPrimTraceSubstatus('OPTIMIZED');

            blockTable=slci.results.cacheData('update',blockTable,...
            blockKey,mObject);
        else
            DAStudio.error('Slci:results:UnknownKey',blockKey);
        end
    end

end

