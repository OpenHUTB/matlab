function[mcdcData,mcdcObjs]=getMcdcSystem(this,sysEntry,currMcdcCnt)






    flags=[];


    metricEnum=cvi.MetricRegistry.getEnum('mcdc');
    [mcdcObjs,...
    justifiedLocalIdx,justifiedTotalIdx,...
    localIdx,localCnt,varLocalCntIdx,totalIdx,totalCnt,varTotalCntIdx,hasVariableSize]=cv('MetricGet',sysEntry.cvId,...
    metricEnum,'.baseObjs',...
    '.justifiedDataIdx.shallow','.justifiedDataIdx.deep',...
    '.dataIdx.shallow','.dataCnt.shallow','.dataCnt.varShallowIdx',...
    '.dataIdx.deep','.dataCnt.deep','.dataCnt.varDeepIdx','.hasVariableSize');

    if isempty(totalCnt)
        localIdx=-1;
        totalIdx=-1;
        totalCnt=0;
        localCnt=0;
    end

    if totalCnt==0
        mcdcData=[];
        return;
    end

    mcdcMetricData=this.metricData.mcdc;
    mcdcData.mcdcIndex=currMcdcCnt+(1:length(mcdcObjs));
    mcdcData.inBlockIdx=1:numel(mcdcObjs);
    if localIdx==-1
        mcdcData.localHits=[];
        mcdcData.justifiedLocalHits=[];
        mcdcData.executedIn='';
    else
        [mcdcData.localHits,mcdcData.justifiedLocalHits]=cvi.ReportData.getHits(mcdcMetricData,localIdx,justifiedLocalIdx);
        mcdcData.executedIn='';
    end

    [mcdcData.totalHits,mcdcData.justifiedTotalHits]=cvi.ReportData.getHits(mcdcMetricData,totalIdx,justifiedTotalIdx);

    if hasVariableSize
        if varLocalCntIdx>0
            localCnt=mcdcMetricData(varLocalCntIdx+1,end);
        end
        totalCnt=mcdcMetricData(varTotalCntIdx+1,end);
    end
    mcdcData.localCnt=localCnt;
    mcdcData.totalCnt=totalCnt;
    mcdcData.totalExecutedIn='';

    if(mcdcData.totalHits(end)==totalCnt)
        flags.fullCoverage=1;
        flags.noCoverage=0;
        flags.leafUncov=0;
    else
        flags.fullCoverage=0;
        if(~isempty(mcdcData.localHits)&&(mcdcData.localHits(end)~=localCnt))&&...
            (localCnt~=(mcdcData.localHits(end)+mcdcData.justifiedLocalHits(end)))
            flags.leafUncov=1;
        else
            flags.leafUncov=0;
        end
        if mcdcData.totalHits(end)==0
            flags.noCoverage=1;
        else
            flags.noCoverage=0;
        end
    end
    mcdcData.flags=flags;


