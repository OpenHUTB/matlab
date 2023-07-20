classdef(ConstructOnLoad)PointSizeChangeEventData<event.EventData





    properties
        PointSize;
    end

    methods

        function data=PointSizeChangeEventData(pointSize)
            data.PointSize=pointSize;
        end
    end
end