classdef mappingCategories<handle








    methods(Static,Access=public)
        function categories=getDataCategoriesForDataDefaults()
            categories={
            'LocalParameters',...
            'ParameterArguments',...
            'InternalData',...
            'InportsOutports'};
        end

        function categories=getMappedToCategoriesForInternalData()
            categories={
            'Default',...
            'ArTypedPerInstanceMemory',...
            'StaticMemory',...
            'StorageClass'};
        end

        function categories=getMappedToCategoriesForParameters()
            categories={
            'Default',...
            'SharedParameters',...
            'PerInstanceParameter',...
            'StorageClass',...
            };
        end

        function categories=getMappedToCategoriesForEndToEndProtectionMethods()
            categories={
            'ProtectionWrapper',...
            'TransformerError'};
        end
    end
end
