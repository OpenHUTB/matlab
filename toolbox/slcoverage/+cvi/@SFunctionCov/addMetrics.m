function addMetrics(coveng,sfcnBlkH)












    allmetrics=cvi.MetricRegistry.getDDEnumVals();
    relOpMetricId=cvi.MetricRegistry.getEnum('cvmetric_Structural_relationalop');

    for ii=1:numel(sfcnBlkH)

        sfcnName=SlCov.Utils.fixSFunctionName(get_param(sfcnBlkH(ii),'FunctionName'));


        if~coveng.slccCov.sfcnCov.sfcnName2Info.isKey(sfcnName)

            continue
        end
        sfcnInfo=coveng.slccCov.sfcnCov.sfcnName2Info(sfcnName);


        covId=get_param(sfcnBlkH(ii),'CoverageId');
        if covId<1
            continue
        end


        coveng.slccCov.sfcnCov.sfcnBlkH2CovId(sfcnBlkH(ii))=covId;


        if sfcnInfo.numDec>0
            cv('defineSFunctionMetric',covId,allmetrics.MTRC_DECISION,sfcnInfo.numDec,sfcnInfo.numDecOutcomes);
        end

        if sfcnInfo.numCond>0
            cv('defineSFunctionMetric',covId,allmetrics.MTRC_CONDITION,sfcnInfo.numCond);
        end

        if~isempty(sfcnInfo.truthTablesForMCDC)
            cv('defineSFunctionMetric',covId,allmetrics.MTRC_MCDC,sfcnInfo.truthTablesForMCDC,sfcnInfo.exprsForMCDC,sfcnInfo.condsForMCDC);
        end

        if sfcnInfo.numCyclo>0
            cv('defineSFunctionMetric',covId,allmetrics.MTRC_CYCLCOMPLEX)
        end

        if sfcnInfo.numRelOp>0
            cv('defineSFunctionMetric',covId,relOpMetricId,sfcnInfo.numRelOp,sfcnInfo.numRelOpOutcomes);
        end

    end
