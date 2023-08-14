




function[funcNameTable,fileNameTable]=getSubSystemData(datamgr)

    pSubSystemFunctionReport=...
    slci.internal.Profiler('SLCI','SubSystemData','','');


    subsystemReader=datamgr.getSubSystemReader();
    sObjects=...
    subsystemReader.getObjects(subsystemReader.getKeys());


    summaryData=getFuncNameSummaryTable(datamgr,sObjects);


    funcNameTable.STATUS=[];
    funcNameTable.SUMMARY.TABLEDATA=summaryData;
    funcNameTable.DETAILS=[];


    summaryData=getFileNameSummaryTable(datamgr,sObjects);


    fileNameTable.STATUS=[];
    fileNameTable.SUMMARY.TABLEDATA=summaryData;
    fileNameTable.DETAILS=[];

    pSubSystemFunctionReport.stop();
end


function summaryTable=getFuncNameSummaryTable(datamgr,sObjects)
    summaryTable=[];
    numObjects=numel(sObjects);
    if numObjects>0
        summaryTable=struct('OBJECTLIST',{},...
        'C_NAME',{},...
        'M_NAME',{});
        idx=0;
        for k=1:numObjects
            sObj=sObjects{k};
            if~isempty(sObj.getCFuncName())
                idx=idx+1;

                summaryTable(idx).C_NAME.CONTENT=sObj.getCFuncName();

                summaryTable(idx).M_NAME.CONTENT=sObj.getMFuncName();

                blockKey=sObj.getKey();
                blockReader=datamgr.getBlockReader();
                blockObj=blockReader.getObject(blockKey);
                summaryTable(idx).OBJECTLIST.SOURCEOBJ.CONTENT=...
                blockObj.getCallback(datamgr);

            end
        end
    end
end


function summaryTable=getFileNameSummaryTable(datamgr,sObjects)
    summaryTable=[];
    numObjects=numel(sObjects);
    if numObjects>0
        summaryTable=struct('OBJECTLIST',{},...
        'C_NAME',{},...
        'M_NAME',{});
        idx=0;
        for k=1:numObjects
            sObj=sObjects{k};
            if~isempty(sObj.getCFileName())
                idx=idx+1;

                summaryTable(idx).C_NAME.CONTENT=sObj.getCFileName();

                summaryTable(idx).M_NAME.CONTENT=sObj.getMFileName();

                blockKey=sObj.getKey();
                blockReader=datamgr.getBlockReader();
                blockObj=blockReader.getObject(blockKey);
                summaryTable(idx).OBJECTLIST.SOURCEOBJ.CONTENT=...
                blockObj.getCallback(datamgr);
            end
        end
    end
end