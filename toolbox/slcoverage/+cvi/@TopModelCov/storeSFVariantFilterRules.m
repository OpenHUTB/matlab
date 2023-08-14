function storeSFVariantFilterRules(modelcovId,testId)




    if~sf('feature','Stateflow Variants')||~strcmpi(cv('Feature','SFVariants'),'on')||testId==0
        return;
    end

    [selectors,isVarTrans]=cvi.TopModelCov.createSFVariantFilterRuleSelectors(modelcovId,[],testId);

    if~isempty(selectors)
        constructorsCode_varTrans={};
        constructorsCode_nonVarTrans={};
        for i=1:numel(selectors)
            if isVarTrans{i}
                constructorsCode_varTrans{end+1}=selectors{i}.ConstructorCode;%#ok<AGROW> 
            else
                constructorsCode_nonVarTrans{end+1}=selectors{i}.ConstructorCode;%#ok<AGROW> 
            end
        end

        if~isempty(constructorsCode_varTrans)
            sfVariant_varTrans.id=char(matlab.lang.internal.uuid);
            sfVariant_varTrans.type='sfvariant_varTrans';
            sfVariant_varTrans.rules=constructorsCode_varTrans;
            sfVariant_varTrans.concatOp=1;

            cvd=cvdata(testId);
            cvd.addFilterData(sfVariant_varTrans);
        end

        if~isempty(constructorsCode_nonVarTrans)
            sfVariant_nonVarTrans.id=char(matlab.lang.internal.uuid);
            sfVariant_nonVarTrans.type='sfvariant_nonVarTrans';
            sfVariant_nonVarTrans.rules=constructorsCode_nonVarTrans;
            sfVariant_nonVarTrans.concatOp=1;

            cvd=cvdata(testId);
            cvd.addFilterData(sfVariant_nonVarTrans);
        end

    end
end


