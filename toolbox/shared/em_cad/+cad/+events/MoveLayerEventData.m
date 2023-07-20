classdef(ConstructOnLoad)MoveLayerEventData<event.EventData





    properties
Data
    end

    methods
        function eventObj=MoveLayerEventData(layerInfo,dir)
            eventObj.Data.Layer=layerInfo;
            eventObj.Data.Direction=dir;
        end

    end
end

