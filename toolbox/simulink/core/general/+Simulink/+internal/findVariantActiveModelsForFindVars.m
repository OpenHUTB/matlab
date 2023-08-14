function models=findVariantActiveModelsForFindVars(model,allLevels)




    if Simulink.internal.useFindSystemVariantsMatchFilter()

        [models,~]=find_mdlrefs(model,'AllLevels',allLevels,...
        'MatchFilter',@Simulink.match.codeCompileVariants);
    else

        [models,~]=find_mdlrefs(model,'AllLevels',allLevels);
    end
end
