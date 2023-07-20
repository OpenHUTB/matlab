classdef(ConstructOnLoad)EditRequestEventData<event.EventData





    properties


        EditName string
        IsTemporal logical
    end

    methods
        function data=EditRequestEventData(editName,isTemporal)
            data.EditName=editName;
            data.IsTemporal=isTemporal;
        end
    end
end