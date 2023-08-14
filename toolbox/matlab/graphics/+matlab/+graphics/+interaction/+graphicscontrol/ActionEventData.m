classdef ActionEventData<event.EventData




    properties
figx
figy
x
y
name
interactionID
hitObjectIds
additionalData
    end

    methods
        function data=ActionEventData(figx,figy,x,y,name,interactionID,hitObjectIds,additionalData)
            data.figx=figx;
            data.figy=figy;
            data.x=x;
            data.y=y;
            data.name=name;
            data.interactionID=interactionID;
            data.hitObjectIds=hitObjectIds;
            data.additionalData=additionalData;
        end
    end
end
