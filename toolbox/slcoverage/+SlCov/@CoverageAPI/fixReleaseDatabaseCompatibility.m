function fixReleaseDatabaseCompatibility(testId,dbVersion,newObjects)







    lessThan22a=str2double(dbVersion(3:end-2))<2022;
    lessThan21a=str2double(dbVersion(3:end-2))<2021;
    lessThen20a=str2double(dbVersion(3:end-2))<2020;
    is22a=contains(dbVersion,'22a');
    is20a=contains(dbVersion,'20a');
    is19b=contains(dbVersion,'19b');

    if lessThan22a||is22a

        updateDynamicArrayInfo(newObjects);
    end

    if lessThan21a

        reaggregateLegacyMcdcXor(testId);
        updateModelInfo(testId);
    end
    if lessThen20a||is20a
        if is19b

            resetTrace(testId);
        end
        if lessThen20a

            fixMetricEnum(testId);
            setHarnessInfo(testId);
        end

        updateFilterApplied(testId);
    end

end

function updateDynamicArrayInfo(newObjects)


    srids=cv('find',newObjects,'.isa',cv('get','default','sigranger.isa'));
    for idx=1:length(srids)
        nports=numel(cv('get',srids(idx),'.cov.allWidths'));

        cv('set',srids(idx),'.cov.isDynamic',zeros(1,nports));
    end
end

function setHarnessInfo(testId)

    cvd=cvdata(testId);
    rmi=cvd.getRawModelInfo;
    ownerModel=rmi.ownerModel;
    harnessModel=rmi.harnessModel;

    modelcovId=cv('get',cvd.rootId,'.modelcov');
    if strcmpi(harnessModel,'notUnique')

        harnessModel=cv('get',modelcovId,'.harnessModel');
    end

    if~isempty(ownerModel)
        if~bdIsLoaded(ownerModel)
            try
                load_system(ownerModel);
                modelH=get_param(ownerModel,'handle');
            catch Mex %#ok<NASGU>
                modelH=0;
            end
            if(modelH==0)
                error(message('Slvnv:simcoverage:cvload:LoadError',ownerModel));
            end

        end
        allHarnesses=Simulink.harness.internal.getAllHarnesses(ownerModel);
        harnessInfo=allHarnesses({allHarnesses.name}==string(harnessModel));
        if~isempty(harnessInfo)
            covHarnessInfo=cvi.TopModelCov.getCovHarnessInfo(harnessInfo);
            covengProxy.ownerModel=covHarnessInfo.ownerModel;
            covengProxy.harnessModel=covHarnessInfo.harnessModel;
            covengProxy.ownerBlock=covHarnessInfo.ownerBlock;
            covengProxy.ownerType=covHarnessInfo.ownerType;
            covengProxy.keepHarnessCvData=covHarnessInfo.keepHarnessCvData;
            covengProxy.forceTopModelResultsRemoval=covHarnessInfo.forceTopModelResultsRemoval;

            cvi.TopModelCov.storeHarnessInfo(covengProxy,modelcovId,testId)
        end
    end
end

function updateModelInfo(testId)

    fieldNames={'.analyzedModel','.ownerModel','.ownerBlock','.harnessModel'};
    for idx=1:numel(fieldNames)
        fn=fieldNames{idx};
        if strcmpi(cv('get',testId,fn),getString(message('Slvnv:simcoverage:cvdata:NotUnique')))
            cv('set',testId,fn,'notUnique');
        end
    end
    if strcmpi(cv('get',testId,'.blockReductionStatus'),getString(message('Slvnv:simcoverage:cvhtml:BlockReductionForcedOff')))
        cv('set',testId,'.blockReductionStatus','forcedOff');
    end
end

function updateFilterApplied(testId)


    cvd=cvdata(testId);
    rootId=cvd.rootId;
    nFA=cvi.TopModelCov.getFilterAppliedStruct();
    cv('set',rootId,'.filterApplied',nFA);
end

function resetTrace(testId)



    cv('set',testId,'.traceOn',0);
    cvd=cvdata(testId);
    cvd.resetTrace();
end


function fixMetricEnum(testId)








    metricDatas=cv('get',testId,'.testobjectives');

    if isempty(metricDatas)
        return;
    end
    metricDatas(metricDatas==0)=[];
    sbMetricData=cv('find',metricDatas,'.metricenumValue',14);

    if strcmpi(cv('get',sbMetricData,'.metricName'),'cvmetric_Structural_block')
        return;
    end
    testobjectives=cv('get',testId,'.testobjectives');
    newTestobjectives=[];
    for idxT=1:numel(testobjectives)
        if testobjectives(idxT)~=0
            metricData=testobjectives(idxT);
            metricName=cv('get',testobjectives(idxT),'.metricName');
            metricEnum=cv('get',testobjectives(idxT),'.metricenumValue');
            newMetricEnum=cvi.MetricRegistry.getEnum(metricName);
            if metricEnum~=newMetricEnum
                cv('set',metricData,'.metricenumValue',newMetricEnum);
            end
            newTestobjectives(newMetricEnum)=testobjectives(metricEnum);%#ok<AGROW>
        end
    end
    cv('set',testId,'.testobjectives',newTestobjectives);
    cvd=cvdata(testId);
    rootId=cvd.rootId;
    topSlsf=cv('get',rootId,'.topSlsf');
    allIds=cv('DecendentsOf',topSlsf);
    allIds=[topSlsf,allIds];%#ok<AGROW>
    for idxI=1:numel(allIds)
        cvid=allIds(idxI);
        mapMetricObjs(cvid);
    end
end

function mapMetricObjs(cvid)







    oldEnums=[0,1,3,4,5,6,7,8,9,10,11,12,13,14];
    newEnums=[0,1,3,4,5,6,7,11,12,13,14,8,9,10];

    newMetricObjs=getMetricObj(cvid,newEnums);
    newdBitFlag=0;
    for idx=1:numel(oldEnums)

        if newMetricObjs(idx)>0
            newdBitFlag=bitset(newdBitFlag,oldEnums(idx)+1,1);
        end
    end

    newMetricObjs(newMetricObjs==0)=[];

    cv('set',cvid,'.metricFlag',newdBitFlag);

    cv('set',cvid,'.metrics',newMetricObjs);
end


function metricObjs=getMetricObj(cvid,enumMap)
    metricObjs=[];
    for idx=1:numel(enumMap)
        metricObjs(idx)=cv('SlsfGetMetric',cvid,enumMap(idx));%#ok<AGROW>
    end
end




function reaggregateLegacyMcdcXor(testId)



    needsFix=false;
    allSlSfIds=getAllSlSfObj(testId);
    for slIdx=1:length(allSlSfIds)
        slsfObjId=allSlSfIds(slIdx);
        if(slsfObjId>0)
            mcdcIds=getMcdcObjs(slsfObjId);
            if any(isLegacyXorMcdc(mcdcIds))
                needsFix=true;
                break;
            end
        end
    end

    if needsFix

        cvd=cvdata(testId);
        if~isempty(cvd)
            metricData=cvd.metrics.mcdc;
            if~isempty(metricData)
                rootId=cvd.rootId;
                mcdcEnumVal=getMcdcEnum();
                metricDataFixed=cv('ProcessData',rootId,mcdcEnumVal,metricData);
                cv('set',testId,'testdata.data.mcdc',metricDataFixed);
            end
        end
    end
end

function res=isLegacyXorMcdc(mcdcIds)


    EXPR_MIXED_GENERIC=0;
    SHRTCIRCUIT_OFF=1;

    mcdcIds(mcdcIds==0)=[];
    if isempty(mcdcIds)
        res=false;
        return;
    end

    [exprType,shortCircuiting,isCascMCDC]=...
    cv('get',mcdcIds,'.exprType','.shortCircuiting','.cascMCDC.isCascMCDC');

    res=(exprType==EXPR_MIXED_GENERIC)&...
    (shortCircuiting==SHRTCIRCUIT_OFF)&...
    (isCascMCDC==false);
end

function allSlSfIds=getAllSlSfObj(testId)
    allSlSfIds=[];
    try
        cvd=cvdata(testId);
        rootId=cvd.rootId;
        if~isempty(rootId)&&(rootId>0)
            topSlsf=cv('get',rootId,'.topSlsf');
            if(topSlsf>0)
                allSlSfIds=cv('DecendentsOf',topSlsf);
            end
        end
    catch
        allSlSfIds=[];
    end
end

function mcdcIds=getMcdcObjs(slsfObjId)
    mcdcEnumVal=getMcdcEnum();
    metricObj=cv('SlsfGetMetric',slsfObjId,mcdcEnumVal);
    mcdcIds=cv('get',metricObj,'.baseObjs');
end

function mcdcEnumVal=getMcdcEnum()
    persistent mcdcEnum
    if isempty(mcdcEnum)
        mcdcEnum=cvi.MetricRegistry.getEnum('mcdc');
    end
    mcdcEnumVal=mcdcEnum;
end
