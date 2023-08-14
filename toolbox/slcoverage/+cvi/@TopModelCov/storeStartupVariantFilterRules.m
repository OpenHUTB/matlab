function storeStartupVariantFilterRules(modelH,testId)




    startupVarFilterData=cvi.TopModelCov.createStartupVariantFilterData(modelH,testId);
    if~isempty(startupVarFilterData)
        cvd=cvdata(testId);
        cvd.addFilterData(startupVarFilterData);
    end
end
