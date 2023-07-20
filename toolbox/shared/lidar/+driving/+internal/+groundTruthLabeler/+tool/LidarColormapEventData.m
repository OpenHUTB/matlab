classdef(ConstructOnLoad)LidarColormapEventData<event.EventData



    properties
Colormap
ColormapValue
    end

    methods
        function eventData=LidarColormapEventData(cmap,val)
            eventData.Colormap=cmap;
            eventData.ColormapValue=val;
        end
    end
end