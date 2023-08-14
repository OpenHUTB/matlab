




function[codeTrace,notProcessedTrace]=getCodeTrace(codeKeys,datamgr,...
    reportConfig)




    inspectedFiles=datamgr.getMetaData('InspectedCodeFiles');
    filesToTrace=inspectedFiles.filesToTrace;



    codeMap=slci.results.groupCode(codeKeys,filesToTrace,datamgr);
    numFiles=numel(filesToTrace);





    for k=1:numFiles


        fileName=filesToTrace{k};
        [~,fileNamePart,fileExtPart]=fileparts(fileName);
        thisFile=[fileNamePart,fileExtPart];

        section=['File : '...
        ,slci.internal.ReportUtil.createFileLink(fileName,...
        thisFile)];

        codeTrace.DETAIL.SECTIONLIST(k).SECTION.CONTENT=section;




        codeObjects=codeMap(fileName);

        if isempty(codeObjects)


            codeTrace.DETAIL.SECTIONLIST(k).TABLEDATA=[];
        else
            codeTrace.DETAIL.SECTIONLIST(k).TABLEDATA=...
            slci.report.prepareCodeTraceDetail(codeObjects,...
            datamgr,reportConfig);
        end
    end




    traceStatuses=reportConfig.getCodeTraceStatusList();
    numTraceStatuses=numel(traceStatuses);
    initialCounts=cell(numTraceStatuses,1);
    [initialCounts{:}]=deal(0);
    allObjectsCountMap=containers.Map(traceStatuses,initialCounts);


    statusStruct(numFiles)=struct('FILENAME',[],'STATUSMAP',[]);
    for p=1:numFiles

        fullFileName=filesToTrace{p};


        objectList=codeMap(fullFileName);
        [countMap,statusMap]=...
        slci.internal.ReportUtil.getStatusObjectAndCountMap(objectList,...
        traceStatuses);

        statusStruct(p).FILENAME=fullFileName;
        statusStruct(p).STATUSMAP=statusMap;


        if p>1
            for k=1:numTraceStatuses
                traceStatus=traceStatuses{k};
                numObjects=countMap(traceStatus);

                allObjectsCountMap(traceStatus)=allObjectsCountMap(traceStatus)+...
                numObjects;
            end
        else
            allObjectsCountMap=countMap;
        end
    end




    resultsReader=datamgr.getReader('RESULTS');
    tStatus=resultsReader.getObject('CodeTraceabilityStatus');
    traceStatus=[];
    traceStatus.CONTENT=reportConfig.getStatusMessage(tStatus);
    traceStatus.ATTRIBUTES=tStatus;
    codeTrace.SUMMARY.STATUS=traceStatus;
    codeTrace.SUMMARY.TABLEDATA=...
    slci.report.prepareTraceSummary(allObjectsCountMap,...
    traceStatuses,reportConfig);


    notProcessedTrace=slci.report.getNotProcessedTable(statusStruct);

end
