function categories=allowedDataCategoriesForExternalUse(modelMapping)




    if isa(modelMapping,'Simulink.CppModelMapping.ModelMapping')

        categories=coder.mapping.internal.allowedDataCategories(modelMapping);
    else

        categories=coder.mapping.internal.dataCategories();

        oldCategoryLabels={'LocalParameters','GlobalParameters','ExternalParameterObjects','ParameterArguments'};
        categories(ismember(categories,oldCategoryLabels))=[];

        categoriesToRemove='';
        if isa(modelMapping,'Simulink.CoderDictionary.ModelMappingSLC')

            categoriesToRemove={'ModelParameterArguments',...
            'ParameterArguments','Constants',...
            'SelfDataStructure','ModelData',...
            'DataTransfers'};
        end

        categories(ismember(categories,categoriesToRemove))=[];
    end

end
