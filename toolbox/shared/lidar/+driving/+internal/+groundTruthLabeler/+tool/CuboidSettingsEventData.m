classdef(ConstructOnLoad)CuboidSettingsEventData<event.EventData



    properties
ShrinkCuboid
    end

    methods
        function eventData=CuboidSettingsEventData(tf)
            eventData.ShrinkCuboid=tf;
        end
    end
end