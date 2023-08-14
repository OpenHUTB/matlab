function setDefaultsMappingFromMappingInspector(mappingObj,modelingElementCategory,varargin)





    argParser=inputParser;
    argParser.FunctionName='setDefaultsMappingFromMappingInspector';
    argParser.KeepUnmatched=true;
    argParser.parse(varargin{:});

    params=argParser.Unmatched;
    propertyNames=fieldnames(params);
    propertyValues=struct2cell(params);
    errorMessages=cell(size(propertyNames));

    modelingElementCategoryForAPI=modelingElementCategory;
    switch modelingElementCategory
    case 'SharedParameters'
        modelingElementCategoryForAPI='ModelParameters';
    case 'PerInstanceParameters'
        modelingElementCategoryForAPI='ModelParameterArguments';
    case 'InitTermFunctions'
        modelingElementCategoryForAPI='InitializeTerminate';
    case 'ExecutionFunctions'
        modelingElementCategoryForAPI='Execution';
    case 'SharedUtilityFunctions'
        modelingElementCategoryForAPI='SharedUtility';
    end

    if isequal(propertyNames{:},'MemorySection')
        if strcmp(propertyValues{:},DAStudio.message('coderdictionary:mapping:MappingNone'))
            mappingObj.DefaultsMapping.unset(modelingElementCategoryForAPI,'MemorySection');
        else
            if startsWith(propertyValues{:},DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI'))

                uuid='';
            else
                uuid=mappingObj.DefaultsMapping.getMemorySectionUuidFromName(propertyValues{:});
            end
            mappingObj.DefaultsMapping.set(modelingElementCategoryForAPI,'MemorySection',uuid);
        end
    else

        dataRef=mappingObj.DefaultsMapping.(modelingElementCategory);
        storageClass=mappingObj.DefaultsMapping.getGroupNameFromUuid(dataRef.StorageClass.UUID);
        for ii=1:numel(propertyNames)
            propertyName=propertyNames{ii};
            propertyValue=propertyValues{ii};
            if isa(propertyValue,'logical')


                propertyValue=int2str(propertyValue);
            end


            errorMessage=mappingObj.DefaultsMapping.setPerInstanceProperty(...
            modelingElementCategoryForAPI,storageClass,propertyName,propertyValue);
            if~isempty(errorMessage)
                errorMessages{ii}=errorMessage;
            end
        end
    end

    errorMessages=errorMessages(~cellfun('isempty',errorMessages));
    if numel(errorMessages)>0
        error(errorMessages{1});
    end
