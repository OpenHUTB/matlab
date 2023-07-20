function[tableData,tableObjs]=getTableExecBlock(this,blockEntry,currTableCnt)







    flags=[];
    metricEnum=cvi.MetricRegistry.getEnum('tableExec');
    [tableObjs,localIdx,localCnt,justifiedLocalIdx,justifiedTotalIdx,totalIdx,totalCnt]=cv('MetricGet',blockEntry.cvId,...
    metricEnum,'.baseObjs',...
    '.dataIdx.shallow','.dataCnt.shallow',...
    '.justifiedDataIdx.shallow','.justifiedDataIdx.deep',...
    '.dataIdx.deep','.dataCnt.deep');


    if isempty(totalCnt)
        localIdx=-1;
        totalIdx=-1;
        totalCnt=0;
        localCnt=0;
    end

    if totalCnt==0
        tableData=[];
        return;
    end

    tableExecData=this.metricData.tableExec;

    tableData.tableIdx=currTableCnt+(1:length(tableObjs));
    tableData.localCnt=localCnt;
    if localIdx==-1
        tableData.localHits=[];
        tableData.justifiedLocalHits=[];
    else
        [tableData.localHits,tableData.justifiedLocalHits]=cvi.ReportData.getHits(tableExecData.rawData,localIdx,justifiedLocalIdx);
    end

    [tableData.totalHits,tableData.justifiedTotalHits]=cvi.ReportData.getHits(tableExecData.rawData,totalIdx,justifiedTotalIdx);
    tableData.totalCnt=totalCnt;
    if(tableData.totalHits(end)==totalCnt)
        flags.fullCoverage=1;
        flags.noCoverage=0;
        flags.leafUncov=0;
    else
        flags.fullCoverage=0;
        if(~isempty(tableData.localHits)&&(tableData.localHits(end)~=localCnt))&&...
            (localCnt~=(tableData.localHits(end)+tableData.justifiedLocalHits(end)))
            flags.leafUncov=1;
        else
            flags.leafUncov=0;
        end

        if tableData.totalHits==0
            flags.noCoverage=1;
        else
            flags.noCoverage=0;
        end
    end
    tableData.flags=flags;



