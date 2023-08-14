
function dataTable=updateCodeAggStatus(inputAggStatus,dataTable,datamgr,...
    reader)

    dataMap=slci.internal.ReportUtil.categorize('ID',inputAggStatus);
    dataKeys=keys(dataMap);

    datamgr.beginTransaction();
    try
        for k=1:numel(dataKeys)

            keyVal=dataKeys{k};
            dataInfos=dataMap(keyVal);

            [codeKey,codeFile,lineNum]=...
            slci.results.readEngineCodeKey(keyVal);


            hasObj=slci.results.cacheData('check',dataTable,reader,...
            'hasObject',codeKey);
            if hasObj

                [dataObject,dataTable]=...
                slci.results.cacheData('get',dataTable,reader,...
                'getObject',codeKey);
            else


                dataObject=slci.results.CodeObject(codeFile,lineNum);
                reader.insertObject(codeKey,dataObject);
            end


            substatuses=cell(numel(dataInfos),1);
            for p=1:numel(substatuses)
                substatuses{p}=dataInfos(p).STATUS;

                if strcmpi(dataInfos(p).STATUS,'OPTIMIZED')
                    dataObject.addPrimTraceSubstatus('OPTIMIZED');
                end
            end

            dataObject.addEngineVerSubstatus(substatuses);


            dataTable=slci.results.cacheData('update',dataTable,...
            codeKey,dataObject);

        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();
end
