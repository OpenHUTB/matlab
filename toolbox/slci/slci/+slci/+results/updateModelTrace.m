
function[blockTable,functionInterfaceTable]=updateModelTrace(...
    inputModelTrace,blockTable,functionInterfaceTable,datamgr)

    blockReader=datamgr.getBlockReader();
    functionInterfaceReader=datamgr.getFunctionInterfaceReader();
    modelTraceMap=slci.internal.ReportUtil.categorize('ID1',inputModelTrace);
    modelTraceKeys=keys(modelTraceMap);

    datamgr.beginTransaction();
    try
        for k=1:numel(modelTraceKeys)

            modelKey=modelTraceKeys{k};

            modelTraceInfo=modelTraceMap(modelKey);
            numTraceInfo=numel(modelTraceInfo);
            cKeys=cell(1,numTraceInfo);
            for p=1:numTraceInfo
                [cKeys{p},~,~]=slci.results.readEngineCodeKey(...
                modelTraceInfo(p).ID2);
            end


            hasObj=slci.results.cacheData('check',blockTable,blockReader,...
            'hasObject',modelKey);
            if hasObj
                [mObject,blockTable]=...
                slci.results.cacheData('get',blockTable,blockReader,...
                'getObject',modelKey);

                if~(isa(mObject,'slci.results.BlockObject')&&...
                    mObject.IsRootInport())
                    mObject.addTraceKey(cKeys);
                    blockTable=slci.results.cacheData('update',blockTable,...
                    modelKey,mObject);
                end
            else
                isFuncInterfaceObj=slci.results.cacheData('check',functionInterfaceTable,...
                functionInterfaceReader,'hasObject',modelKey);
                if isFuncInterfaceObj
                    [mObject,functionInterfaceTable]=...
                    slci.results.cacheData('get',functionInterfaceTable,...
                    functionInterfaceReader,'getObject',modelKey);
                    mObject.addTraceKey(cKeys);
                    functionInterfaceTable=...
                    slci.results.cacheData('update',functionInterfaceTable,...
                    modelKey,mObject);

                else
                    DAStudio.error('Slci:results:UnknownKey',modelKey);
                end
            end
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();
end
