







function modelVerificationData=...
    getModelVerification(datamgr,reportConfig)

    pModelVerReport=slci.internal.Profiler('SLCI','ModelVerification','','');


    modelName=datamgr.getMetaData('ModelName');
    resultsReader=datamgr.getReader('RESULTS');
    blockReader=datamgr.getBlockReader();

    orderedBlockKeys=blockReader.getDescription('OrderedKeyList');
    blockKeys=blockReader.getKeys();
    allKeys=union(orderedBlockKeys,blockKeys,'stable');

    allObjects=blockReader.getObjects(allKeys);
    predicate=@(x)getIsVisible(x);
    selected=cellfun(predicate,allObjects);
    blockObjectList=allObjects(selected);







    statuses=reportConfig.getModelVerStatusList();

    statusMap=slci.internal.ReportUtil.getStatusCounts(blockObjectList,statuses);
    aggStatus=resultsReader.getObject('ModelInspectionStatus');


    modelStatusList(1).STATUS.CONTENT=...
    reportConfig.getStatusMessage(aggStatus);
    modelStatusList(1).STATUS.ATTRIBUTES=aggStatus;
    modelStatusList(1).COUNTLIST=...
    prepareModelVerSummary(statusMap,reportConfig);
    modelStatusSummary.TABLEDATA=modelStatusList;


    modelStatusSummary.STATUS=modelStatusList(1).STATUS;






    charts={};
    blocks={};
    for k=1:numel(blockObjectList)
        Obj=blockObjectList{k};
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
    modelStatusDetail.SECTIONLIST(1).SECTION.CONTENT=['Model : '...
    ,slci.internal.ReportUtil.createModelLink(...
    modelFileName,modelName)];
    modelStatusDetail.SECTIONLIST(1).TABLEDATA...
    =slci.report.prepareBlockStatus(blocks,datamgr,reportConfig);


    numCharts=numel(charts);

    tableIndex=2;
    for k=1:numCharts
        cObj=charts{k};
        subComponentKeys=slci.report.getAllSubComps(cObj,blockReader);
        if~isempty(subComponentKeys)
            subComponents=blockReader.getObjects(subComponentKeys);
            stateflowDetail=...
            slci.report.prepareBlockStatus(subComponents,datamgr,reportConfig);
            modelStatusDetail.SECTIONLIST(tableIndex).SECTION.CONTENT...
            =['Chart : ',cObj.getCallback(datamgr)];
            modelStatusDetail.SECTIONLIST(tableIndex).TABLEDATA=...
            stateflowDetail;
            tableIndex=tableIndex+1;
        end
    end



    modelVerificationData.DETAIL=modelStatusDetail;
    modelVerificationData.SUMMARY=modelStatusSummary;

    pModelVerReport.stop();

end



function statusCounts=prepareModelVerSummary(countMap,reportConfig)



    message='Model objects with status ';
    statuses=reportConfig.getModelVerStatusList();
    statusCounts=slci.report.formatSummaryCounts(countMap,...
    statuses,message,reportConfig);

end
