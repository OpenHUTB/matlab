function[condData,condObjs]=getConditionBlock(this,blockInfo,currCondCnt)






    conditionData=this.metricData.condition;

    flags=[];


    metricEnum=cvi.MetricRegistry.getEnum('condition');
    [condObjs,localIdx,localCnt,justifiedLocalIdx,varLocalCntIdx,hasLocalVariableSize]=cv('MetricGet',blockInfo.cvId,metricEnum,'.baseObjs',...
    '.dataIdx.shallow','.dataCnt.shallow',...
    '.justifiedDataIdx.shallow',...
    '.dataCnt.varShallowIdx','.hasLocalVariableSize');
    if isempty(localCnt)||localCnt==0
        condData=[];
        return;
    end
    condData.conditionIdx=currCondCnt+(1:length(condObjs));
    condData.inBlockIdx=1:numel(condObjs);
    [condData.localHits,condData.justifiedLocalHits]=cvi.ReportData.getHits(conditionData,localIdx,justifiedLocalIdx);
    condData.condCount=length(condObjs);

    if hasLocalVariableSize
        localCnt=conditionData(varLocalCntIdx+1,end);
    end
    condData.localCnt=localCnt;

    flags.justified=any(condData.justifiedLocalHits>0);
    if(condData.localHits(end)==localCnt)
        flags.fullCoverage=1;
        flags.noCoverage=0;
        flags.leafUncov=0;
    else
        flags.fullCoverage=0;
        flags.leafUncov=1;
        if(localCnt==(condData.localHits(end)+condData.justifiedLocalHits(end)))
            flags.leafUncov=0;
        end

        if condData.localHits(end)==0
            flags.noCoverage=1;
        else
            flags.noCoverage=0;
        end
    end
    condData.executedIn=this.cvd{1}.getTrace('condition',localIdx+1,true);
    condData.flags=flags;

