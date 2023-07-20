



function modelTrace=getModelTrace(datamgr,reportConfig)


    blockReader=datamgr.getReader('BLOCK');

    orderedBlockKeys=blockReader.getDescription('OrderedKeyList');
    blockKeys=blockReader.getKeys();
    allKeys=union(orderedBlockKeys,blockKeys,'stable');

    allObjects=blockReader.getObjects(allKeys);
    predicate=@(x)getIsVisible(x);
    selected=cellfun(predicate,allObjects);
    blockObjects=allObjects(selected);


    charts={};
    blocks={};
    for k=1:numel(blockObjects)
        Obj=blockObjects{k};
        if isa(Obj,'slci.results.BlockObject')||...
            isa(Obj,'slci.results.RegistrationDataObject')
            blocks{end+1}=Obj;%#ok
        elseif isa(Obj,'slci.results.ChartObject')
            charts{end+1}=Obj;%#ok
            if Obj.getIsRootChart()
                blocks{end+1}=Obj;%#ok
            end
        end
    end



    modelFileName=datamgr.getMetaData('ModelFileName');
    modelName=datamgr.getMetaData('ModelName');
    modelTrace.DETAIL.SECTIONLIST(1).SECTION.CONTENT=['Model : '...
    ,slci.internal.ReportUtil.createModelLink(...
    modelFileName,modelName)];
    modelTrace.DETAIL.SECTIONLIST(1).TABLEDATA=...
    slci.report.prepareModelTraceDetail(blocks,...
    datamgr,...
    reportConfig);


    blockReader=datamgr.getBlockReader();
    numCharts=numel(charts);
    tableIndex=2;
    for k=1:numCharts
        cObj=charts{k};
        subComponentKeys=slci.report.getAllSubComps(cObj,blockReader);
        if~isempty(subComponentKeys)
            subComponents=blockReader.getObjects(subComponentKeys);
            stateflowDetail=slci.report.prepareModelTraceDetail(subComponents,...
            datamgr,...
            reportConfig);
            modelTrace.DETAIL.SECTIONLIST(tableIndex).SECTION.CONTENT...
            =['Chart : ',cObj.getCallback(datamgr)];
            modelTrace.DETAIL.SECTIONLIST(tableIndex).TABLEDATA=stateflowDetail;
            tableIndex=tableIndex+1;
        end
    end




    resultsReader=datamgr.getReader('RESULTS');
    tStatus=resultsReader.getObject('ModelTraceabilityStatus');
    traceStatus.CONTENT=reportConfig.getStatusMessage(tStatus);
    traceStatus.ATTRIBUTES=tStatus;
    modelTrace.SUMMARY.STATUS=traceStatus;

    traceStatuses=reportConfig.getModelTraceStatusList();
    countMap=slci.internal.ReportUtil.getTraceCounts(blockObjects,...
    traceStatuses);
    modelTrace.SUMMARY.TABLEDATA=slci.report.prepareTraceSummary(countMap,...
    traceStatuses,...
    reportConfig);
end
