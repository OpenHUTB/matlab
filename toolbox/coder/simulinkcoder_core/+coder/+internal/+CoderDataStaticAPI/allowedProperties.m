function out=allowedProperties(dictName,category)







    out=[];
    switch category
    case coder.mapping.internal.dataCategories()
        out={'StorageClass'};
        sc=coder.mapping.defaults.get(dictName,category,'StorageClass');
        scObj=coder.internal.CoderDataStaticAPI.getByName(dictName,'StorageClass',sc);
        if isequal(sc,DAStudio.message('coderdictionary:mapping:SimulinkGlobal'))




            out=[out,'MemorySection'];
        elseif isa(scObj,'coderdictionary.data.LegacyStorageClass')
            swc=coder.internal.CoderDataStaticAPI.getSWCT(dictName);
            hlp=coder.internal.CoderDataStaticAPI.getHelper;
            cat=hlp.getProp(swc,category);
            instSpecificSchema=hlp.getProp(cat,'InitialCSCAttributesSchema');
            instanceSpecificProperties={};
            if~isempty(instSpecificSchema)
                instSp=jsondecode(instSpecificSchema);
                if~isempty(instSp)
                    instanceSpecificProperties={instSp.Name};
                end
            end
            out=[out,instanceSpecificProperties];
        end
        out=out';
    case coder.mapping.internal.functionCategories()
        out={DAStudio.message('coderdictionary:mapping:FunctionClass')};
        fct=coder.mapping.defaults.get(dictName,category,...
        'FunctionCustomizationTemplate');
        if isequal(fct,DAStudio.message('coderdictionary:mapping:MappingFunctionDefault'))


            out=[out,'MemorySection'];
        end
        out=out';
    otherwise
        assert(false,sprintf('The %s is not handled yet.',category));
    end
end


