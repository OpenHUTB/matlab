function validateArguments(~,mapping,modelingElementType,propertyName)




    if isempty(mapping)
        DAStudio.error('coderdictionary:api:noDefaultMapping');
    end

    msgArg='C/C++';

    if~(isa(mapping,'Simulink.CoderDictionary.ModelMapping')||...
        isa(mapping,'Simulink.CoderDictionary.ModelMappingSLC')||...
        isa(mapping,'Simulink.CppModelMapping.ModelMapping'))
        DAStudio.error('coderdictionary:api:supportedForErtCppTarget',msgArg);
    end
    if isa(mapping,'Simulink.CoderDictionary.ModelMappingSLC')...
        &&any(strcmp(propertyName,{DAStudio.message('coderdictionary:mapping:FunctionClass'),'MemorySection'}))
        DAStudio.error('coderdictionary:api:invalidAttributeName',propertyName);
    end
    if nargin>2
        switch modelingElementType
        case coder.mapping.internal.dataCategories()
            if strcmp(propertyName,DAStudio.message('coderdictionary:mapping:FunctionClass'))
                DAStudio.error('coderdictionary:api:invalidAttributeNameForCategory',propertyName,modelingElementType);
            end
        case coder.mapping.internal.functionCategories()
            if~any(strcmp(propertyName,{DAStudio.message('coderdictionary:mapping:FunctionClass'),'MemorySection'}))
                DAStudio.error('coderdictionary:api:invalidAttributeNameForCategory',propertyName,modelingElementType);
            end
        otherwise
            assert(false,sprintf('Add handling for Simulink modeling element type %s',modelingElementType));
        end
    end
end


