




classdef SimulationOutputIndexer
    properties(Dependent)
Keys
    end

    properties(Access=private)
Extractors
IndexToExtractorMap
    end

    methods
        function obj=SimulationOutputIndexer(extractors)
            validateattributes(extractors,{'MultiSim.internal.BaseExtractor'},{'nonempty'});
            obj.Extractors=extractors;
            obj.IndexToExtractorMap=containers.Map;

            keys=obj.Keys;
            for i=1:numel(keys)
                obj.IndexToExtractorMap(keys(i))=obj.Extractors(i);
            end
        end

        function keys=get.Keys(obj)
            keys=arrayfun(@(x)x.StringIndex,obj.Extractors);
        end

        function extractor=getExtractor(obj,key)
            extractor=obj.IndexToExtractorMap(key);
        end
    end
end
