classdef(ConstructOnLoad)CustomCameraOperationEventData<event.EventData





    properties
OperationID




ViewID
    end

    methods

        function data=CustomCameraOperationEventData(opertaionID,viewID)
            data.OperationID=opertaionID;
            if nargin==1
                viewID=0;
            end
            data.ViewID=viewID;
        end
    end

end