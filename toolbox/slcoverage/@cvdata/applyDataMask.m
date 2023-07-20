function newCvd=applyDataMask(this,targetCvIds)



    [metricNames,toMetricNames]=getEnabledMetricNames(this);
    deleteIdx=contains(metricNames,{'sigrange','sigsize'});
    metricNames(deleteIdx==1)=[];
    allMetricNames=[metricNames,toMetricNames];


    tmpCvd=cvdata;
    tmpCvd.createDerivedData(this,this,this.metrics,this.trace);
    tmpCvd.testRunInfo=this.testRunInfo;
    joinedAggregatedTestInfo=cv.internal.cvdata.createAggregatedTestInfo(tmpCvd);


    targetIndexMap=tmpCvd.getMetricIndices(tmpCvd,targetCvIds,allMetricNames);

    [metricStruct,traceStruct]=cvdata.processSubsystemMetric(tmpCvd.rootID,tmpCvd,targetIndexMap,...
    [],targetIndexMap,...
    joinedAggregatedTestInfo,...
    metricNames,toMetricNames,'reset',true);



    newCvd=cvdata;
    newCvd.createDerivedData(this,this,metricStruct,traceStruct);
    newCvd.testRunInfo=this.testRunInfo;
    newCvd.aggregatedTestInfo=cv.internal.cvdata.createAggregatedTestInfo(newCvd);
end


