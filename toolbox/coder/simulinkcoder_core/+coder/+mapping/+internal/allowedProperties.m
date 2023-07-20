function out=allowedProperties(modelH,category,mapping)






    out=[];
    switch category
    case coder.mapping.internal.dataCategories()
        out={'StorageClass'};
        sc=coder.mapping.internal.getDataDefault(modelH,category,...
        'StorageClass',mapping);
        if isequal(sc,DAStudio.message('coderdictionary:mapping:SimulinkGlobal'))




            out=[out,'MemorySection'];
        end

        propName=mapping.DefaultsMapping.getPropNameFromType(category);
        targetDataRef=eval(['mapping.DefaultsMapping.',propName]);
        if~isempty(targetDataRef)&&~isempty(targetDataRef.StorageClass)
            instanceSpecificProperties=targetDataRef.getCSCAttributeNames(modelH)';
            instanceSpecificProperties=setdiff(instanceSpecificProperties,targetDataRef.getPerInstanceAttributeNames','stable');
            out=[out,instanceSpecificProperties];
        end
        out=out';
    case coder.mapping.internal.functionCategories()
        out={DAStudio.message('coderdictionary:mapping:FunctionClass')};
        mapping=Simulink.CodeMapping.get(modelH,'CoderDictionary');
        if~mapping.DefaultsMapping.isMemorySectionDisabledOnMapping(category)



            out=[out,'MemorySection'];
        end

        out=out';
    otherwise
        assert(false,sprintf('The %s is not handled yet.',category));
    end
end


