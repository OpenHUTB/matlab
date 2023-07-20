function schema



    schema.package('SlCovCC');

    if isempty(findtype('SlCovCC.CovMetricStructuralLevelEnum'))
        schema.EnumType('SlCovCC.CovMetricStructuralLevelEnum',{'BlockExecution','Decision','ConditionDecision','MCDC'});
    end

    if isempty(findtype('SlCovCC.CovScopeEnum'))
        schema.EnumType('SlCovCC.CovScopeEnum',{'EntireSystem','ReferencedModels','Subsystem'});
    end

    if isempty(findtype('SlCovCC.CovMcdcMode'))
        schema.EnumType('SlCovCC.CovMcdcModeEnum',{'UniqueCause','Masking'});
    end
