function buildTraceMask(this)









    this.traceMask=[];
    if(~this.scopeDataToReqs)||(~this.traceOn)||isempty(this.trace)
        return;
    end

    [metricNames,toMetricNames]=getEnabledMetricNames(this);
    deleteIdx=contains(metricNames,{'sigrange','sigsize'});
    metricNames(deleteIdx==1)=[];
    allMetricNames=[metricNames,toMetricNames];
    isTOmetric=[zeros(1,numel(metricNames)),ones(1,numel(toMetricNames))];

    cvi.ReportUtils.checkHarnessData(this);
    scopedCvIdsByTest=getCvIdsScopedToTests(this);
    allCvIds=unique([scopedCvIdsByTest{:}]);
    targetIndexMap=this.getMetricIndices(this,allCvIds,allMetricNames);

    traceStruct=this.trace;
    for metricIdx=1:length(allMetricNames)
        metricName=allMetricNames{metricIdx};

        if isTOmetric(metricIdx)
            tempTraceStruct=traceStruct.testobjectives;
        else
            tempTraceStruct=traceStruct;
        end

        if~isfield(tempTraceStruct,metricName)
            continue;
        end

        curTrace=tempTraceStruct.(metricName);
        locTraceMask=buildTraceMaskForMetric(curTrace,metricName,scopedCvIdsByTest,targetIndexMap);
        this.traceMask.(metricName)=locTraceMask;
    end
end

function scopedCvIds=getCvIdsScopedToTests(this)





    scopedCvIds={};
    atiList=this.aggregatedTestInfo;
    for atiIdx=1:numel(atiList)
        ati=atiList(atiIdx);

        linkedModelItems=getReqLinkedModelItems(this.reqTestMapInfo,ati.testRunInfo.runId);





        linkedModelItems=this.mapToHarnessSID(linkedModelItems);

        scopedCvIds{atiIdx}=this.findCvIdsInScope(linkedModelItems,false);%#ok<AGROW>
    end


end


function linkedModelItems=getReqLinkedModelItems(reqInfo,runId)



    linkedModelItems={};
    if isempty(reqInfo)
        return;
    end

    try
        simIdx=strcmp({reqInfo.Simulation.RunId},runId);
        testIdx=reqInfo.Simulation(simIdx).TestIdx;
        test=reqInfo.Test(testIdx);
        verifyLinks=reqInfo.VerifyLink([test.VerifyInd]);
        requirements=reqInfo.Requirement([verifyLinks.RequirementIdx]);
        implLinks=reqInfo.ImplementLink([requirements.ImplementInd]);
        modelItems=reqInfo.ModelItem(unique([implLinks.ModelItemIdx]));
        linkedModelItems={modelItems.SID};
    catch
        linkedModelItems={};
    end
end


function traceMask=buildTraceMaskForMetric(curTrace,metricName,targetCvIdsByTest,targetIndexMap)












    traceMask=zeros(size(curTrace),'logical');
    for testIdx=1:length(targetCvIdsByTest)
        curScopedCvIdsForTest=targetCvIdsByTest{testIdx};

        for cvidIdx=1:length(curScopedCvIdsForTest)
            cvId=curScopedCvIdsForTest(cvidIdx);
            targetIndices=getTargetIndices(targetIndexMap,cvId,metricName);

            for ii=1:numel(targetIndices)
                targetIndex=targetIndices(ii).idx;
                targetSize=targetIndices(ii).size;
                targetIdxRange=targetIndex:targetIndex+targetSize-1;

                traceMask(targetIdxRange,testIdx)=true;
            end
        end
    end
    traceMask=sparse(traceMask);
end

function res=getTargetIndices(targetIndexMap,cvId,metricName)

    tIdx=([targetIndexMap.cvId]==cvId);
    res=targetIndexMap(tIdx).metricIndex.(metricName);
end

