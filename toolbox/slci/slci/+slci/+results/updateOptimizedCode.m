

function codeTable=updateOptimizedCode(inputOptimizedCode,...
    codeTable,datamgr)

    codeReader=datamgr.getReader('CODE');
    numOptimizedCode=numel(inputOptimizedCode);
    for k=1:numOptimizedCode

        [codeKey,codeFile,lineNum]=...
        slci.results.readEngineCodeKey(inputOptimizedCode(k).ID);

        hasObj=slci.results.cacheData('check',codeTable,codeReader,...
        'hasObject',codeKey);
        if hasObj
            [cObject,codeTable]=...
            slci.results.cacheData('get',codeTable,codeReader,...
            'getObject',codeKey);
        else


            cObject=slci.results.CodeObject(codeFile,lineNum);
            codeReader.insertObject(cObject.getKey(),cObject);
        end


        cObject.addPrimVerSubstatus('OPTIMIZED');


        cObject.addPrimTraceSubstatus('OPTIMIZED');

        codeTable=slci.results.cacheData('update',codeTable,...
        cObject.getKey(),cObject);
    end

end

