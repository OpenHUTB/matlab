function[condData,condObjs]=getConditionSystem(this,sysEntry,currCondCnt)





    condData=[];
    conditionData=this.metricData.condition;

    flags=[];

    metricEnum=cvi.MetricRegistry.getEnum('condition');
    [condObjs,justifiedLocalIdx,justifiedTotalIdx,...
    localIdx,localCnt,varLocalCntIdx,totalIdx,totalCnt,varTotalCntIdx,hasVariableSize,hasLocalVariableSize]=cv('MetricGet',sysEntry.cvId,...
    metricEnum,'.baseObjs',...
    '.justifiedDataIdx.shallow','.justifiedDataIdx.deep',...
    '.dataIdx.shallow','.dataCnt.shallow','.dataCnt.varShallowIdx',...
    '.dataIdx.deep','.dataCnt.deep','.dataCnt.varDeepIdx','.hasVariableSize','.hasLocalVariableSize');

    if isempty(totalCnt)||totalCnt==0

        return;
    end

    condData.conditionIdx=currCondCnt+(1:length(condObjs));
    condData.inBlockIdx=1:numel(condObjs);
    if localIdx==-1
        condData.localHits=[];
        condData.justifiedLocalHits=[];
        condData.executedIn='';
    else
        [condData.localHits,condData.justifiedLocalHits]=cvi.ReportData.getHits(conditionData,localIdx,justifiedLocalIdx);
        condData.executedIn='';
    end
    [condData.totalHits,condData.justifiedTotalHits]=cvi.ReportData.getHits(conditionData,totalIdx,justifiedTotalIdx);
    condData.condCount=length(condObjs);
    condData.totalExecutedIn='';

    if hasVariableSize
        totalCnt=conditionData(varTotalCntIdx+1,end);
    end
    if hasLocalVariableSize
        localCnt=conditionData(varLocalCntIdx+1,end);
    end

    condData.localCnt=localCnt;
    condData.totalCnt=totalCnt;


    if(condData.totalHits(end)==totalCnt)
        flags.fullCoverage=1;
        flags.noCoverage=0;
        flags.leafUncov=0;
    else
        flags.fullCoverage=0;
        if(~isempty(condData.localHits)&&(condData.localHits(end)~=localCnt))&&...
            (localCnt~=(condData.localHits(end)+condData.justifiedLocalHits(end)))
            flags.leafUncov=1;
        else
            flags.leafUncov=0;
        end
        if condData.totalHits(end)==0
            flags.noCoverage=1;
        else
            flags.noCoverage=0;
        end
    end

    condData.flags=flags;

