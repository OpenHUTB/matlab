classdef M3IGarbageCollectorContext<handle






    methods(Abstract)
        m3iModel=getM3IModel(this);
        cacheRestoreDirtyState(this);
    end

    methods(Static)
        function context=createContext(src)

            if is_simulink_handle(src)&&strcmp(get(src,'type'),'block_diagram')
                src=getfullname(src);
            end

            if endsWith(src,'.sldd')
                interfaceDictName=src;
                context=autosar.mm.sl2mm.internal.M3IGarbageCollectorDictionaryContext(interfaceDictName);
            else
                modelName=src;
                context=autosar.mm.sl2mm.internal.M3IGarbageCollectorModelContext(modelName);
            end
        end
    end
end


