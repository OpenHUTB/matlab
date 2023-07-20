classdef M3IModelContext<handle











    methods(Abstract)
        m3iModel=getM3IModel(this);
        isMapped=isContextMappedToSubComponent(this);
        isMapped=isContextMappedToAdaptiveApplication(this);
        isMapped=isContextMappedToComposition(this);
        isArch=isContextArchitectureModel(this);
        length=getMaxShortNameLength(this);
        schemaVer=getAutosarSchemaVersion(this);
        [hasMapping,mapping,m3iMappedComp]=hasCompMapping(this);
        ddName=getDataDictionaryName();



        name=getContextName(this);
    end

    methods(Static)
        function context=createContext(src)
            if is_simulink_handle(src)&&strcmp(get(src,'type'),'block_diagram')
                src=getfullname(src);
            end

            if endsWith(src,'.sldd')
                interfaceDictName=src;
                context=autosar.api.internal.M3IModelDictionaryContext(interfaceDictName);
            else
                modelName=src;
                context=autosar.api.internal.M3IModelSLModelContext(modelName);
            end
        end
    end
end


