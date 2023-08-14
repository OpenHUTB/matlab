
function[modelTable,functionInterfaceTable]=updateModelAggStatus(...
    inputModelAggStatus,...
    modelTable,...
    functionInterfaceTable,...
    datamgr)

    blockReader=datamgr.getBlockReader();
    functionInterfaceReader=datamgr.getFunctionInterfaceReader();
    modelMap=slci.internal.ReportUtil.categorize('ID',inputModelAggStatus);
    modelKeys=keys(modelMap);

    datamgr.beginTransaction();
    try
        for k=1:numel(modelKeys)
            keyVal=modelKeys{k};
            hasObj=slci.results.cacheData('check',modelTable,blockReader,...
            'hasObject',keyVal);
            if hasObj

                [mObject,modelTable]=...
                slci.results.cacheData('get',modelTable,blockReader,...
                'getObject',keyVal);
            else
                isFuncInterfaceObj=slci.results.cacheData('check',...
                functionInterfaceTable,...
                functionInterfaceReader,...
                'hasObject',keyVal);
                if isFuncInterfaceObj

                    [mObject,functionInterfaceTable]=...
                    slci.results.cacheData('get',...
                    functionInterfaceTable,...
                    functionInterfaceReader,...
                    'getObject',...
                    keyVal);
                else
                    DAStudio.error('Slci:results:UnknownKey',keyVal);
                end
            end


            modelInfos=modelMap(keyVal);
            substatuses=cell(numel(modelInfos),1);
            for p=1:numel(modelInfos)
                substatuses{p}=modelInfos(p).STATUS;

                if strcmpi(modelInfos(p).STATUS,'OPTIMIZED')




                    assert(isa(mObject,'slci.results.ModelObject'));
                    mObject.addPrimTraceSubstatus('OPTIMIZED');
                end
            end

            mObject.addEngineVerSubstatus(substatuses);


            modelTable=slci.results.cacheData('update',modelTable,...
            keyVal,mObject);

        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();
end
