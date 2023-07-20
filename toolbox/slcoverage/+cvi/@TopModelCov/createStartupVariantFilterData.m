function startupVarFilterData=createStartupVariantFilterData(modelH,testId)




    startupVarFilterData=[];

    if~cvi.TopModelCov.isStartupVariantCoverageSupported()||...
        ~strcmpi(cv('Feature','filterInactiveStartupVariants'),'on')||...
        testId==0
        return;
    end

    selectors=cvi.TopModelCov.createStartupVariantFilterRuleSelectors(modelH,testId);

    if~isempty(selectors)
        constructorsCode=cell(size(selectors));
        for i=1:numel(selectors)
            constructorsCode{i}=selectors{i}.ConstructorCode;
        end
        startupVarFilterData.id=char(matlab.lang.internal.uuid);
        startupVarFilterData.type='startupvariant';
        startupVarFilterData.rules=constructorsCode;
        startupVarFilterData.concatOp=1;
    end

end


