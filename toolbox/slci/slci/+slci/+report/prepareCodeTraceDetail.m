







function codeDetailTable=prepareCodeTraceDetail(codeObjects,datamgr,...
    reportConfig)
    numCodes=numel(codeObjects);
    if slcifeature('SLCIJustification')==1
        codeDetailTable(numCodes)=struct('SOURCEOBJ',[],'CODE',[],...
        'SOURCELIST',[],'REASON',[],...
        'JUSTIFICATION',[]);
    else
        codeDetailTable(numCodes)=struct('SOURCEOBJ',[],'CODE',[],...
        'SOURCELIST',[],'REASON',[]);
    end
    lineNum=ones(numCodes,1);
    for k=1:numCodes
        codeObj=codeObjects{k};

        lineNum(k)=codeObj.getLineNumber();

        codeDetailTable(k).SOURCEOBJ.CONTENT=int2str(lineNum(k));

        codeDetailTable(k).CODE.CONTENT=slci.internal.encodeString(...
        codeObj.getCodeString(),'all','encode');

        traceKeys=codeObj.getTraceArray();
        numTraced=numel(traceKeys);
        if numTraced>0
            sourceList=struct('SOURCEOBJ',[]);
            tObjects=readObjects(traceKeys,datamgr);
            for p=1:numTraced
                tObj=tObjects{p};
                sourceList(p).SOURCEOBJ.CONTENT=tObj.getCallback(datamgr);
            end
            codeDetailTable(k).SOURCELIST=sourceList;
        else
            codeDetailTable(k).SOURCELIST.SOURCEOBJ.CONTENT='-';
        end

        detailsMessage=slci.report.getDetailsColumn(codeObj,reportConfig);
        codeDetailTable(k).REASON.CONTENT=detailsMessage;
        codeDetailTable(k).REASON.ATTRIBUTES='';
        if slcifeature('SLCIJustification')==1
            codeDetailTable(k).JUSTIFICATION.CONTENT='-';
        end
    end

    [~,sortedIdxs]=sort(lineNum);
    codeDetailTable=codeDetailTable(sortedIdxs);
end


function tObjs=readObjects(traceKeys,datamgr)
    numTrace=numel(traceKeys);
    blockReader=datamgr.getReader('BLOCK');
    functionInterfaceReader=datamgr.getReader('FUNCTIONINTERFACE');
    tObjs=cell(numTrace,1);
    datamgr.beginTransaction();
    try
        for k=1:numTrace
            tKey=traceKeys{k};
            tObjs{k}=readObject(tKey,blockReader,functionInterfaceReader);
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();
end
function traceObj=readObject(traceKey,blockReader,functionInterfaceReader)


    if blockReader.hasObject(traceKey)
        traceObj=blockReader.getObject(traceKey);
    else
        if functionInterfaceReader.hasObject(traceKey)
            traceObj=functionInterfaceReader.getObject(traceKey);
        else
            error(['Unknown object ',traceKey]);
        end
    end
end
