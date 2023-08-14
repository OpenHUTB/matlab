function modelCovClear(topModelH)

    if cvi.TopModelCov.isTopMostModel(topModelH)
        coveng=cvi.TopModelCov.getInstance(topModelH);
        allModelcovIds=coveng.getAllModelcovIds;


        if strcmpi(get_param(topModelH,'SimulationStatus'),'initializing')
            cvi.TopModelCov.deleteInstance(topModelH);
        end
        for currModelcovId=allModelcovIds(:)'
            cv('ModelcovClear',currModelcovId);
        end

    end