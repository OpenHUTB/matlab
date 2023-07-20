classdef(ConstructOnLoad)LidarViewerCameraViewEventData<event.EventData




    properties
Method
EgoDirection
    end

    methods
        function eventData=LidarViewerCameraViewEventData(method,varargin)
            egoDirection='';
            if nargin>1
                egoDirection=varargin{1};
            end
            eventData.EgoDirection=egoDirection;
            eventData.Method=method;
        end
    end
end