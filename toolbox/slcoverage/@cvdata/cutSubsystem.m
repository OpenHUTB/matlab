function newCvd=cutSubsystem(this,targetSubsys)



    try
        newCvd=[];
        rootId=this.rootID;


        cvi.ReportData.updateDataIdx(this);

        toCutRootVariantId=cvi.RootVariant.addRootVariant(rootId,targetSubsys);
        if isempty(toCutRootVariantId)||...
            cv('get',toCutRootVariantId,'.state')==0
            return;
        end


        [metricNames,toMetricNames]=getEnabledMetricNames(this);
        deleteIdx=contains(metricNames,{'sigrange','sigsize'});
        metricNames(deleteIdx==1)=[];
        allMetricNames=[metricNames,toMetricNames];


        topCvId=cv('get',rootId,'.topSlsf');
        descendantCvIds=[topCvId,cv('DecendentsOf',topCvId)];
        sourceIndexMap=cvdata.getMetricIndices(this,descendantCvIds,allMetricNames);



        toCutVariantStates=[];
        path=cv('get',toCutRootVariantId,'.path');
        foundIdx=[];
        origVariantStates=this.getRootVariantStates();
        if~isempty(origVariantStates)
            foundIdx=find([origVariantStates.path]==string(path));

            if~isempty(foundIdx)
                toCutVariantStates=origVariantStates;
                toCutVariantStates(foundIdx).state=0;
            end
        end
        if isempty(foundIdx)
            tvs=[];
            tvs.path=path;
            tvs.variantPath=cv('get',toCutRootVariantId,'.variantPath');
            tvs.state=0;
            if isempty(toCutVariantStates)
                toCutVariantStates=tvs;
            else
                toCutVariantStates(end+1)=tvs;
            end
        end
        this.setRootVariantStates(toCutVariantStates);

        cvi.ReportData.updateDataIdx(this);
        descendantCvIds=[topCvId,cv('DecendentsOf',topCvId)];
        targetIndexMap=cvdata.getMetricIndices(this,descendantCvIds,allMetricNames);


        this.setRootVariantStates(origVariantStates);



        metricStruct=cvdata.processSubsystemMetric(rootId,[],targetIndexMap,...
        this,sourceIndexMap,...
        [],...
        metricNames,toMetricNames,'assign',true);
        newCvd=cvdata;
        newCvd.createDerivedData(this,this,metricStruct,[]);
        newCvd.storeRootVariants();
    catch MEx
        rethrow(MEx);
    end
end
