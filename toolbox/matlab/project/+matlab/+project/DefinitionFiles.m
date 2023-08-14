classdef DefinitionFiles




    properties(Hidden=true)
        fFactories;
    end

    methods(Hidden=true)
        function obj=DefinitionFiles(factories)
            obj.fFactories=factories;
        end

        function factory=getFactory(obj)
            factory=obj.fFactories{end};
        end

        function factory=getFactoryByIndex(obj,idx)
            if isempty(idx)
                factory=obj.getFactory();
                return;
            end
            factory=obj.fFactories{idx};
        end
    end

    enumeration
        SingleFile(["monolithic"]);
        FixedPathMultiFile(["fixedPathV1","fixedPath"]);
        MultiFile(["distributed"]);
    end

end

