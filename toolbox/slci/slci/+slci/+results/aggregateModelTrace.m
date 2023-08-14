


function modelTraceStatus=aggregateModelTrace(datamgr,reportConfig,slciConfig)







    reader=datamgr.getReader('BLOCK');
    ObjectKeys=reader.getKeys();
    dataObjects=reader.getObjects(ObjectKeys);


    if slcifeature('SLCIJustification')==1

        modelManager=slciConfig.getModelManager();
        numObjects=numel(dataObjects);
        for k=1:numObjects
            thisObject=dataObjects{k};
            if isa(thisObject,'slci.results.HiddenBlockObject')&&~isempty(modelManager)
                if modelManager.isFiltered(thisObject.fOrigBlock)

                    thisObject.setTraceStatus('JUSTIFIED');
                end
            end
        end
    end


    traceStatuses=reportConfig.getModelTraceStatusList();
    traceStatusesToAgg={};

    countMap=slci.internal.ReportUtil.getTraceCounts(dataObjects,...
    traceStatuses);

    for k=1:numel(traceStatuses)
        thisStatus=traceStatuses{k};
        if(countMap(thisStatus)>0)
            traceStatusesToAgg{end+1}=thisStatus;%#ok
        end
    end


    modelTraceStatus=reportConfig.getHeaviest(traceStatusesToAgg);
    modelTraceStatus=reportConfig.getTopTraceStatus(modelTraceStatus);

end
