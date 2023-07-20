classdef LayerToCompMapInfo










    properties(Constant)
        LayerToCompMap=dltargets.internal.LayerToCompMapData();
    end

    methods
        function layerToCompMap=getLayersToCompMap(obj)
            layerToCompMap=[obj.LayerToCompMap.NonCustomLayersToCompMap;...
            obj.LayerToCompMap.CustomLayersToCompMap];
        end

        function layerToCompMap=getNonCustomLayersToCompMap(obj)
            layerToCompMap=obj.LayerToCompMap.NonCustomLayersToCompMap;
        end

        function layerToCompMap=getCustomLayersToCompMap(obj)
            layerToCompMap=obj.LayerToCompMap.CustomLayersToCompMap;
        end
    end
end

