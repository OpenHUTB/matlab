classdef(ConstructOnLoad)MeasurementToolEventData<event.EventData





    properties

ToolType

ToolObj

        ToCancel(1,1)logical=false;
    end

    methods

        function data=MeasurementToolEventData(toolType,ToolObj,toCancel)
            data.ToolType=toolType;
            data.ToolObj=ToolObj;
            if nargin==3
                data.ToCancel=toCancel;
            end
        end

    end

end