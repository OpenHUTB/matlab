function[tableData,tableObjs]=getTableExecSystem(this,sysEntry,currTableCnt)





    tableData=[];
    flags=[];

    metricEnum=cvi.MetricRegistry.getEnum('tableExec');
    [tableObjs,justifiedLocalIdx,justifiedTotalIdx,localIdx,localCnt,totalIdx,totalCnt]=cv('MetricGet',sysEntry.cvId,...
    metricEnum,'.baseObjs',...
    '.justifiedDataIdx.shallow','.justifiedDataIdx.deep',...
    '.dataIdx.shallow','.dataCnt.shallow',...
    '.dataIdx.deep','.dataCnt.deep');

    if isempty(totalCnt)
        localIdx=-1;
        totalIdx=-1;
        totalCnt=0;
        localCnt=0;
    end

    if totalCnt==0

        return;
    end
    tableExecData=this.metricData.tableExec;


    tableData.tableIdx=currTableCnt+(1:length(tableObjs));
    tableData.localCnt=localCnt;
    if localIdx==-1
        tableData.localHits=[];
        tableData.justifiedLocalHits=[];
        tableData.executedIn='';
    else
        [tableData.localHits,tableData.justifiedLocalHits]=cvi.ReportData.getHits(tableExecData.rawData,localIdx,justifiedLocalIdx);
        tableData.executedIn=this.cvd{1}.getTrace('tableExec',localIdx+1,true);
    end
    [tableData.totalHits,tableData.justifiedTotalHits]=cvi.ReportData.getHits(tableExecData.rawData,totalIdx,justifiedTotalIdx);
    tableData.totalCnt=totalCnt;
    tableData.totalExecutedIn='';

    if(tableData.totalHits==totalCnt)
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

