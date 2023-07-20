function[decData,decObjs]=getDecisionBlock(this,blockInfo,currDecCount)





    decisionData=this.metricData.decision;

    metricEnum=cvi.MetricRegistry.getEnum('decision');
    [decObjs,localIdx,localCnt,justifiedLocalIdx,varLocalCntIdx,hasLocalVariableSize]=cv('MetricGet',blockInfo.cvId,metricEnum,'.baseObjs',...
    '.dataIdx.shallow','.dataCnt.shallow',...
    '.justifiedDataIdx.shallow',...
    '.dataCnt.varShallowIdx','.hasLocalVariableSize');

    if isempty(decObjs)
        decData=[];
        return;
    end

    decData.decisionIdx=currDecCount+(1:length(decObjs));
    decData.inBlockIdx=1:numel(decObjs);
    [decData.outHitCnts,decData.justifiedOutHitCnts]=cvi.ReportData.getHits(decisionData,localIdx,justifiedLocalIdx);

    if hasLocalVariableSize
        localCnt=decisionData(varLocalCntIdx+1,end);
    end
    decData.totalCnts=localCnt;
    decData.executedIn=this.cvd{1}.getTrace('decision',localIdx+1,true);
    decData.flags=cvi.ReportData.getDecisionBlockFlag(decData);




