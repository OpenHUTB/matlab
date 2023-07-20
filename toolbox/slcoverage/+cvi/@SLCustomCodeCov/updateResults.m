function updateResults(coveng,forPause)







    if nargin<2
        forPause=false;
    end


    if coveng.slccCov.covId2ScriptName.isempty()
        return
    end



    cvt=cvi.SLCustomCodeCov.getCvTest(coveng);
    if isempty(cvt)
        return
    end


    settings=cvt.settings;
    hasDec=settings.decision;
    hasCond=settings.condition;
    hasMcdc=settings.mcdc;
    hasRelationalBoundary=settings.relationalop;


    allmetrics=cvi.MetricRegistry.getDDEnumVals();
    if hasRelationalBoundary
        relOpMetricId=cvi.MetricRegistry.getEnum('cvmetric_Structural_relationalop');
    end

    covIds=coveng.slccCov.covId2ScriptName.keys();
    covId2Remove=[];
    for ii=1:numel(covIds)

        fileCovId=covIds{ii};

        testId=cv('get',fileCovId,'.currentTest');
        ccCovGrp=cv('get',testId,'.data.sfcnCovData');
        rootId=cv('get',fileCovId,'.activeRoot');
        covId=cv('get',rootId,'.topSlsf');
        covId=cv('get',covId,'.treeNode.child');
        if isempty(ccCovGrp)||~hasResults(ccCovGrp)
            if~forPause
                covId2Remove=[covId2Remove,fileCovId];%#ok<AGROW>
            end
            continue
        end



        ccCovRes=ccCovGrp.getAll();
        ccCovRes=ccCovRes(1);


        codeCovDataObj=ccCovRes.CodeCovDataImpl;


        if hasDec
            cv('setSFunctionMetricHit',covId,allmetrics.MTRC_DECISION,{codeCovDataObj,0});
        end
        if hasCond
            cv('setSFunctionMetricHit',covId,allmetrics.MTRC_CONDITION,{codeCovDataObj,0});
        end
        if hasMcdc
            cv('setSFunctionMetricHit',covId,allmetrics.MTRC_MCDC,{codeCovDataObj,0});
        end
        cv('setSFunctionMetricHit',covId,allmetrics.MTRC_CYCLCOMPLEX,{codeCovDataObj,0});
        if hasRelationalBoundary
            cv('setSFunctionMetricHit',covId,relOpMetricId,{codeCovDataObj,0});
        end


        covdata=cvdata(testId);
        cvi.TopModelCov.setUpFiltering(coveng.topModelH,covdata);
    end


    if~isempty(covId2Remove)
        topModelcovId=cv('get',covId2Remove(1),'.topModelcovId');
        refModelcovIds=cv('get',topModelcovId,'.refModelcovIds');
        for currModelcovId=covId2Remove
            cv('ModelClose',currModelcovId);
            cv('delete',currModelcovId);
            refModelcovIds(refModelcovIds==currModelcovId)=[];
        end
        cv('set',topModelcovId,'.refModelcovIds',refModelcovIds);
    end


