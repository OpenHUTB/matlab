






function results=getAggregatedCoverage(resources,modelNames,coverageKey)

    results=[];

    if isempty(resources)
        return
    end

    if isempty(resources.CoverageFragment)
        return
    end

    anyCoverage=false;
    satisfied=0;
    justified=0;
    total=0;
    for i=1:numel(modelNames)


        covFragment=resources.CoverageFragment(...
        [resources.CoverageFragment.Model]==modelNames{i});
        if~isempty(covFragment)
            covData=covFragment.CoverageData;
        else
            covData=[];
        end

        if isempty(covData)
            continue
        end


        if isequal(coverageKey,cvmetric.Structural.block)||...
            covData.test.settings.(coverageKey)

            [numSatisfied,numJustified,numTotal]=...
            SlCov.CoverageAPI.getHitCount(covData,modelNames{i},coverageKey);

            satisfied=satisfied+numSatisfied;
            justified=justified+numJustified;
            total=total+numTotal;
            anyCoverage=true;
        end
    end

    if anyCoverage
        results.satisfied=satisfied;
        results.justified=justified;
        results.missed=total-satisfied-justified;
        results.total=total;
    end

end

