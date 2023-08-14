function lhs_cvdata=extract(rhs_cvdata,subsysH)





    if~valid(rhs_cvdata)
        error(message('Slvnv:simcoverage:cvdata:InvalidCvData',2));
    end


    if Sldv.utils.isAtomicSubchartSubsystem(subsysH)
        error(message('Slvnv:simcoverage:cvdata:NotSupportedExtractionAtomicSubchart'));
    end

    subsysCvId=cvprivate('find_block_cv_id',rhs_cvdata.rootID,subsysH);
    if cvi.CascMCDC.hasCrossBoundaryCascade(subsysCvId)
        error(message('Slvnv:simcoverage:cvdata:NotSupportedCascadedMCDCCrossingBoundaries'));
    end

    lhs_cvdata=[];

    [metricNames,toMetricNames]=cvi.MetricRegistry.getAllMetricNames;
    deleteIdx=contains(metricNames,{'sigrange','sigsize'});
    metricNames(deleteIdx==1)=[];




    allMetricNames=[metricNames,toMetricNames];



    cvi.ReportData.updateDataIdx(rhs_cvdata);

    [lhs_rootId,sourceCvId]=getTargetRootId(get_param(subsysH,'handle'),rhs_cvdata);
    if isempty(lhs_rootId)
        return;
    end
    if lhs_rootId==rhs_cvdata.rootId
        lhs_cvdata=rhs_cvdata;
        return;
    end


    descendantSourceCvIds=[sourceCvId,cv('DecendentsOf',sourceCvId)];
    sourceIndexMap=cvdata.getMetricIndices(rhs_cvdata,descendantSourceCvIds,allMetricNames);


    lhs_cvdata=cvdata;
    lhs_cvdata.createDerivedData(rhs_cvdata,rhs_cvdata,[],[]);
    lhs_cvdata.localData.rootId=lhs_rootId;
    lhs_cvdata.storeRootVariants();

    cvi.ReportData.updateDataIdx(lhs_cvdata);
    targetIndexMap=cvdata.getMetricIndices(lhs_cvdata,descendantSourceCvIds,allMetricNames);



    metricStruct=cvdata.processSubsystemMetric(lhs_rootId,[],targetIndexMap,...
    rhs_cvdata,sourceIndexMap,...
    [],...
    metricNames,toMetricNames,'assign',true);

    mFileds=fields(rhs_cvdata.metrics);
    for idx=1:numel(mFileds)
        cmf=mFileds{idx};
        if isempty(rhs_cvdata.metrics.(cmf))
            metricStruct.(cmf)=[];
        end
    end

    metricStruct.sigrange=[];
    metricStruct.sigsize=[];

    lhs_cvdata.setMetricData(metricStruct);
    tchk=cv('get',lhs_rootId,'.checksum');
    checksum.u1=tchk(1);
    checksum.u2=tchk(2);
    checksum.u3=tchk(3);
    checksum.u4=tchk(4);
    lhs_cvdata.localData.checksum=checksum;
    lhs_cvdata.localData.modelinfo.analyzedModel=getfullname(subsysH);
    lhs_cvdata.storeRootVariants();

end

function[rootId,subsysCvId]=getTargetRootId(subsysH,cvd)
    subsysCvId=cvprivate('find_block_cv_id',cvd.rootID,subsysH);
    rootId=[];
    if ischar(subsysCvId)||isempty(subsysCvId)
        return;
    end
    rootId=getRootId(subsysCvId,subsysH);
    if isempty(rootId)

        modelcovId=cv('get',subsysCvId,'.modelcov');
        rootId=cvi.TopModelCov.createRoot(modelcovId,subsysH);
        cv('set',rootId,'.topSlsf',subsysCvId);
        setTestObjectives(rootId)
        cv('InsertRoot',rootId);
        cv('RootUpdateChecksum',rootId);
    end
end

function setTestObjectives(rootId)
    [~,allTOMetricNames]=cvi.MetricRegistry.getAllMetricNames;
    for i=1:numel(allTOMetricNames)
        cmn=allTOMetricNames{i};
        metricenumValue=cvi.MetricRegistry.getEnum(cmn);
        metricdataIds(metricenumValue)=cv('new','metricdata','.metricName',cmn,'.metricenumValue',metricenumValue);%#ok<AGROW>
    end
    cv('set',rootId,'.testobjectives',metricdataIds);
end


function rootId=getRootId(subsysCvId,subsysH)
    rootId=[];
    modelCvId=cv('get',subsysCvId,'.modelcov');
    roots=cv('RootsIn',modelCvId);
    subsysH=get_param(subsysH,'handle');
    for idx=1:numel(roots)
        h=cv('get',roots(idx),'.topSlHandle');
        if h==subsysH
            rootId=roots(idx);
        end
    end
end

function fname=checkFilter(lhd,rhd)

    lfileName=lhd.filter;
    rfileName=rhd.filter;

    fname=[];
    if strcmpi(rfileName,lfileName)
        fname=rfileName;
    end
    applyFilter(lhd,fname);
    applyFilter(rhd,fname);

end
