function newCvd=addSubsystem(this,targetSubsys,cvd)



    newCvd=[];
    if~valid(this)||~valid(cvd)
        error(message('Slvnv:simcoverage:cvdata:InvalidCvData',2));
    end



    if SlCov.CovMode.isGeneratedCode(this.simMode)&&SlCov.CovMode.isGeneratedCode(cvd.simMode)
        if~isempty(this.codeCovData)&&~isempty(cvd.codeCovData)&&...
            (this.isAtomicSubsystemCode||cvd.isAtomicSubsystemCode)
            lhsCksum=cvd.codeCovData.CodeTr.computeChecksum(true);
            rhsCksum=this.codeCovData.CodeTr.computeChecksum(true);
            if isequal(lhsCksum,rhsCksum)
                newCvd=this+cvd;
            end
        end
        return
    end

    targetCvId=findTargetCvId(this,targetSubsys,cvd);

    if isempty(targetCvId)

        return;
    end


    [metricNames,toMetricNames]=cvi.MetricRegistry.getAllMetricNames;
    deleteIdx=contains(metricNames,{'sigrange','sigsize'});
    metricNames(deleteIdx==1)=[];

    allMetricNames=[metricNames,toMetricNames];

    targetDescendantCvIds=[targetCvId,cv('DecendentsOf',targetCvId)];
    targetIndexMap=cvdata.getMetricIndices(this,targetDescendantCvIds,allMetricNames);

    sourceCvId=cv('get',cvd.rootID,'.topSlsf');
    sourceDescendantCvIds=[sourceCvId,cv('DecendentsOf',sourceCvId)];
    sourceIndexMap=cvdata.getMetricIndices(cvd,sourceDescendantCvIds,allMetricNames);

    joinedAggregatedTestInfo=cv.internal.cvdata.joinAggregatedTestInfo(this,cvd);

    oldTraceOn=this.traceOn;
    this.traceOn=cvd.traceOn;

    [metricStruct,traceStruct]=cvdata.processSubsystemMetric(this.rootID,this,targetIndexMap,...
    cvd,sourceIndexMap,...
    joinedAggregatedTestInfo,...
    metricNames,toMetricNames,'plus',false);
    [joinedAggregatedTestInfo,traceStruct]=cv.internal.cvdata.removeDuplicateTestTraces(joinedAggregatedTestInfo,traceStruct);
    newCvd=cvdata;
    newCvd.createDerivedData(this,this,metricStruct,traceStruct);
    this.traceOn=oldTraceOn;
    cv.internal.cvdata.aggregateUniqueIds(newCvd,this,cvd);
    newCvd.aggregatedTestInfo=joinedAggregatedTestInfo;
end

function targetCvId=findTargetCvId(this,targetSubsys,cvd)
    targetCvId=[];
    subsysCvId=cvprivate('find_block_cv_id',this.rootID,targetSubsys);
    if ischar(subsysCvId)
        return;
    end
    targetCheckSum=cv('get',subsysCvId,'.cvChecksum');
    sourceCheckSum=cv('get',cvd.rootId,'.checksum');
    if isequal(targetCheckSum,...
        sourceCheckSum)
        targetCvId=subsysCvId;
    end

end


