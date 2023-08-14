function setModelCovFilterApplied(modelCovId,filterAppliedStruct)





    roots=cv('RootsIn',modelCovId);
    for idx=1:numel(roots)
        cv('set',roots(idx),'.filterApplied',filterAppliedStruct);
    end
end

