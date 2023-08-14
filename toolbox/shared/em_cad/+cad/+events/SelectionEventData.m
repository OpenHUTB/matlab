classdef(ConstructOnLoad)SelectionEventData<event.EventData





    properties
Data
SelectionView
    end

    methods
        function eventObj=SelectionEventData(Data,SelectionView)
            if nargin==1
                SelectionView='Canvas';
            end
            eventObj.Data=Data;
            eventObj.SelectionView=SelectionView;
        end

    end
end

