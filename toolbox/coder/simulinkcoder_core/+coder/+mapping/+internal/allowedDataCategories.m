function categories=allowedDataCategories(modelMapping)




    if isa(modelMapping,'Simulink.CppModelMapping.ModelMapping')

        categories={'Inports',...
        'Outports',...
        'ModelParameters',...
        'ModelParameterArguments',...
        'InternalData'};
    else

        categories=coder.mapping.internal.dataCategories();

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
