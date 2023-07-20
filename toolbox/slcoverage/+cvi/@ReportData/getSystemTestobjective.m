function[testobjectiveData,testobjectiveObjs]=getSystemTestobjective(this,sysEntry,currTestobjCount,metricName)





    testobjectiveEnum=cvi.MetricRegistry.getEnum(metricName);

    [testobjectiveObjs,justifiedLocalIdx,justifiedTotalIdx,...
    localIdx,localCnt,totalIdx,totalCnt]=cv('MetricGet',sysEntry.cvId,testobjectiveEnum,...
    '.baseObjs',...
    '.justifiedDataIdx.shallow','.justifiedDataIdx.deep',...
    '.dataIdx.shallow','.dataCnt.shallow',...
    '.dataIdx.deep','.dataCnt.deep');

    if isempty(totalCnt)||totalCnt==0
        testobjectiveData=[];
        return;
    end

    testobjectiveData.testobjectiveIdx=currTestobjCount+(1:length(testobjectiveObjs));
    testobjectiveData.inBlockIdx=1:numel(testobjectiveObjs);
    if localIdx==-1
        testobjectiveData.outlocalCnts=[];
        testobjectiveData.justifiedOutlocalCnts=[];
        testobjectiveData.executedIn='';
    else
        [testobjectiveData.outlocalCnts,testobjectiveData.justifiedOutlocalCnts]=cvi.ReportData.getHits(this.testobjectiveData.(metricName),localIdx,justifiedLocalIdx);
        testobjectiveData.executedIn='';
    end

    [testobjectiveData.outTotalCnts,testobjectiveData.justifiedOutTotalCnts]=cvi.ReportData.getHits(this.testobjectiveData.(metricName),totalIdx,justifiedTotalIdx);

    testobjectiveData.totalLocalCnts=localCnt;
    testobjectiveData.totalTotalCnts=totalCnt;
    testobjectiveData.totalExecutedIn='';

    if(testobjectiveData.outTotalCnts(end)==totalCnt)
        flags.fullCoverage=1;
        flags.noCoverage=0;
        flags.leafUncov=0;
    else
        flags.fullCoverage=0;
        if(~isempty(testobjectiveData.outlocalCnts)&&(testobjectiveData.outlocalCnts(end)~=localCnt))&&...
            (totalCnt~=(testobjectiveData.outlocalCnts(end)+testobjectiveData.justifiedOutlocalCnts(end)))
            flags.leafUncov=1;
        else
            flags.leafUncov=0;
        end
        if testobjectiveData.outTotalCnts==0
            flags.noCoverage=1;
        end
    end

    testobjectiveData.flags=flags;



