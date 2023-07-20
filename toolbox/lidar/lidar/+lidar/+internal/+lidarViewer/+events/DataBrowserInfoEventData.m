classdef(ConstructOnLoad)DataBrowserInfoEventData<event.EventData





    properties
DataName
    end

    methods
        function data=DataBrowserInfoEventData(dataName)
            data.DataName=dataName;
        end
    end
end