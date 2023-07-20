








function modelDetailTable=prepareModelTraceDetail(blockObjects,datamgr,...
    reportConfig)

    numBlocks=numel(blockObjects);
    if slcifeature('SLCIJustification')==1
        modelDetailTable(numBlocks)=struct('SOURCEOBJ',[],...
        'SOURCELIST',[],'REASON',[],...
        'JUSTIFICATION',[]);
    else
        modelDetailTable(numBlocks)=struct('SOURCEOBJ',[],...
        'SOURCELIST',[],'REASON',[]);
    end

    codeReader=datamgr.getReader('CODE');

    for k=1:numBlocks
        blkObj=blockObjects{k};


        modelDetailTable(k).SOURCEOBJ.CONTENT=blkObj.getCallback(datamgr);


        traceKeys=blkObj.getTraceArray();
        traceObjs=codeReader.getObjects(traceKeys);
        numTraced=numel(traceObjs);
        if numTraced>0
            modelDetailTable(k).SOURCELIST=slci.report.formatSourceCodeObjects(...
            traceObjs);
        else
            modelDetailTable(k).SOURCELIST.SOURCEOBJ.CONTENT='-';
        end


        detailsMessage=slci.report.getDetailsColumn(blkObj,reportConfig);

        modelDetailTable(k).REASON.CONTENT=detailsMessage;
        modelDetailTable(k).REASON.ATTRIBUTES='';
        if slcifeature('SLCIJustification')==1
            modelDetailTable(k).JUSTIFICATION.CONTENT='-';
        end

    end

end
