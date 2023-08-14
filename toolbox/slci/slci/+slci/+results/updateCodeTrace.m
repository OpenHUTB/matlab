
function codeTable=updateCodeTrace(inputCodeTrace,codeTable,datamgr)

    codeReader=datamgr.getCodeReader();
    codeTraceMap=slci.internal.ReportUtil.categorize('ID1',inputCodeTrace);
    codeTraceKeys=keys(codeTraceMap);
    numCodeTraceObjects=numel(codeTraceKeys);
    datamgr.beginTransaction();
    try
        for k=1:numCodeTraceObjects

            [codeKey,codeFile,lineNum]=...
            slci.results.readEngineCodeKey(codeTraceKeys{k});
            if codeReader.hasObject(codeKey)
                [cObject,codeTable]=...
                slci.results.cacheData('get',codeTable,codeReader,...
                'getObject',codeKey);
            else

                cObject=slci.results.CodeObject(codeFile,lineNum);
                codeReader.insertObject(cObject.getKey(),cObject);
            end

            codeTraceInfo=codeTraceMap(codeTraceKeys{k});
            numTraceInfo=numel(codeTraceInfo);
            tKeys=cell(1,numTraceInfo);

            for p=1:numTraceInfo
                tKeys{p}=codeTraceInfo(p).ID2;
            end

            cObject.addTraceKey(tKeys);
            codeTable=slci.results.cacheData('update',codeTable,codeKey,cObject);
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();

end
