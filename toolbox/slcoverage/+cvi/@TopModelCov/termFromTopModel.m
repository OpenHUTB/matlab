function termFromTopModel(topModelH)




    try
        coveng=cvi.TopModelCov.getInstance(topModelH);
        allModelcovIds=coveng.getAllModelcovIds;
        topModelcovId=get_param(topModelH,'CoverageId');
        for modelcovId=allModelcovIds(:)'
            if topModelcovId~=modelcovId
                cvi.TopModelCov.term(modelcovId);
            end
        end
        if~isempty(coveng.covModelRefData)
            coveng.covModelRefData.term;
            coveng.covModelRefData=[];
        end
        coveng.scriptDataMap=[];
        coveng.scriptNumToCvIdMap=[];
        coveng.lastReportingModelH=[];

    catch MEx
        rethrow(MEx);
    end


