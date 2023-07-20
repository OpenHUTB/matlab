




function notProcessedTable=getNotProcessedTable(statusStruct)






    numSections=numel(statusStruct);
    for k=1:numSections


        fullFile=statusStruct(k).FILENAME;
        [~,fileName,fileExt]=fileparts(fullFile);
        fileDisplayName=[fileName,fileExt];
        section=['File : '...
        ,slci.internal.ReportUtil.createFileLink(fullFile,fileDisplayName)];
        summaryData.SECTIONLIST(k).SECTION.CONTENT=section;


        summaryData.SECTIONLIST(k).TABLEHEADER={'Code location','Code'};


        summaryData.SECTIONLIST(k).TABLEDATA=...
        getSummaryTable('NOT_PROCESSED',statusStruct(k).STATUSMAP);

    end

    notProcessedTable.STATUS=[];
    notProcessedTable.SUMMARY.TABLEDATA=summaryData;
    notProcessedTable.DETAILS=[];
end


function summaryTable=getSummaryTable(status,statusMap)

    objectList=statusMap(status);
    numObjects=numel(objectList);
    if numObjects==0
        summaryTable=struct('SOURCEOBJ',[],'CODE',[]);
        return;
    end
    summaryTable(numObjects)=struct('SOURCEOBJ',[],'CODE',[]);
    lineNum=ones(numObjects,1);
    for k=1:numObjects
        codeObj=objectList{k};


        lineNum(k)=codeObj.getLineNumber();


        summaryTable(k).SOURCEOBJ.CONTENT=num2str(lineNum(k));


        summaryTable(k).CODE.CONTENT=slci.internal.encodeString(...
        codeObj.getCodeString(),...
        'all',...
        'encode');
    end


    [~,sortedIdxs]=sort(lineNum);
    summaryTable=summaryTable(sortedIdxs);
end
