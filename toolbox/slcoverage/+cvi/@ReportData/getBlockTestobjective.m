function[testobjData,testobjectiveObjs]=getBlockTestobjective(this,blockInfo,currTestobjCount,metricName)




    testobjectiveEnum=cvi.MetricRegistry.getEnum(metricName);
    [testobjectiveObjs,localIdx,localCnt,justifiedLocalIdx]=cv('MetricGet',blockInfo.cvId,testobjectiveEnum,'.baseObjs',...
    '.dataIdx.shallow','.dataCnt.shallow','.justifiedDataIdx.shallow');

    if isempty(testobjectiveObjs)
        testobjData=[];
        return;
    end

    testobjData.testobjectiveIdx=currTestobjCount+(1:length(testobjectiveObjs));
    testobjData.inBlockIdx=1:numel(testobjectiveObjs);
    [testobjData.outHitCnts,testobjData.justifiedOutHitCnts]=cvi.ReportData.getHits(this.testobjectiveData.(metricName),localIdx,justifiedLocalIdx);
    testobjData.totalCnts=localCnt;
    testobjData.executedIn=this.cvd{1}.getTrace(metricName,localIdx+1,true);

    testobjData.flags=cvi.ReportData.getDecisionBlockFlag(testobjData);

    if testobjData.flags.fullCoverage
        testobjData.justifiedOutHitCnts=zeros(1,numel(testobjData.justifiedOutHitCnts));
    end




